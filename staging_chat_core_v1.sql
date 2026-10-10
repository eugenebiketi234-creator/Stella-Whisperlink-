-- STELLA WHISPERLINK STAGING ONLY
-- Apply ONLY to Supabase project dodfgntgfosjscqewuwr (stella-whisperlink-staging).
-- Do not apply to production project eklluunyjifnucleeqhc.
-- Contains schema + RLS + minimal session RPCs. No production records are copied.

begin;

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  username text,
  lang text not null default 'English',
  industry text not null default 'General',
  avatar_color smallint not null default 0,
  code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^WL-[A-Z0-9]{6}$'),
  name text not null default '',
  industry text not null default 'General',
  role text,
  purpose text,
  created_by uuid not null references public.profiles(id),
  status text not null default 'waiting' check (status in ('waiting','active','ended')),
  created_at timestamptz not null default now(),
  ended_at timestamptz
);

create table public.participants (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  unique (session_id,user_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  sender_id uuid not null references public.profiles(id),
  original_text text not null,
  original_lang text not null,
  translated_text text,
  translated_lang text,
  confidence smallint,
  translation_source text,
  created_at timestamptz not null default now(),
  reply_to_message_id uuid references public.messages(id),
  edited_at timestamptz,
  deleted_at timestamptz
);

-- This table is intentionally empty in staging until synthetic terminology fixtures are added.
create table public.terminology_runtime (
  runtime_id bigint generated always as identity primary key,
  family_id text not null,
  concept_id text not null,
  language_code text not null,
  canonical_english text not null,
  resolution_mode text not null check (resolution_mode in ('PREFERRED','ENGLISH-RETAINED','FALLBACK')),
  resolved_term text not null,
  stage3_outcome text not null check (stage3_outcome in ('VERIFIED LOCALIZED','ENGLISH-RETAINED','FALLBACK')),
  release_version text not null,
  release_status text not null default 'released' check (release_status in ('draft','released','revoked')),
  source_cell_id text not null,
  released_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index participants_session_active_idx on public.participants(session_id,user_id) where left_at is null;
create index messages_session_created_idx on public.messages(session_id,created_at);
create index terminology_runtime_lookup_idx on public.terminology_runtime(family_id,language_code,release_status,concept_id);
create unique index terminology_runtime_release_cell_unique on public.terminology_runtime(family_id,concept_id,language_code,release_version);

alter table public.profiles enable row level security;
alter table public.sessions enable row level security;
alter table public.participants enable row level security;
alter table public.messages enable row level security;
alter table public.terminology_runtime enable row level security;

create or replace function private.is_current_active_session_member(p_session_id uuid)
returns boolean
language sql stable security definer
set search_path = pg_catalog, public
as $$
  select auth.uid() is not null and exists (
    select 1 from public.participants p
    where p.session_id = p_session_id and p.user_id = auth.uid() and p.left_at is null
  );
$$;

create or replace function private.has_session_history_access(p_session_id uuid)
returns boolean
language sql stable security definer
set search_path = pg_catalog, public
as $$
  select auth.uid() is not null and exists (
    select 1 from public.participants p
    where p.session_id = p_session_id and p.user_id = auth.uid()
  );
$$;

revoke all on function private.is_current_active_session_member(uuid) from public, anon;
revoke all on function private.has_session_history_access(uuid) from public, anon;
grant execute on function private.is_current_active_session_member(uuid) to authenticated;
grant execute on function private.has_session_history_access(uuid) to authenticated;

create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profiles_update_own on public.profiles
  for update to authenticated using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy sessions_select_history_member on public.sessions
  for select to authenticated
  using (created_by = (select auth.uid()) or private.has_session_history_access(id));
create policy sessions_insert_creator on public.sessions
  for insert to authenticated
  with check (created_by = (select auth.uid()));

create policy participants_select_own_or_active_roster on public.participants
  for select to authenticated
  using (user_id = (select auth.uid()) or private.is_current_active_session_member(session_id));

create policy messages_select_session_history on public.messages
  for select to authenticated using (private.has_session_history_access(session_id));
create policy messages_insert_active_member on public.messages
  for insert to authenticated
  with check (
    sender_id = (select auth.uid())
    and private.is_current_active_session_member(session_id)
  );

-- Keep client-supplied lifecycle/translation metadata from being forged.
create or replace function private.prepare_message_insert_staging()
returns trigger language plpgsql security definer
set search_path = pg_catalog, public
as $$
begin
  new.created_at := now();
  new.translated_text := null;
  new.translated_lang := null;
  new.confidence := null;
  new.translation_source := null;
  new.edited_at := null;
  new.deleted_at := null;
  return new;
end;
$$;
revoke all on function private.prepare_message_insert_staging() from public, anon, authenticated;
create trigger prepare_message_insert_staging
  before insert on public.messages
  for each row execute function private.prepare_message_insert_staging();

create or replace function private.prepare_session_insert_staging()
returns trigger language plpgsql security definer
set search_path = pg_catalog, public
as $$
begin
  new.status := 'waiting';
  new.created_at := now();
  new.ended_at := null;
  return new;
end;
$$;
revoke all on function private.prepare_session_insert_staging() from public, anon, authenticated;
create trigger prepare_session_insert_staging
  before insert on public.sessions
  for each row execute function private.prepare_session_insert_staging();

-- Explicit Data API grants; row access remains governed by RLS.
grant select, update on public.profiles to authenticated;
grant select, insert on public.sessions to authenticated;
grant select on public.participants to authenticated;
grant select, insert on public.messages to authenticated;
revoke all on public.terminology_runtime from anon, authenticated;

create or replace function public.handle_new_user_staging()
returns trigger
language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_name text;
  v_color smallint := 0;
begin
  v_name := coalesce(new.raw_user_meta_data->>'name', '');
  if coalesce(new.raw_user_meta_data->>'avatar_color','') ~ '^-?[0-9]{1,4}$' then
    v_color := (new.raw_user_meta_data->>'avatar_color')::smallint;
  end if;
  insert into public.profiles(id,name,username,lang,industry,avatar_color,code)
  values (
    new.id,
    v_name,
    nullif(new.raw_user_meta_data->>'username',''),
    coalesce(nullif(new.raw_user_meta_data->>'lang',''),'English'),
    coalesce(nullif(new.raw_user_meta_data->>'industry',''),'General'),
    v_color,
    upper(left(regexp_replace(v_name, '[^A-Za-z0-9]', '', 'g'), 2))
  ) on conflict (id) do nothing;
  return new;
end;
$$;
revoke all on function public.handle_new_user_staging() from public, anon, authenticated;
create trigger on_auth_user_created_staging after insert on auth.users
  for each row execute function public.handle_new_user_staging();

create or replace function public.auto_join_session_creator_staging()
returns trigger language plpgsql security definer
set search_path = pg_catalog, public
as $$
begin
  if auth.uid() is not null and new.created_by = auth.uid() then
    insert into public.participants(session_id,user_id) values (new.id,new.created_by)
    on conflict (session_id,user_id) do nothing;
  end if;
  return new;
end;
$$;
revoke all on function public.auto_join_session_creator_staging() from public, anon, authenticated;
create trigger on_session_created_auto_join_staging after insert on public.sessions
  for each row execute function public.auto_join_session_creator_staging();

create or replace function public.join_session_by_code_v2(p_code text)
returns jsonb language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare
  v_user uuid := auth.uid();
  v_session public.sessions%rowtype;
  v_count integer;
begin
  if v_user is null then return jsonb_build_object('ok',false,'error','AUTH_REQUIRED','message','Authentication required'); end if;
  if coalesce(trim(p_code),'') = '' then return jsonb_build_object('ok',false,'error','EMPTY_CODE','message','EMPTY_CODE'); end if;
  select * into v_session from public.sessions
    where code=upper(trim(p_code)) and status <> 'ended' for update;
  if not found then return jsonb_build_object('ok',false,'error','NOT_FOUND','message','Session not found or ended'); end if;
  if exists (select 1 from public.participants p where p.session_id=v_session.id and p.user_id=v_user and p.left_at is null) then
    return jsonb_build_object('ok',true,'session',to_jsonb(v_session));
  end if;
  select count(*) into v_count from public.participants p where p.session_id=v_session.id and p.left_at is null;
  if v_count >= 4 then return jsonb_build_object('ok',false,'error','SESSION_FULL','message','SESSION_FULL'); end if;
  insert into public.participants(session_id,user_id,joined_at,left_at)
  values (v_session.id,v_user,now(),null)
  on conflict (session_id,user_id) do update set joined_at=excluded.joined_at,left_at=null;
  if v_count >= 1 then update public.sessions set status='active' where id=v_session.id and status='waiting'; end if;
  select * into v_session from public.sessions where id=v_session.id;
  return jsonb_build_object('ok',true,'session',to_jsonb(v_session));
end;
$$;
revoke all on function public.join_session_by_code_v2(text) from public, anon;
grant execute on function public.join_session_by_code_v2(text) to authenticated;

create or replace function public.leave_session(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('ok',false,'error','AUTH_REQUIRED'); end if;
  update public.participants set left_at=now()
    where session_id=p_session_id and user_id=v_user and left_at is null;
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.leave_session(uuid) from public, anon;
grant execute on function public.leave_session(uuid) to authenticated;

create or replace function public.end_session(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('ok',false,'error','AUTH_REQUIRED'); end if;
  update public.sessions set status='ended',ended_at=now()
    where id=p_session_id and created_by=v_user and status <> 'ended';
  if not found then return jsonb_build_object('ok',false,'error','NOT_FOUND_OR_NOT_OWNER'); end if;
  update public.participants set left_at=coalesce(left_at,now()) where session_id=p_session_id;
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.end_session(uuid) from public, anon;
grant execute on function public.end_session(uuid) to authenticated;

create or replace function public.get_co_participant_profiles(p_user_ids uuid[])
returns table(id uuid,name text,lang text,industry text,avatar_color smallint,code text)
language sql stable security definer
set search_path = pg_catalog, public
as $$
  select distinct p.id,p.name,p.lang,p.industry,p.avatar_color,p.code
  from public.profiles p
  where auth.uid() is not null
    and p.id=any(coalesce(p_user_ids,array[]::uuid[]))
    and exists (
      select 1 from public.participants mine
      join public.participants theirs on theirs.session_id=mine.session_id
      where mine.user_id=auth.uid() and theirs.user_id=p.id
    );
$$;
revoke all on function public.get_co_participant_profiles(uuid[]) from public, anon;
grant execute on function public.get_co_participant_profiles(uuid[]) to authenticated;

create or replace function public.edit_message(p_message_id uuid,p_new_text text)
returns jsonb language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('ok',false,'error','AUTH_REQUIRED'); end if;
  if p_new_text is null or length(trim(p_new_text))=0 or length(p_new_text)>10000 then return jsonb_build_object('ok',false,'error','INVALID_TEXT'); end if;
  update public.messages m set original_text=trim(p_new_text),edited_at=now(),translated_text=null,translated_lang=null,confidence=null,translation_source=null
  where m.id=p_message_id and m.sender_id=v_user and m.deleted_at is null
    and private.is_current_active_session_member(m.session_id);
  if not found then return jsonb_build_object('ok',false,'error','NOT_FOUND_OR_NOT_ALLOWED'); end if;
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.edit_message(uuid,text) from public, anon;
grant execute on function public.edit_message(uuid,text) to authenticated;

create or replace function public.delete_message_for_everyone(p_message_id uuid)
returns jsonb language plpgsql security definer
set search_path = pg_catalog, public
as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('ok',false,'error','AUTH_REQUIRED'); end if;
  update public.messages m set original_text='',deleted_at=now(),translated_text=null,translated_lang=null,confidence=null,translation_source=null
  where m.id=p_message_id and m.sender_id=v_user and m.deleted_at is null
    and private.is_current_active_session_member(m.session_id);
  if not found then return jsonb_build_object('ok',false,'error','NOT_FOUND_OR_NOT_ALLOWED'); end if;
  return jsonb_build_object('ok',true);
end;
$$;
revoke all on function public.delete_message_for_everyone(uuid) from public, anon;
grant execute on function public.delete_message_for_everyone(uuid) to authenticated;

create or replace function private.validate_reply_target_staging()
returns trigger language plpgsql security definer
set search_path = pg_catalog, public
as $$
begin
  if new.reply_to_message_id is not null and not exists (
    select 1 from public.messages target where target.id=new.reply_to_message_id and target.session_id=new.session_id
  ) then raise exception 'REPLY_TARGET_WRONG_SESSION'; end if;
  return new;
end;
$$;
revoke all on function private.validate_reply_target_staging() from public, anon, authenticated;
create trigger validate_message_reply_target_staging
  before insert or update of reply_to_message_id,session_id on public.messages
  for each row execute function private.validate_reply_target_staging();

-- Replicate table-level Realtime publication membership only; no production data is imported.
do $$
begin
  if exists (select 1 from pg_publication where pubname='supabase_realtime') then
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='messages') then
      alter publication supabase_realtime add table public.messages;
    end if;
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='participants') then
      alter publication supabase_realtime add table public.participants;
    end if;
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='sessions') then
      alter publication supabase_realtime add table public.sessions;
    end if;
  end if;
end;
$$;

commit;

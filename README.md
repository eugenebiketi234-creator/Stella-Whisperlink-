# WhisperLink staging setup

Target project: `stella-whisperlink-staging`  
Project ref: `dodfgntgfosjscqewuwr`  
API URL: `https://dodfgntgfosjscqewuwr.supabase.co`  
Branch: `stella-whisperlink-staging`

**Important:** The migration has been prepared but was NOT applied by ChatGPT. The attempted Supabase write was blocked before execution. This SQL is a staging-only draft and requires application and verification in the Supabase SQL/migration interface. Apply it once only; the script is a first-run scaffold rather than an idempotent re-run migration. Never run it against production ref `eklluunyjifnucleeqhc`.

## Before opening a Vercel preview

The GitHub branch's `index.html` was verified to contain the production Supabase URL/key when last inspected. The attempted GitHub update was blocked before execution, so it still requires a branch-only change:

- Replace `https://eklluunyjifnucleeqhc.supabase.co` with `https://dodfgntgfosjscqewuwr.supabase.co`.
- Replace `sb_publishable_-AUhd2MisNkRWXjwJa_vOA_rIEFD3J6` with the staging publishable key `sb_publishable_0PVTUhxiM1NIZaWR5iUCaA_S0drYYAb`.
- Commit only to `stella-whisperlink-staging`; do not change `main`.

Publishable keys are designed for browser use; never add a service-role/secret key to `index.html` or GitHub.

## Apply and verify

1. Open the SQL/migration editor for staging project `dodfgntgfosjscqewuwr`.
2. Review the SQL file before applying. This creates minimal `profiles`, `sessions`, `participants`, `messages`, and `terminology_runtime` tables, RLS policies, signup/profile triggers, and core session/message RPCs. It does not copy any user messages or terminology records from production.
3. Apply it only to staging and verify the five tables have RLS enabled.
4. Run Supabase security advisors and resolve unexpected warnings before testing.
5. Only after the GitHub branch uses staging credentials, open its Vercel preview and use two synthetic anonymous test users to create/join a session and send synthetic messages.
6. The Chat translation gateway still needs to be implemented separately in staging. This migration does not deploy any Edge Function and does not change Solo/Demo or production.

The migration is a first staging scaffold, not an assertion that the complete production schema or every production policy has been reproduced. Validate in staging before treating it as the test oracle.

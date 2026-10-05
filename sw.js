const CACHE_NAME = 'whisperlink-shell-v2';
const APP_SHELL = '/';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.add(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) =>
      Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      )
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;

  // Service workers only handle GET requests here.
  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);

  // Never intercept cross-origin services such as Supabase,
  // translation providers, CDNs, APIs, etc.
  if (url.origin !== self.location.origin) {
    return;
  }

  // Navigation requests: network first.
  // This keeps WhisperLink fresh while allowing the cached
  // root application to load when the network is unavailable.
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => response)
        .catch(() => caches.match(APP_SHELL))
    );

    return;
  }

  // Same-origin static resources: network first, then cache.
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response && response.ok) {
          const copy = response.clone();

          event.waitUntil(
            caches.open(CACHE_NAME)
              .then((cache) => cache.put(request, copy))
          );
        }

        return response;
      })
      .catch(() => caches.match(request))
  );
});

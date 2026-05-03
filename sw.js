// Service Worker - Mon Budget (cloud sync)
// Stratégie : cache-first pour les assets de l'app, network-first avec fallback pour les API

const CACHE_NAME = 'mon-budget-cloud-v5';
const RUNTIME_CACHE = 'mon-budget-runtime-v5';

// Fichiers de l'app à mettre en cache à l'installation
const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k !== CACHE_NAME && k !== RUNTIME_CACHE)
          .map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET') return;

  // Les requêtes vers Supabase passent toujours en réseau direct
  // (pas de cache car données dynamiques + auth tokens)
  if (url.host.endsWith('.supabase.co') || url.host.endsWith('.supabase.in')) {
    return; // laisse le navigateur gérer
  }

  // Stratégie cache-first pour notre app shell
  if (APP_SHELL.includes(url.pathname.split('/').pop()) || url.pathname.endsWith('/')) {
    event.respondWith(
      caches.match(event.request).then((cached) => cached || fetch(event.request))
    );
    return;
  }

  // Pour les CDN (Supabase SDK, Google Fonts) : cache puis réseau
  if (
    url.host === 'esm.sh' ||
    url.host === 'fonts.googleapis.com' ||
    url.host === 'fonts.gstatic.com'
  ) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        if (cached) return cached;
        return fetch(event.request).then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(RUNTIME_CACHE).then((cache) => cache.put(event.request, clone));
          }
          return response;
        });
      })
    );
    return;
  }

  // Par défaut : réseau d'abord, sinon cache, sinon page d'app
  event.respondWith(
    fetch(event.request)
      .catch(() => caches.match(event.request))
      .then((res) => res || (event.request.mode === 'navigate' ? caches.match('./index.html') : undefined))
  );
});

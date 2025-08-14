// service-worker.js (icons INCLUDED, subpath-safe)
- const CACHE_NAME = 'tetris-v1';
+ const CACHE_NAME = 'tetris-v2';  // ← 버전 올림
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.mode === 'navigate') {
    e.respondWith(
      fetch(req).then(r => {
        const copy = r.clone();
        caches.open(CACHE_NAME).then(c => c.put('./index.html', copy));
        return r;
      }).catch(() => caches.match('./index.html'))
    );
  } else {
    e.respondWith(
      caches.match(req).then(cached => cached || fetch(req).then(r => {
        const rsp = r.clone();
        caches.open(CACHE_NAME).then(c => c.put(req, rsp));
        return r;
      }))
    );
  }
});

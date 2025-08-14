// service-worker.js
const CACHE_NAME = 'tetris-v4'; // 버전 올리기
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  // 필요한 이미지, 사운드 파일이 있다면 여기에 추가
];

// 설치 단계: 필수 파일 캐시
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS))
  );
});

// 활성화 단계: 오래된 캐시 삭제
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
});

// 요청 가로채기: HTML/JS/CSS는 네트워크 우선
self.addEventListener('fetch', event => {
  const req = event.request;

  // HTML 파일은 네트워크 우선
  if (req.mode === 'navigate' || req.destination === 'document') {
    event.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
        return res;
      }).catch(() => caches.match(req))
    );
    return;
  }

  // JS/CSS/Manifest 파일도 네트워크 우선
  if (req.destination === 'script' || req.destination === 'style' || req.destination === 'manifest') {
    event.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
        return res;
      }).catch(() => caches.match(req))
    );
    return;
  }

  // 이미지, 폰트 등은 캐시 우선
  event.respondWith(
    caches.match(req).then(cached => cached || fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
      return res;
    }))
  );
});

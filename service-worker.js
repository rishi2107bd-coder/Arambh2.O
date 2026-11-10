const SCOPE_PATH = new URL("./", self.registration.scope).pathname;
const SCOPE_KEY = SCOPE_PATH.replace(/^\/$/, "root").replace(/[^A-Za-z0-9_-]/g, "-");
const CACHE_PREFIX = `arambh-mobile-${SCOPE_KEY}-`;
const CACHE = `${CACHE_PREFIX}v1`;
const APP_FILES = ["./", "./index.html", "./admin.html", "./theme.css", "./config.js", "./manifest.webmanifest", "./icons/icon.svg", "./icons/icon-192.png", "./icons/icon-512.png"];
self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(APP_FILES)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith(CACHE_PREFIX) && key !== CACHE).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== "GET" || url.origin !== self.location.origin || !url.pathname.startsWith(SCOPE_PATH)) return;
  event.respondWith(fetch(request).then(response => {
    if (response.ok) { const copy = response.clone(); caches.open(CACHE).then(cache => cache.put(request, copy)); }
    return response;
  }).catch(() => caches.open(CACHE).then(cache => cache.match(request).then(cached => cached || (request.mode === "navigate" ? cache.match(new URL("index.html", self.registration.scope).href) : Response.error())))));
});


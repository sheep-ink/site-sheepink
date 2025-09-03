export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // /content-media/* と /content-data/* は R2 から返す
    const r2PathPrefixes = ["/content-media/", "/data-media/"];
    if (r2PathPrefixes.some((prefix) => url.pathname.startsWith(prefix))) {
      const cache = caches.default;
      const cacheKey = new Request(request.url, request);

      // CDN キャッシュにあれば即返す
      const cached = await cache.match(cacheKey);
      if (cached) return cached;

      // 例: /content-media/foo.jpg -> content-media/foo.jpg
      const key = url.pathname.slice(1);

      // R2 から取得
      const obj = await env.IMAGES.get(key);
      if (!obj) return new Response("Not Found", { status: 404 });

      // 必要最小のヘッダ
      const headers = new Headers();

      // R2 の httpMetadata を優先（無ければ application/octet-stream）
      const ct = obj.httpMetadata?.contentType || "application/octet-stream";
      headers.set("Content-Type", ct);

      // ブラウザ1日 + エッジ30日（immutable）
      headers.set("Cache-Control", "public, max-age=86400, s-maxage=2592000, immutable");

      // R2 側の他メタがあれば反映（なければ何もしない）
      obj.writeHttpMetadata?.(headers);
      const resp = new Response(obj.body, { status: 200, headers });

      // GET かつ 200 のときだけ CDN に保存
      if (request.method === "GET") {
        ctx.waitUntil(cache.put(cacheKey, resp.clone()));
      }
      return resp;
    }

    // それ以外は Hugo の静的サイト
    return env.ASSETS.fetch(request);
  },
};

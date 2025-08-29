export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // --- /images/* は R2 から返す ---
    if (url.pathname.startsWith("/images/")) {
      const key = url.pathname.replace(/^\/images\//, "");
      const obj = await env.IMAGES.get(key);

      if (!obj) {
        return new Response("Not Found", { status: 404 });
      }

      // Content-Type ヘッダ
      const headers = new Headers();
      if (obj.httpMetadata?.contentType) {
        headers.set("Content-Type", obj.httpMetadata.contentType);
      } else {
        headers.set("Content-Type", "application/octet-stream");
      }

      // Cache-Control ヘッダ（ブラウザやCDNにキャッシュさせる）
      headers.set("Cache-Control", "public, max-age=86400, immutable");

      return new Response(obj.body, { status: 200, headers });
    }

    // --- それ以外は Hugo の静的サイトを返す ---
    return env.ASSETS.fetch(request);
  },
};

FROM node:20-bookworm-slim

WORKDIR /app

# 1. Install gpg, curl, ca-certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gpg ca-certificates procps && \
    rm -rf /var/lib/apt/lists/*

# 2. Pasang GPG key & repo resmi Cloudflare WARP
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ bookworm main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends cloudflare-warp && \
    rm -rf /var/lib/apt/lists/*

# Langsung copy file aplikasi tanpa npm install
COPY . .

ENV PORT=8080
ENV PROXY_PORT=8081

EXPOSE 8080 8081

# Jalankan daemon WARP, konek proxy port 40000, lalu jalankan server.js
CMD ["sh", "-c", "warp-svc & sleep 3 && (warp-cli --accept-tos register 2>/dev/null || warp-cli --accept-tos registration new 2>/dev/null || true) && (warp-cli --accept-tos set-mode proxy 2>/dev/null || warp-cli --accept-tos mode proxy 2>/dev/null || true) && (warp-cli --accept-tos set-proxy-port 40000 2>/dev/null || warp-cli --accept-tos proxy port 40000 2>/dev/null || true) && warp-cli --accept-tos connect && sleep 2 && node server.js"]

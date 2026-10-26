# ---- deps: install only production dependencies (cached separately from source changes) ----
FROM node:26-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# ---- runtime ----
FROM node:26-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app

# Run as a non-root, unprivileged user (required by the restricted Pod
# Security Standard applied to the platform-* namespaces).
RUN addgroup -S app && adduser -S app -G app

# The base image bundles the global npm CLI (and its own vendored
# dependencies, e.g. tar/minimatch/cross-spawn) under
# /usr/local/lib/node_modules/npm - none of that is needed at runtime since
# this container only ever runs `node src/index.js`. Removing it shrinks the
# image and eliminates a recurring source of HIGH/CRITICAL CVEs reported by
# Trivy against packages the app never actually executes.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack \
    /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
    /opt/yarn* 2>/dev/null || true

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src

USER app
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:3000/healthz', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "src/index.js"]

# build
FROM node:20.11-alpine3.18 AS build

WORKDIR /app

COPY ./package.json ./pnpm-lock.yaml ./pnpm-workspace.yaml ./
COPY ./patches/ ./patches/
RUN corepack enable
RUN corepack prepare --activate
RUN pnpm install --production --frozen-lockfile

# runtime
FROM node:20.11-alpine3.18 AS runtime

RUN apk add --no-cache dumb-init

WORKDIR /app

COPY ./index.js ./
COPY --from=build /app/node_modules/ ./node_modules/

EXPOSE 3000
ENV PDS_PORT=3000
ENV NODE_ENV=production
ENV UV_USE_IO_URING=0

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "--enable-source-maps", "index.js"]
# BLKOUT: container build for Coolify on the Manchester VPS (not part of upstream SignuDoc).
# Files live on the /data volume; the database is the Coolify Postgres given in DATABASE_URL.
FROM node:24-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:24-slim
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 STORAGE_DRIVER=local STORAGE_LOCAL_DIR=/data/storage
COPY --from=build /app ./
RUN mkdir -p /data/storage && chown -R node:node /data /app
USER node
EXPOSE 3000
# Apply any new database migrations, then start.
CMD ["sh", "-c", "npm run db:migrate && npm run start"]

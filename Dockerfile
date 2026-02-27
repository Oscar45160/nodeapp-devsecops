# Stage 1: Build
FROM node:20-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Production
FROM node:20-alpine

WORKDIR /app

# Copy necessary files from build stage
COPY --from=build /app/node_modules ./node_modules
COPY app.js .
COPY package.json .

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Remove npm and other unnecessary tools to reduce attack surface and fix vulnerabilities
RUN rm -rf /usr/local/lib/node_modules/npm \
  && rm -rf /usr/local/bin/npm \
  && rm -rf /usr/local/bin/npx

USER appuser

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]

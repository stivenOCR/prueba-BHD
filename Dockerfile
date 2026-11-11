# ==============================================================================
# Etapa 1: Build y dependencias
# ==============================================================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

# ==============================================================================
# Etapa 2: Imagen final para producción (ligera y segura)
# ==============================================================================
FROM node:20-alpine

# Buenas prácticas de seguridad: ejecutar como usuario no-root
USER node

WORKDIR /home/node/app

# Copiar dependencias de producción y código de la app
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node src/ ./src/

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Healthcheck nativo de Docker
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]


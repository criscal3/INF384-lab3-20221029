# ---------- Etapa 1: build ----------
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# Manifiesto y lock file copiados e instalados ANTES del código de la app
COPY package.json package-lock.json ./
RUN npm ci

# Solo el código fuente necesario para el build (no infra/, no test/)
COPY src ./src

# esbuild (devDependency) empaqueta el handler y sus dependencias en dist/handler.js
RUN npm run build

# ---------- Etapa 2: final ----------
FROM public.ecr.aws/lambda/nodejs:20

WORKDIR /var/task

# Solo el artefacto empaquetado
COPY --from=build /build/dist/handler.js ./

CMD ["handler.handler"]

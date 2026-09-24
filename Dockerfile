# ---------- Etapa 1: build ----------
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# Manifiesto y lock file copiados e instalados ANTES del código de la app
COPY package.json package-lock.json ./
RUN npm ci

# Solo el código fuente necesario para el build (no infra/, no test/)
COPY src ./src

### NO TOCAR DE ACA EN ADELANTE, CONSIDEREN QUE EL WORKDIR DEBE SER /build
RUN npx esbuild src/handler.js \
      --bundle --platform=node --target=node20 \
      --outfile=dist/handler.js

# Etapa final: recibe unicamente el artefacto empaquetado.
# El arbol de node_modules se queda en la etapa anterior.
FROM public.ecr.aws/lambda/nodejs:20 AS runtime
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/
CMD ["handler.handler"]

# syntax=docker/dockerfile:1

# ================================
# Stage 1: Build Flutter Web
# ================================
FROM ghcr.io/cirruslabs/flutter:3.32.8 AS build
WORKDIR /app

COPY . .

ARG API_BASE_URL=http://localhost:8081
RUN flutter pub get
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ================================
# Stage 2: Serve with Nginx
# ================================
FROM nginx:alpine
RUN apk add --no-cache curl

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

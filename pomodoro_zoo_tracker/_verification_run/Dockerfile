# Build stage: compile Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache dependencies first for faster rebuilds
COPY pubspec.yaml pubspec.lock ./
RUN flutter config --enable-web && flutter pub get

# Copy source and build
COPY . .
RUN flutter build web --release

# Runtime stage: serve static files with nginx
FROM nginx:1.27-alpine AS runtime

# Configure SPA fallback so deep links resolve to index.html
RUN printf '%s\n' \
  'server {' \
  '  listen 80;' \
  '  server_name _;' \
  '  root /usr/share/nginx/html;' \
  '  index index.html;' \
  '' \
  '  location / {' \
  '    try_files $uri $uri/ /index.html;' \
  '  }' \
  '' \
  '  location /assets/ {' \
  '    expires 1y;' \
  '    add_header Cache-Control "public, immutable";' \
  '  }' \
  '}' > /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

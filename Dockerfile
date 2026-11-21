FROM nginx:alpine

LABEL org.opencontainers.image.title="codyssey-dev-station" \
      org.opencontainers.image.description="Codyssey All-in-One admission mission web server" \
      org.opencontainers.image.source="local-assignment"

ENV APP_ENV=dev

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/

RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1

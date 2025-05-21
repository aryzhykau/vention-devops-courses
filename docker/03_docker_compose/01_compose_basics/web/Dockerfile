FROM nginx:alpine

# Метаданные об образе
LABEL maintainer="DevOps Course Team"
LABEL description="Simple Nginx web server for Docker Compose basics"

# Копируем основной конфиг nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Копируем статические файлы
COPY index.html /usr/share/nginx/html/

# Проверка работоспособности
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Запускаем Nginx в режиме без демонизации
CMD ["nginx", "-g", "daemon off;"] 
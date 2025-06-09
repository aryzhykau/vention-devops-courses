#!/bin/bash

# Этот скрипт настраивает окружение для задания по траблшутингу Nginx.
# Он устанавливает Nginx (если его нет), создает некорректный конфиг файл
# и включает его в основную конфигурацию Nginx, чтобы вызвать ошибку запуска.

# Проверяем, запущен ли скрипт от root
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script as root (use sudo)."
  exit 1
fi

# 1. Установка Nginx (если еще не установлен)
echo "Checking and installing Nginx..."
if ! command -v nginx &> /dev/null
then
    echo "Nginx not found. Installing Nginx..."
    apt update
    apt install -y nginx
    if [ $? -ne 0 ]; then
        echo "Error installing Nginx. Exiting."
        exit 1
    fi
    echo "Nginx installed successfully."
else
    echo "Nginx is already installed."
fi

# Останавливаем Nginx на время настройки, если он запущен
systemctl stop nginx 2>/dev/null

# 2. Создание директории для проблемного конфига
TROUBLE_DIR="/opt/system_config_data"
INVALID_CONFIG="$TROUBLE_DIR/web_service_config"
NGINX_MAIN_CONFIG="/etc/nginx/nginx.conf"
NGINX_MAIN_CONFIG_BACKUP="$NGINX_MAIN_CONFIG.bak"

mkdir -p $TROUBLE_DIR

# 3. Создание некорректного конфиг файла
echo "Creating invalid configuration file: $INVALID_CONFIG"
cat <<EOF > $INVALID_CONFIG
server {
    listen 80;
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
    # This line has a syntax error - missing semicolon
    error_page 404 /404.html
}
EOF

# Делаем бэкап основного конфига, если его еще нет
if [ ! -f "$NGINX_MAIN_CONFIG_BACKUP" ]; then
    cp $NGINX_MAIN_CONFIG $NGINX_MAIN_CONFIG_BACKUP
    echo "Main config backup created: $NGINX_MAIN_CONFIG_BACKUP"
fi

# Добавляем строку включения после строки 12 (где предположительно начинается http {)
sed -i '12a\
    # Included file for troubleshooting task\
    include '$INVALID_CONFIG';' $NGINX_MAIN_CONFIG

# Проверяем, успешно ли прошла вставка
if [ $? -ne 0 ]; then
    echo "Error inserting include directive into $NGINX_MAIN_CONFIG. Exiting."
    exit 1
fi

# 5. Проверка синтаксиса и попытка запуска Nginx
echo "Attempting to check Nginx syntax and start service..."
nginx -t

echo "\nNginx configuration syntax check result above (error expected).\n"

echo "Script finished. The student now needs to find and fix the problem!" 
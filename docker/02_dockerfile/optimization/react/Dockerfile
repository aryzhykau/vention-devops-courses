# Используем большой образ с полной установкой Node.js
FROM node:16

# Создаем рабочую директорию
WORKDIR /app

# Установка глобальных пакетов, не все из которых нужны
RUN npm install -g npm@8 create-react-app nodemon typescript

# Копируем весь проект, включая node_modules если они есть локально
COPY . .

# Устанавливаем все зависимости (включая devDependencies)
RUN npm install

# Скачиваем дополнительные пакеты, которые не нужны в production
RUN npm install --save-dev eslint-plugin-react jest-dom @types/react

# Собираем приложение в production-режиме
RUN npm run build

# Устанавливаем веб-сервер для раздачи статических файлов
RUN npm install -g serve

# Открываем порт для веб-сервера
EXPOSE 3000

# Запускаем веб-сервер для раздачи статических файлов
CMD ["serve", "-s", "build", "-l", "3000"] 
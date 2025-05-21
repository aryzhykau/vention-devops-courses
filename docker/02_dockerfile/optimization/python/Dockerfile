# Используем полный образ Python вместо slim или alpine
FROM python:3.9

# Установка дополнительных утилит, которые на самом деле не требуются
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    iputils-ping \
    telnet \
    curl \
    htop \
    wget \
    git

# Копирование всего содержимого директории вместо отдельных файлов
WORKDIR /app
COPY . .

# Установка зависимостей без использования --no-cache-dir и с лишними пакетами разработки
RUN pip install -r requirements.txt

# Открываем для контейнера порт
EXPOSE 5000

# Запускаем приложение с root-правами
CMD ["python", "app.py"] 
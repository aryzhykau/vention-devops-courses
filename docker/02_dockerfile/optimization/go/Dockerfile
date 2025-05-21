# Используем полный образ для разработки
FROM golang:1.18-bullseye

# Устанавливаем дополнительные инструменты, не все из которых нужны для production
RUN apt-get update && apt-get install -y \
    vim \
    git \
    curl \
    wget \
    net-tools \
    iputils-ping

# Устанавливаем отладочные инструменты для Go
RUN go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/ramya-rao-a/go-outline@latest

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем исходный код
COPY . .

# Собираем приложение без оптимизаций и в режиме отладки
RUN go build -o main .

# Открываем порт для нашего приложения
EXPOSE 8080

# Запускаем приложение
CMD ["./main"] 
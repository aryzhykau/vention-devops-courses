# Используем полный образ .NET SDK с большим количеством инструментов
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Устанавливаем дополнительные инструменты для разработки
RUN apt-get update && apt-get install -y \
    vim \
    git \
    curl \
    wget \
    htop \
    unzip \
    procps

# Устанавливаем глобальные инструменты .NET
RUN dotnet tool install --global dotnet-ef
RUN dotnet tool install --global dotnet-trace
RUN dotnet tool install --global dotnet-counters

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем весь проект целиком
COPY . .

# Восстанавливаем зависимости
RUN dotnet restore

# Публикуем приложение с отладочной информацией
RUN dotnet publish -c Debug -o /app/publish

# Устанавливаем переменные окружения для отладки
ENV ASPNETCORE_ENVIRONMENT=Development
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV ASPNETCORE_URLS=http://+:80;https://+:443

# Открываем порты
EXPOSE 80 443

# Запускаем приложение с отладочными параметрами
CMD ["dotnet", "watch", "run", "--urls", "http://+:80;https://+:443"] 
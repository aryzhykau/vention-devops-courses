# Задание 1: Основы Docker

В этом задании вы познакомитесь с основными концепциями Docker, научитесь запускать контейнеры, исследовать образы и взаимодействовать с Docker Hub.

## Цель задания

Освоить базовые команды Docker, понять концепции контейнеров и образов, научиться запускать и управлять контейнерами.

## Предварительные требования

- Установленный Docker Engine (инструкции по установке: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/))
- Доступ к терминалу
- Доступ в интернет для загрузки образов

## Задачи

### 1. Проверка установки Docker

```bash
# Проверьте версию Docker
docker --version

# Проверьте, что демон Docker запущен
docker info
```

### 2. Запуск первого контейнера

```bash
# Запустите контейнер с образом hello-world
docker run hello-world
```

Объясните, что произошло при выполнении этой команды. Какие этапы выполнил Docker?

### 3. Работа с контейнерами

```bash
# Запустите контейнер nginx в фоновом режиме с проброшенным портом
docker run -d -p 8080:80 --name my-nginx nginx

# Проверьте, что контейнер запущен
docker ps

# Проверьте доступность веб-сервера
# В браузере откройте http://localhost:8080 или используйте curl:
curl http://localhost:8080
```

Выполните следующие действия:
- Просмотрите логи контейнера
- Остановите контейнер
- Запустите его снова
- Удалите контейнер

Запишите использованные команды и их результаты.

### 4. Исследование образов

```bash
# Посмотрите список локальных образов
docker images

# Изучите информацию об образе nginx
docker inspect nginx
```

Найдите и запишите:
- Размер образа nginx
- Архитектуру образа
- Слои, из которых состоит образ

### 5. Запуск интерактивных контейнеров

```bash
# Запустите Ubuntu контейнер в интерактивном режиме
docker run -it --name ubuntu-container ubuntu:latest bash
```

Внутри контейнера выполните:
- Обновление списка пакетов (`apt update`)
- Установку пакета (`apt install -y curl`)
- Проверку IP-адреса контейнера (`ip addr` или `hostname -i`)

Выйдите из контейнера (команда `exit`), затем:
- Запустите его снова и подключитесь к нему
- Проверьте, сохранились ли установленные пакеты

### 6. Работа с Docker Hub

- Зарегистрируйтесь на [Docker Hub](https://hub.docker.com/)
- Найдите официальный образ PostgreSQL
- Изучите документацию по его использованию
- Запустите контейнер PostgreSQL с заданными переменными окружения

## Дополнительные задачи

1. Запустите несколько контейнеров из разных образов одновременно.
2. Изучите параметр `--rm` при запуске контейнеров. В чем его преимущества?
3. Исследуйте режимы сети в Docker: bridge, host, none. Запустите контейнеры в разных режимах и сравните их.

## Результаты

В результате выполнения задания вы должны:
- Уметь запускать, останавливать и удалять контейнеры
- Понимать разницу между образами и контейнерами
- Знать базовые команды для взаимодействия с Docker
- Уметь работать с Docker Hub

---

# Assignment 1: Docker Basics

In this assignment, you will familiarize yourself with basic Docker concepts, learn to run containers, explore images, and interact with Docker Hub.

## Assignment Goal

Master basic Docker commands, understand the concepts of containers and images, learn to run and manage containers.

## Prerequisites

- Installed Docker Engine (installation instructions: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/))
- Terminal access
- Internet access for downloading images

## Tasks

### 1. Verifying Docker Installation

```bash
# Check Docker version
docker --version

# Verify that the Docker daemon is running
docker info
```

### 2. Running Your First Container

```bash
# Run a container with the hello-world image
docker run hello-world
```

Explain what happened when you executed this command. What steps did Docker perform?

### 3. Working with Containers

```bash
# Run an nginx container in the background with a mapped port
docker run -d -p 8080:80 --name my-nginx nginx

# Check that the container is running
docker ps

# Verify web server accessibility
# Open http://localhost:8080 in your browser or use curl:
curl http://localhost:8080
```

Perform the following actions:
- View container logs
- Stop the container
- Start it again
- Delete the container

Record the commands used and their results.

### 4. Exploring Images

```bash
# View the list of local images
docker images

# Examine information about the nginx image
docker inspect nginx
```

Find and record:
- The size of the nginx image
- The architecture of the image
- The layers that make up the image

### 5. Running Interactive Containers

```bash
# Run an Ubuntu container in interactive mode
docker run -it --name ubuntu-container ubuntu:latest bash
```

Inside the container, perform:
- Update the package list (`apt update`)
- Install a package (`apt install -y curl`)
- Check the container's IP address (`ip addr` or `hostname -i`)

Exit the container (command `exit`), then:
- Start it again and connect to it
- Check if the installed packages were preserved

### 6. Working with Docker Hub

- Register on [Docker Hub](https://hub.docker.com/)
- Find the official PostgreSQL image
- Study the documentation on its usage
- Run a PostgreSQL container with specified environment variables

## Additional Tasks

1. Run several containers from different images simultaneously.
2. Study the `--rm` parameter when running containers. What are its advantages?
3. Explore Docker network modes: bridge, host, none. Run containers in different modes and compare them.

## Results

Upon completing the assignment, you should be able to:
- Run, stop, and delete containers
- Understand the difference between images and containers
- Know basic commands for interacting with Docker
- Be able to work with Docker Hub 
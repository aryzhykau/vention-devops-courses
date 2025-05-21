# Задание 2: Создание Docker-образов с помощью Dockerfile

В этом задании вы научитесь создавать собственные Docker-образы, используя Dockerfile, познакомитесь с лучшими практиками и принципами многоэтапных сборок.

## Цель задания

Освоить создание Docker-образов с использованием Dockerfile, понять концепции слоев и кэширования, научиться минимизировать размер образов.

## Предварительные требования

- Установленный Docker Engine
- Опыт выполнения базовых команд Docker (из предыдущего задания)
- Базовые знания Linux-команд
- Текстовый редактор для создания файлов

## Часть 1: Создание простых Docker-образов

В этой части вы создадите простые Docker-образы для различных приложений, следуя инструкциям из задания.

## Часть 2: Оптимизация Docker-образов

В подкаталоге `optimization/` вы найдете несколько неоптимизированных Dockerfile для различных типов приложений. Ваша задача - оптимизировать их, применяя лучшие практики.

Подробные инструкции по заданиям на оптимизацию находятся в файле [optimization/README.md](./optimization/README.md).

## Задачи

### 1. Создание простого Dockerfile

Создайте простой Dockerfile для статического веб-приложения:

1. Создайте директорию для проекта и перейдите в неё:
   ```bash
   mkdir -p my-web-app
   cd my-web-app
   ```

2. Создайте HTML-файл `index.html`:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Docker Test</title>
       <style>
           body {
               background-color: #f0f0f0;
               font-family: Arial, sans-serif;
               text-align: center;
               padding-top: 100px;
           }
           h1 {
               color: #333;
           }
       </style>
   </head>
   <body>
       <h1>Мой первый Docker-образ!</h1>
       <p>Это простое веб-приложение, развернутое в контейнере.</p>
   </body>
   </html>
   ```

3. Создайте файл `Dockerfile`:
   ```Dockerfile
   FROM nginx:alpine
   COPY index.html /usr/share/nginx/html/
   ```

4. Соберите образ и запустите контейнер:
   ```bash
   docker build -t my-web-app:v1 .
   docker run -d -p 8080:80 --name my-web-app my-web-app:v1
   ```

5. Проверьте работу приложения, открыв в браузере http://localhost:8080

### 2. Оптимизация Dockerfile

Теперь создайте более сложное приложение на Python и оптимизируйте Dockerfile:

1. Создайте новую директорию:
   ```bash
   mkdir -p python-app
   cd python-app
   ```

2. Создайте простое Flask-приложение - файл `app.py`:
   ```python
   from flask import Flask
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       return "Привет от Python приложения в Docker!"
   
   if __name__ == "__main__":
       app.run(host='0.0.0.0', port=5000)
   ```

3. Создайте файл `requirements.txt`:
   ```
   flask==2.0.1
   ```

4. Создайте неоптимизированный `Dockerfile.bad`:
   ```Dockerfile
   FROM python:3.9
   
   WORKDIR /app
   
   COPY app.py .
   COPY requirements.txt .
   
   RUN pip install -r requirements.txt
   
   EXPOSE 5000
   
   CMD ["python", "app.py"]
   ```

5. Соберите образ и обратите внимание на его размер:
   ```bash
   docker build -t python-app:bad -f Dockerfile.bad .
   docker images python-app:bad
   ```

6. Создайте оптимизированный `Dockerfile.good`:
   ```Dockerfile
   FROM python:3.9-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY app.py .
   
   EXPOSE 5000
   
   USER nobody
   
   CMD ["python", "app.py"]
   ```

7. Соберите новый образ и сравните размеры:
   ```bash
   docker build -t python-app:good -f Dockerfile.good .
   docker images python-app:good
   ```

8. Запустите приложение из оптимизированного образа:
   ```bash
   docker run -d -p 5000:5000 --name python-app python-app:good
   ```

### 3. Многоэтапная сборка

Создайте многоэтапную сборку для Go-приложения:

1. Создайте директорию:
   ```bash
   mkdir -p go-app
   cd go-app
   ```

2. Создайте простое Go-приложение - файл `main.go`:
   ```go
   package main
   
   import (
       "fmt"
       "net/http"
   )
   
   func handler(w http.ResponseWriter, r *http.Request) {
       fmt.Fprintf(w, "Привет от Go-приложения в Docker!")
   }
   
   func main() {
       http.HandleFunc("/", handler)
       fmt.Println("Сервер запущен на порту 8080")
       http.ListenAndServe(":8080", nil)
   }
   ```

3. Создайте многоэтапный `Dockerfile`:
   ```Dockerfile
   # Этап сборки
   FROM golang:1.17 AS builder
   
   WORKDIR /app
   
   COPY main.go .
   
   RUN CGO_ENABLED=0 GOOS=linux go build -o app main.go
   
   # Финальный этап
   FROM alpine:3.14
   
   WORKDIR /app
   
   COPY --from=builder /app/app .
   
   EXPOSE 8080
   
   CMD ["./app"]
   ```

4. Соберите и запустите:
   ```bash
   docker build -t go-app:v1 .
   docker run -d -p 8080:8080 --name go-app go-app:v1
   ```

5. Проверьте работу приложения: http://localhost:8080

### 4. Создание и публикация собственного образа

1. Создайте учетную запись на Docker Hub (если еще нет)
2. Войдите в Docker Hub из командной строки:
   ```bash
   docker login
   ```

3. Тегируйте ваш образ согласно требованиям Docker Hub:
   ```bash
   docker tag go-app:v1 username/go-app:v1
   ```

4. Опубликуйте образ:
   ```bash
   docker push username/go-app:v1
   ```

## Дополнительные задачи

1. Используйте .dockerignore для исключения ненужных файлов при сборке образа.
2. Создайте образ, используя сжатый дистрибутив Alpine Linux, и сравните его с аналогичным образом на основе Ubuntu.
3. Исследуйте возможности инструкции HEALTHCHECK и добавьте проверку здоровья в один из ваших образов.
4. Создайте многоэтапную сборку для Node.js приложения с фронтендом (например, React).

## Результаты

В результате выполнения задания вы должны:
- Уметь создавать базовые Dockerfile
- Понимать принципы оптимизации Docker-образов
- Знать, как использовать многоэтапные сборки для минимизации размера
- Уметь публиковать образы в Docker Hub

---

# Assignment 2: Creating Docker Images with Dockerfile

In this assignment, you will learn to create your own Docker images using Dockerfile, understand best practices, and learn the principles of multi-stage builds.

## Assignment Goal

Master the creation of Docker images using Dockerfile, understand the concepts of layers and caching, learn to minimize image size.

## Prerequisites

- Installed Docker Engine
- Experience with basic Docker commands (from the previous assignment)
- Basic knowledge of Linux commands
- Text editor for creating files

## Part 1: Creating Simple Docker Images

In this part, you will create simple Docker images for various applications, following the instructions from the assignment.

## Part 2: Docker Image Optimization

In the `optimization/` subdirectory, you will find several unoptimized Dockerfiles for various types of applications. Your task is to optimize them, applying the best practices.

Detailed instructions for optimization tasks are located in the [optimization/README.md](./optimization/README.md) file.

## Tasks

### 1. Creating a Simple Dockerfile

Create a simple Dockerfile for a static web application:

1. Create a directory for the project and navigate to it:
   ```bash
   mkdir -p my-web-app
   cd my-web-app
   ```

2. Create an HTML file `index.html`:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Docker Test</title>
       <style>
           body {
               background-color: #f0f0f0;
               font-family: Arial, sans-serif;
               text-align: center;
               padding-top: 100px;
           }
           h1 {
               color: #333;
           }
       </style>
   </head>
   <body>
       <h1>My First Docker Image!</h1>
       <p>This is a simple web application deployed in a container.</p>
   </body>
   </html>
   ```

3. Create a `Dockerfile`:
   ```Dockerfile
   FROM nginx:alpine
   COPY index.html /usr/share/nginx/html/
   ```

4. Build the image and run the container:
   ```bash
   docker build -t my-web-app:v1 .
   docker run -d -p 8080:80 --name my-web-app my-web-app:v1
   ```

5. Check the application by opening http://localhost:8080 in your browser

### 2. Dockerfile Optimization

Now create a more complex Python application and optimize the Dockerfile:

1. Create a new directory:
   ```bash
   mkdir -p python-app
   cd python-app
   ```

2. Create a simple Flask application - file `app.py`:
   ```python
   from flask import Flask
   app = Flask(__name__)
   
   @app.route('/')
   def hello():
       return "Hello from a Python app in Docker!"
   
   if __name__ == "__main__":
       app.run(host='0.0.0.0', port=5000)
   ```

3. Create a `requirements.txt` file:
   ```
   flask==2.0.1
   ```

4. Create an unoptimized `Dockerfile.bad`:
   ```Dockerfile
   FROM python:3.9
   
   WORKDIR /app
   
   COPY app.py .
   COPY requirements.txt .
   
   RUN pip install -r requirements.txt
   
   EXPOSE 5000
   
   CMD ["python", "app.py"]
   ```

5. Build the image and note its size:
   ```bash
   docker build -t python-app:bad -f Dockerfile.bad .
   docker images python-app:bad
   ```

6. Create an optimized `Dockerfile.good`:
   ```Dockerfile
   FROM python:3.9-slim
   
   WORKDIR /app
   
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   
   COPY app.py .
   
   EXPOSE 5000
   
   USER nobody
   
   CMD ["python", "app.py"]
   ```

7. Build the new image and compare sizes:
   ```bash
   docker build -t python-app:good -f Dockerfile.good .
   docker images python-app:good
   ```

8. Run the application from the optimized image:
   ```bash
   docker run -d -p 5000:5000 --name python-app python-app:good
   ```

### 3. Multi-Stage Build

Create a multi-stage build for a Go application:

1. Create a directory:
   ```bash
   mkdir -p go-app
   cd go-app
   ```

2. Create a simple Go application - file `main.go`:
   ```go
   package main
   
   import (
       "fmt"
       "net/http"
   )
   
   func handler(w http.ResponseWriter, r *http.Request) {
       fmt.Fprintf(w, "Hello from a Go app in Docker!")
   }
   
   func main() {
       http.HandleFunc("/", handler)
       fmt.Println("Server started on port 8080")
       http.ListenAndServe(":8080", nil)
   }
   ```

3. Create a multi-stage `Dockerfile`:
   ```Dockerfile
   # Build stage
   FROM golang:1.17 AS builder
   
   WORKDIR /app
   
   COPY main.go .
   
   RUN CGO_ENABLED=0 GOOS=linux go build -o app main.go
   
   # Final stage
   FROM alpine:3.14
   
   WORKDIR /app
   
   COPY --from=builder /app/app .
   
   EXPOSE 8080
   
   CMD ["./app"]
   ```

4. Build and run:
   ```bash
   docker build -t go-app:v1 .
   docker run -d -p 8080:8080 --name go-app go-app:v1
   ```

5. Check the application: http://localhost:8080

### 4. Creating and Publishing Your Own Image

1. Create a Docker Hub account (if you don't have one)
2. Log in to Docker Hub from the command line:
   ```bash
   docker login
   ```

3. Tag your image according to Docker Hub requirements:
   ```bash
   docker tag go-app:v1 username/go-app:v1
   ```

4. Publish the image:
   ```bash
   docker push username/go-app:v1
   ```

## Additional Tasks

1. Use .dockerignore to exclude unnecessary files when building the image.
2. Create an image using the compressed Alpine Linux distribution and compare it with a similar image based on Ubuntu.
3. Explore the capabilities of the HEALTHCHECK instruction and add a health check to one of your images.
4. Create a multi-stage build for a Node.js application with a frontend (e.g., React).

## Results

Upon completing the assignment, you should be able to:
- Create basic Dockerfiles
- Understand Docker image optimization principles
- Know how to use multi-stage builds to minimize size
- Know how to publish images to Docker Hub 
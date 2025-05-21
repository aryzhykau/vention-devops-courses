# Задания по оптимизации Dockerfile

В этом разделе вы найдете несколько приложений на разных языках программирования с **неоптимальными** Dockerfile. Ваша задача - оптимизировать их, применив лучшие практики построения Docker-образов.

## Цель заданий

Для каждого приложения вам необходимо:

1. Изучить исходный Dockerfile и найти проблемы и неоптимальные решения
2. Создать новый, оптимизированный Dockerfile, который:
   - Минимизирует размер финального образа
   - Ускоряет процесс сборки
   - Улучшает безопасность образа
   - Следует лучшим практикам

## Как выполнить задания

1. Склонируйте репозиторий в свою локальную среду
2. Создайте новую ветку с именем `student/ваше_имя`
3. Для каждого приложения создайте новый файл `Dockerfile.optimized`
4. Соберите оба образа (оригинальный и оптимизированный) и сравните их:
   ```bash
   # Пример для Python-приложения
   cd docker/02_dockerfile/optimization/python
   
   # Сборка оригинального образа
   docker build -t python-app:original -f Dockerfile .
   
   # Сборка вашего оптимизированного образа
   docker build -t python-app:optimized -f Dockerfile.optimized .
   
   # Сравнение размера образов
   docker images | grep python-app
   ```
5. Запустите оба контейнера и убедитесь, что приложения работают одинаково
6. Создайте файл `REPORT.md` в каждой директории приложения, в котором опишите:
   - Найденные проблемы
   - Предложенные решения
   - Сравнение размера и безопасности исходного и оптимизированного образов
   - Другие улучшения, которые вы применили
7. Закоммитьте изменения в вашу ветку и создайте pull request

## Список приложений для оптимизации

В каждой директории находится простое приложение с неоптимальным Dockerfile:

1. **python/** - Flask-приложение с неоптимальным базовым образом и порядком слоев
2. **react/** - JavaScript/React приложение с проблемами кэширования и лишними зависимостями
3. **java/** - Java Spring Boot приложение с проблемами в многоэтапной сборке
4. **go/** - Golang приложение с избыточным размером образа
5. **csharp/** - .NET приложение с проблемами в структуре слоев и кэширования

## Критерии оценки

Ваша работа будет оцениваться по следующим критериям:

1. Размер оптимизированного образа по сравнению с исходным
2. Использование правильного базового образа
3. Оптимальная организация слоев для эффективного кэширования
4. Удаление ненужных инструментов разработки из финальных образов
5. Применение многоэтапных сборок (где применимо)
6. Внедрение практик безопасности (непривилегированные пользователи, сканирование уязвимостей и т.д.)
7. Документирование изменений и объяснение решений

## Дополнительные ресурсы

Перед выполнением заданий рекомендуется ознакомиться со следующими ресурсами:

- [Docker documentation: Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker optimization cheat sheet](https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)

---

# Docker Optimization Assignments

In this section, you will find several applications in different programming languages with **non-optimized** Dockerfiles. Your task is to optimize them by applying Docker image building best practices.

## Goal of the Assignments

For each application, you need to:

1. Study the original Dockerfile and identify problems and suboptimal solutions
2. Create a new, optimized Dockerfile that:
   - Minimizes the size of the final image
   - Speeds up the build process
   - Improves image security
   - Follows best practices

## How to Complete the Assignments

1. Clone the repository to your local environment
2. Create a new branch named `student/your_name`
3. For each application, create a new file `Dockerfile.optimized`
4. Build both images (original and optimized) and compare them:
   ```bash
   # Example for Python application
   cd docker/02_dockerfile/optimization/python
   
   # Build the original image
   docker build -t python-app:original -f Dockerfile .
   
   # Build your optimized image
   docker build -t python-app:optimized -f Dockerfile.optimized .
   
   # Compare image sizes
   docker images | grep python-app
   ```
5. Run both containers and make sure the applications work the same
6. Create a `REPORT.md` file in each application directory, describing:
   - Problems found
   - Solutions proposed
   - Comparison of size and security of original and optimized images
   - Other improvements you applied
7. Commit your changes to your branch and create a pull request

## List of Applications to Optimize

Each directory contains a simple application with a non-optimized Dockerfile:

1. **python/** - Flask application with a non-optimal base image and layer ordering
2. **react/** - JavaScript/React application with caching issues and unnecessary dependencies
3. **java/** - Java Spring Boot application with multi-stage build issues
4. **go/** - Golang application with excessive image size
5. **csharp/** - .NET application with layer structure and caching issues

## Evaluation Criteria

Your work will be evaluated based on the following criteria:

1. Size of the optimized image compared to the original
2. Use of the appropriate base image
3. Optimal layer organization for efficient caching
4. Removal of unnecessary development tools from final images
5. Application of multi-stage builds (where applicable)
6. Implementation of security practices (unprivileged users, vulnerability scanning, etc.)
7. Documentation of changes and explanation of decisions

## Additional Resources

Before completing the assignments, it is recommended to review the following resources:

- [Docker documentation: Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker optimization cheat sheet](https://blog.docker.com/2019/07/intro-guide-to-dockerfile-best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/) 
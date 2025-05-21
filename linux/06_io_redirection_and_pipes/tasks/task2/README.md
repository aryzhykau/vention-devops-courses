# Задача 2: Конвейеры и Фильтры

## Описание
В этом задании вы научитесь использовать конвейеры (pipes) для соединения команд и работать с текстовыми фильтрами в Linux для обработки данных.

### Подготовка
Скрипт `setup.sh` создаст набор тестовых файлов с различными данными для практики использования конвейеров и фильтров.

### Задачи
1. Базовые конвейеры:
   - Используйте `ls -l | grep` для поиска файлов
   - Подсчитайте количество файлов в директории с помощью `wc`
   - Объедините несколько команд в цепочку с помощью pipe

2. Текстовые фильтры:
   - Отфильтруйте и отсортируйте содержимое лог-файла
   - Найдите уникальные записи с помощью `uniq`
   - Используйте `cut` и `awk` для извлечения конкретных полей

3. Сложные конвейеры:
   - Создайте конвейер из трех и более команд
   - Используйте `tee` для сохранения промежуточных результатов
   - Примените `sed` для замены текста в потоке

4. Обработка данных:
   - Проанализируйте системные логи с помощью конвейеров
   - Создайте статистику использования команд
   - Отфильтруйте и отформатируйте вывод команд

### Ожидаемые результаты
- Понимание концепции конвейеров в Linux
- Умение соединять команды для обработки данных
- Навыки использования текстовых фильтров
- Опыт создания сложных командных цепочек

### Очистка
После выполнения задания запустите скрипт `cleanup.sh` для удаления тестовых файлов и возврата системы в исходное состояние.

---

# Task 2: Pipes and Filters

## Description
In this task, you will learn to use pipes to connect commands and work with text filters in Linux for data processing.

### Preparation
The `setup.sh` script will create a set of test files with various data for practicing pipes and filters.

### Tasks
1. Basic pipes:
   - Use `ls -l | grep` to search for files
   - Count files in directory using `wc`
   - Combine multiple commands in a pipeline

2. Text filters:
   - Filter and sort log file contents
   - Find unique entries using `uniq`
   - Use `cut` and `awk` to extract specific fields

3. Complex pipelines:
   - Create a pipeline with three or more commands
   - Use `tee` to save intermediate results
   - Apply `sed` for text replacement in stream

4. Data processing:
   - Analyze system logs using pipelines
   - Create command usage statistics
   - Filter and format command output

### Expected Outcomes
- Understanding of pipes concept in Linux
- Ability to chain commands for data processing
- Skills in using text filters
- Experience in creating complex command chains

### Cleanup
After completing the task, run the `cleanup.sh` script to remove test files and return the system to its original state. 
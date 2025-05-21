|---------------------------------------------------------------------------------------------------|
| **Задание 6: Автоматизация скриптом**                                                           |
|                                                                                                   |
| - Создать пользователя `ci_user` без возможности входа (`/sbin/nologin`)                         |
| - Создать группу `ci_agents` и добавить `ci_user`                                                |
| - Создать `/var/ci` с правами `750`                                                             |
|                                                                                                   |
| **Скрипты:**                                                                                     |
| - `check.sh.x` - проверяет пользователя, группу и директорию                                      |
| - `cleanup.sh.x` - удаляет всё созданное                                                          |
|                                                                                                   |
| **Task 6: Automation with Script**                                                               |
|                                                                                                   |
| - Create `ci_user` with no login shell (`/sbin/nologin`)                                         |
| - Create group `ci_agents` and add `ci_user`                                                     |
| - Create `/var/ci` with `750` permissions                                                       |
|                                                                                                   |
| **Scripts:**                                                                                     |
| - `check.sh.x` - checks user, group, and directory                                                 |
| - `cleanup.sh.x` - removes all created items                                                       |
|---------------------------------------------------------------------------------------------------|

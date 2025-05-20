#!/bin/bash

# Удаление общей директории
rm -rf /shared/data

# Удаление пользователей
userdel -r userA
userdel -r userB

# Удаление группы
groupdel sharedgroup

echo "Среда для Сценария 4 очищена." 
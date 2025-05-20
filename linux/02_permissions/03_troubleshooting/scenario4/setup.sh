#!/bin/bash

# Создание группы и пользователей
groupadd sharedgroup
useradd -m -g sharedgroup userA
useradd -m -g sharedgroup userB

# Создание общей директории
mkdir /shared/data

# Установка владельца, группы и прав доступа
chown userA:sharedgroup /shared/data
chmod 770 /shared/data

echo "Среда для Сценария 4 настроена. Пользователи userA и userB являются членами sharedgroup и имеют права на чтение/запись в /shared/data, но без Sticky Bit." 
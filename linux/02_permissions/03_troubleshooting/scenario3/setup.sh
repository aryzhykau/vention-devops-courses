#!/bin/bash

# Создание пользователя testuser2
useradd testuser2

# Создание исполняемого файла
touch /usr/local/bin/my_script.sh
echo "#!/bin/bash
echo 'Hello from the script!'" > /usr/local/bin/my_script.sh
chmod u+x /usr/local/bin/my_script.sh

# Установка некорректных прав
chown root:root /usr/local/bin/my_script.sh
chmod 644 /usr/local/bin/my_script.sh

echo "Среда для Сценария 3 настроена. Пользователь testuser2 не сможет выполнить /usr/local/bin/my_script.sh" 
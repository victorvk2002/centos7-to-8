# Обновление centos7 на centos8

Локаль лучше поправить из оболочки юзера
```
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PYTHONIOENCODING=UTF-8
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
locale -a | grep -E "(en_US|ru_RU)"
echo 'export LANG=en_US.UTF-8' >> /etc/profile
echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile
source /etc/profile
locale
```

## Запуск

```
bash centos7-up-to-last.sh

reboot

# проверяем что загрузились с последнего ядра
```


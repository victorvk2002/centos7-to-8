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

Подготовка
```
curl -O https://vault.centos.org/centos/7/os/x86_64/Packages/wget-1.14-18.el7_6.1.x86_64.rpm
rpm -i wget-1.14-18.el7_6.1.x86_64.rpm
curl -O https://vault.centos.org/centos/7/os/x86_64/Packages/unzip-6.0-21.el7.x86_64.rpm
rpm -i unzip-6.0-21.el7.x86_64.rpm

wget https://github.com/victorvk2002/centos7-to-8/archive/refs/heads/main.zip
unzip main.zip
cd centos7-to-8-main
```

## Запуск

1. Меняем на правильные репозитарии и обновляем centos7 до последней версии
```
sudo bash centos7-up-to-last.sh
```
```
reboot
```
проверяем что загрузились с последнего ядра (3.10.0-1160.119.1.el7.x86_64)

2. Подставляем репозитарии centos8 и создаём новое ядро 4.18, меняем загрузчик
```
sudo bash centos7-to-8.sh
```
```
reboot
```
проверяем что загрузились с последнего ядра (4.18.0-348.7.1.el8_5.x86_64)

3. Обновляем centos8 до последней версии, решаем конфликты
```
sudo bash centos8-up-to-last.sh
```
стоит перезагрузиться и проверить что сеть точно поднимается

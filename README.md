# Vlashm_infra
Vlashm Infra repository
---
Домашнее задание #3

3.1 Прыжок через бастион на внутреннюю машину
ssh -i <KEY_FILE> -A <USER_BASTION>@<BASTION_IP> -t 'ssh <HOST_IP>'
или
ssh -i <KEY_FILE> -J <USER_BASTION>@<BASTION_IP> <USER_HOST>@<HOST_IP>

3.1* Подключение командой "ssh someinternalhost"
Надо настроить алиасы ssh. Для этого редактируем файл "~/.ssh/config" (если его нет, то создаем)

Host bastion
    Hostname BASTION_IP
    User USER_BASTION
    IdentityFile KEY_FILE
    ForwardAgent yes

Host someinternalhost
    Hostname HOST_IP
    User USER_HOST
    ProxyJump bastion

3.2 Реализация валидного сертификата для панели управления VPN сервера
Надо в настройках задать Lets Encrypt Domain 178.154.202.177.sslip.io

Бастион создан на Ubuntu 20.04  файл setupvpn.sh изменен для версии 20.04

bastion_IP = 178.154.202.177
someinternalhost_IP = 10.128.0.23

# Vlashm_infra
Vlashm Infra repository

## Домашнее задание 7

### 7.1 Удаленное хранилище для terraform.state

Сначала надо создать статический ключ доступа. Для этого выполнить команду

    yc iam access-key create --service-account-name <Имя_Сервисного_Аккаунта>

В переменную *storage_key* записать *key_id*, а в переменную *storage_secret* записать *secret*.
Развернуть *Object Storage* используя конфигурацию из файле *storage-bucket.tf*. Так же можно включить версионирование в бакете, для сохранения предыдущих версий *terraform.state*, добавив

    versioning {
        enabled = true
    }
для этого надо добавить сервисному аккаунту роль *storage.admin*. Можно еще включить шифрование на стороне сервера, чтобы данные шифровались при сохранении в *Object Storage*.

Для включения бекенда в директории stage(prod) в файле *backend.hcl* в переменную *access_key* записать *key_id*, а в переменную *secret_key* записать *secret* и выполнить

    terraform init -backend-config=backend.hcl

Теперь *terraform.state* будет сохраняться в облаке.

### 7.2 Добавление в модули provisioner

- В модули *app* и *dp* добавлены provisioner.
- Добавлена переменная *deploy* для включения provisioner по умолчанию равная *true*
- В модуль *dp* добавлен шаблон конфигурации *mongod*
- В модуль *app* добален шаблон сервиса *puma.service*. В переменную окружения *DATABASE_URL* подставляется адрес БД с использование *Terraform Data Sources*

## Домашнее задание 6
- Установлен Terraform
- Создана конфигурация виртуальных машин в Terraform
- Создан балансировщик нагрузки
- Добавлена возможность разворачивать указанное количество ВМ

Недостаток описания каждой ВМ в дублирование кода, что приводит к увеличению количества кода и возможному возникновению ошибок, также к сложности внесения изменений. Избежать этого помогает использование переменной *count*, позволяющей указывать количество необходимых ВМ.

 ## Домашнее задание 5
- Создан сервисный аккаунт и установлен Packer
- Создан конфигурационный файл *ubuntu16.json* и файл с переменными *variables.json*. Собран образ reddit-base на основе этих данных.
- Создан конфигурационный файл *immutable.json* для сборки образа reddit-full с уже запущенным приложением.
- В директории *config-scripts* добавлен скрипт *create-reddit-vm.sh* для сборки образа reddit-full и разворачивания ВМ на его основе



## Домашнее задание 4
Создан startup_script.sh, при запуске которого создается файл metadata.yml с конфигурацией ВМ и зупускается создание Вм командой:

    yc compute instance create \
    --name reddit-app \
    --hostname reddit-app \
    --memory=4 \
    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
    --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
    --metadata serial-port-enable=1 \
    --metadata-from-file user-data=./metadata.yml

testapp_IP = 51.250.70.112
testapp_port = 9292


## Домашнее задание 3

### 3.1 Прыжок через бастион на внутреннюю машину
    ssh -i <KEY_FILE> -A <USER_BASTION>@<BASTION_IP> -t 'ssh <HOST_IP>'
    или
    ssh -i <KEY_FILE> -J <USER_BASTION>@<BASTION_IP> <USER_HOST>@<HOST_IP>

### 3.1* Подключение командой "ssh someinternalhost"
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

### 3.2 Реализация валидного сертификата для панели управления VPN сервера
Надо в настройках задать Lets Encrypt Domain 178.154.202.177.sslip.io

Бастион создан на Ubuntu 20.04  файл setupvpn.sh изменен для версии 20.04

bastion_IP = 178.154.202.177
someinternalhost_IP = 10.128.0.23

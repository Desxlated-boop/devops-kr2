# Контрольная работа 2 Вариант 4

Ресурс: https://kv.devops.local, приложение слушает 8004 внутри контейнера.
На сервере опубликован только 127.0.0.1:8004. Redis не публикует порт.
Исходное приложение и зависимости шаблона сохранены; добавлен комментарий с фамилией.

## Доставка

Из WSL, из каталога проекта:

```sh
rsync -avz --delete --chmod=D755,F644 --exclude=.env --exclude=.git --dry-run ./ devops:kr2/
rsync -avz --delete --chmod=D755,F644 --exclude=.env --exclude=.git ./ devops:kr2/
```

На VM файл .env создан со случайным паролем openssl rand -hex 32, владельцем devops и правами 600.
Действующий пароль существует только на VM и явно передаётся обоим контейнерам через env_file.
Перед запуском не экспортировать REDIS_PASSWORD в оболочке.

```sh
cd ~/kr2
docker compose up -d --build
docker compose ps
docker compose top
docker compose port app 8004
docker compose exec redis redis-cli ping  # ожидается NOAUTH
```

Именованный том kr2_redis_data сохраняет данные после down. Флаг down -v не применялся.
Redis запускается штатной точкой входа, которая понижает привилегии до redis.
docker compose exec redis id показывает пользователя вспомогательного exec-процесса;
пользователя основного Redis проверять через compose top или /proc/1/status.

## Nginx и TLS

```sh
sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /etc/ssl/private/kr2.key -out /etc/ssl/certs/kr2.crt \
  -subj '/CN=kv.devops.local' -addext 'subjectAltName=DNS:kv.devops.local'
sudo chmod 600 /etc/ssl/private/kr2.key
sudo chown root:root /etc/ssl/private/kr2.key
sudo ln -s /etc/nginx/sites-available/kr2 /etc/nginx/sites-enabled/kr2
sudo nginx -t && sudo systemctl reload nginx
```

Конфигурация ресурса сохранена в nginx/kr2. Файл devops-site не изменён.
В Windows hosts добавлено 192.168.56.101 kv.devops.local.
Копируется только открытый сертификат: scp devops:/etc/ssl/certs/kr2.crt ~/kr2.crt.
Проверка: curl --cacert ~/kr2.crt https://kv.devops.local/whoami.
Kaspersky: адрес добавлен пользователем в исключения проверки защищённых соединений.

## Контроль

scripts/audit.sh содержит исходные 15 проверок ПР 5–7 и пять проверок КР2.
На VM итоговая версия также установлена в ~/devops-course-2026/scripts/audit.sh.
Нарушенная публикация 8004:8004 дала код 1, штатная 127.0.0.1:8004:8004 — код 0.
Правила UFW сверяются с ~/ufw-before-kr2.txt, секрет ищется по значению без вывода пароля.
Перед защитой создан снимок 07-kr2. Pull Request оставляется открытым до защиты.

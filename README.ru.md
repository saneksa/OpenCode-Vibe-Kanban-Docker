# OpenCode + Vibe-Kanban Docker образ

[简体中文](README.zh-CN.md) | [English](README.md) | Русский

Docker образ на базе Ubuntu 24.04 LTS с предустановленными OpenCode и Vibe-Kanban, а также соответствующими плагинами OpenCode.

## Возможности

- **OpenCode**: ИИ-агент для программирования с открытым исходным кодом
- **Claude Code**: ИИ-редактор кода от Claude (предустановлен)
- **Vibe-Kanban**: Инструмент для управления проектами
- **Docker**: Полноценный движок Docker с поддержкой Docker Compose (Docker-in-Docker)
- **SSH**: SSH-сервер для удаленного доступа
- **Языки программирования**: Предустановленные среды разработки
  - **Go**: Среда разработки Golang
  - **Rust**: Инструментарий Rust и пакетный менеджер cargo
  - **Node.js 20**: Установлен через репозиторий NodeSource
  - **Python 3**: Включает пакетный менеджер pip
  - **Conda**: Менеджер пакетов и сред (окружения хранятся в `/app/conda-env/`)
- **Git**: Система контроля версий
- **Инструменты сборки**: Набор инструментов build-essential

## Установленные плагины OpenCode

Следующие плагины установлены и готовы к использованию в OpenCode:

- **oh-my-opencode**: Улучшения для OpenCode ([GitHub](https://github.com/code-yeongyu/oh-my-opencode))
- **superpowers**: Суперсилы для OpenCode ([GitHub](https://github.com/obra/superpowers))
- **playwright-mcp**: MCP-сервер Playwright ([GitHub](https://github.com/microsoft/playwright-mcp))
- **agent-browser**: Агент-браузер ([GitHub](https://github.com/vercel-labs/agent-browser))
- **chrome-devtools-mcp**: MCP-сервер Chrome DevTools ([GitHub](https://github.com/ChromeDevTools/chrome-devtools-mcp))

## Проброс портов

| Порт | Сервис | Описание |
|------|---------|-------------|
| 2046 | OpenCode | Веб-сервер OpenCode |
| 3927 | Vibe-Kanban | Веб-интерфейс Vibe-Kanban |
| 2027 | Зарезервирован | Для пользовательских сервисов |
| 2211 | SSH | SSH-сервер для удаленного доступа |

## Проброс томов (Volumes)

| Путь на хосте | Путь в контейнере | Описание |
|-----------|----------------|-------------|
| `./project` | `/home/user/project` | Рабочая директория по умолчанию, здесь хранятся файлы проекта |
| `./vibe-kanban` | `/var/tmp/vibe-kanban` | Директория данных Vibe-Kanban |
| `./app` | `/app` | Директория приложения |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker сокет для Docker-in-Docker |

## Быстрый старт

### Предварительные требования

- Docker 20.10 или выше
- Docker Compose 2.0 или выше

### Запуск с помощью Docker Compose

1. Клонируйте или скачайте этот репозиторий локально

```bash
git clone <repository-url>
cd <repository-directory>
```

2. Запустите сервис

```bash
docker compose up -d
```

3. Доступ к сервисам

- **OpenCode**: http://localhost:2046
- **Vibe-Kanban**: http://localhost:3927

### Запуск напрямую через Docker

```bash
docker build -t successage/opencode-vibe-kanban-docker:latest .
docker run -d \
  --name opencode-vibe \
  --privileged \
  -p 2046:2046 \
  -p 3927:3927 \
  -p 2027:2027 \
  -p 2211:2211 \
  -v $(pwd)/project:/home/user/project \
  -v $(pwd)/vibe-kanban:/var/tmp/vibe-kanban \
  -v $(pwd)/app:/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  successage/opencode-vibe-kanban-docker:latest
```

## Использование

### Директория проекта

`/home/user/project` является рабочей директорией по умолчанию. Поместите файлы вашего проекта в директорию `./project`, и они автоматически станут доступны в контейнере.

### OpenCode

Сервер OpenCode запускается автоматически при старте контейнера и слушает порт 2046.

При первом запуске OpenCode вы увидите предупреждение:
```
! OPENCODE_SERVER_PASSWORD is not set; server is unsecured.
```

Это ожидаемое поведение. Если требуется безопасный доступ, вы можете установить переменную окружения `OPENCODE_SERVER_PASSWORD` в `docker-compose.yml`.

### Vibe-Kanban

Сервер Vibe-Kanban запускается автоматически при старте контейнера и слушает порт 3927.

### Claude Code

Claude Code предустановлен и готов к использованию. Конфигурационные файлы будут автоматически синхронизироваться между контейнером и хостом (`./userdata/.claude.json` и `./userdata/.claude/`).

**Первоначальная настройка:**
```bash
# 1. Запустите контейнер
docker-compose up -d

# 2. Подключитесь к контейнеру через SSH
ssh -p 2211 user@localhost
# Пароль: pwd4user

# 3. Запустите Claude Code (при первом запуске потребуется вход)
claude

# 4. Конфигурационные файлы будут автоматически сохранены в ./userdata/
```

**Дальнейшее использование:**
Конфигурация сохраняется после перезапуска контейнера. Просто запустите `claude` после подключения по SSH.

### SSH Доступ

SSH-сервер запускается автоматически на порту 2211.

**Безопасный доступ (Рекомендуется):**
Установите ваш публичный ключ в `docker-compose.yml` или переменную окружения:
```yaml
environment:
  - SSH_PUBLIC_KEY="ssh-rsa AAAAB3..."
```

**Детали подключения:**
- Порт: 2211
- Имя пользователя: user
- Аутентификация: Публичный ключ (предпочтительно) или Пароль (если установлен через OPENCODE_SERVER_PASSWORD)

```bash
ssh -p 2211 user@localhost
```

### Docker-in-Docker

Контейнер включает полную установку Docker, которая запускается автоматически. Это позволяет запускать и управлять Docker-контейнерами изнутри контейнера.

**Конфигурация Docker:**
- Драйвер хранения: fuse-overlayfs (необходим для запуска Docker внутри контейнеров)
- Пользовательская конфигурация сети для предотвращения конфликтов с хостом:
  - IP моста: 192.168.200.1/24
  - Пул адресов по умолчанию: 10.200.0.0/16
  - MTU: 1400
- Директория данных: /app/docker-data

**Docker Compose:**
Доступны команды `docker compose` и `docker-compose`.

**Примечание:** Для корректной работы Docker-in-Docker контейнер должен быть запущен в привилегированном режиме (privileged mode), а также должен быть примонтирован сокет Docker. Это настроено в `docker-compose.yml`.

### Пользовательские сервисы

Порт 2027 зарезервирован для запуска пользователями собственных сервисов. Например:

```bash
docker exec -it opencode-vibe bash
cd /home/user/project
python -m http.server 2027
```

Затем получите доступ к вашему сервису по адресу http://localhost:2027.

## Остановка сервисов

```bash
docker compose down
```

## Просмотр логов

```bash
docker compose logs -f
```

## Вход в контейнер

```bash
docker exec -it opencode-vibe bash
```

## Устранение неполадок

### Порт уже используется

Если вы видите ошибку "address already in use", значит порт уже занят. Вы можете:

1. Остановить процесс, занимающий порт
2. Или изменить проброс портов в `docker-compose.yml`

### Проблемы с правами доступа к томам

Если вы столкнулись с проблемами прав доступа к файлам в контейнере, вы можете изменить права доступа к директориям на хосте:

```bash
chmod -R 755 project vibe-kanban
```

### Перезапуск контейнера

```bash
docker compose restart
```

## Размер образа

- **Размер сборки**: ~832MB
- **Базовый образ**: Ubuntu 24.04 LTS

## Разработка

### Пересборка образа

```bash
docker compose build --no-cache
```

### Очистка

```bash
docker compose down
docker system prune -a
```

## Лицензия

Программные компоненты, включенные в этот образ, следуют своим соответствующим лицензиям:

- [OpenCode](https://github.com/anomalyco/opencode)
- [Vibe-Kanban](https://github.com/BloopAI/vibe-kanban)
- [Ubuntu](https://ubuntu.com/legal/terms-and-policies)

## Поддержка и вклад

- Документация OpenCode: https://opencode.ai/docs
- GitHub OpenCode: https://github.com/anomalyco/opencode
- GitHub Vibe-Kanban: https://github.com/BloopAI/vibe-kanban

## Примечания

1. **Конфликты портов**: Порты по умолчанию 2046, 3927, 2027 и 2211 могут быть заняты другими сервисами. Пожалуйста, убедитесь, что эти порты свободны, или измените настройки проброса портов.
2. **Сохранение данных**: Все данные сохраняются на хосте через проброс томов (volume mappings). Удаление контейнера не приведет к потере данных.
3. **Безопасность**: По умолчанию сервер OpenCode не имеет установленного пароля. В продакшене, пожалуйста, установите переменную окружения `OPENCODE_SERVER_PASSWORD`.
4. **Безопасность SSH**: Пароль SSH по умолчанию (pwd4user) следует изменить в производственных средах. Вы можете изменить его, пересобрав образ с пользовательской конфигурацией.
5. **Docker-in-Docker**: Запуск Docker внутри Docker требует привилегированного режима и монтирования сокета Docker, что настроено в docker-compose.yml. Эта настройка подходит для разработки, но должна быть тщательно оценена для использования в продакшене.
6. **Браузер Playwright**: Браузер Playwright Chromium предустановлен и готов к использованию.

## История изменений

### v2.0.0 (2026-01-23)

- Добавлен движок Docker с поддержкой Docker-in-Docker
- Добавлен SSH-сервер для удаленного доступа (порт 2211, user/pwd4user)
- Настроен Docker для окружения контейнера (fuse-overlayfs, пользовательская сеть)
- Добавлен скрипт инициализации Docker для управления сервисами
- Обновлен docker-compose.yml с привилегированным режимом и монтированием сокета Docker
- Добавлен проброс тома приложения (./app → /app)
- Обновлена документация для функций SSH и Docker

### v1.0.0 (2026-01-23)

- Первоначальный релиз
- Установлен OpenCode 1.1.33
- Установлен Vibe-Kanban
- Предустановлено 5 плагинов OpenCode (oh-my-opencode, superpowers, playwright-mcp, agent-browser, chrome-devtools-mcp)
- Настроены скрипты запуска двойного сервиса
- Проброс портов: 2046 (OpenCode), 3927 (Vibe-Kanban), 2027 (пользовательский)
- Поддержка проброса томов для сохранения данных проекта

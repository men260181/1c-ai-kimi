---
name: web-stop
description: >
  Этот скилл MUST быть вызван когда пользователь просит остановить веб-сервер, Apache, прекратить веб-публикацию.
  SHOULD также вызывать когда веб-публикации больше не нужны.
  Do NOT использовать для удаления публикаций — используй web-unpublish; для проверки статуса — используй web-info.
---

# /skill:1c-ai-kimi:web-stop — Остановка Apache

Останавливает Apache HTTP Server. Публикации сохраняются — при следующем `/skill:1c-ai-kimi:web-publish` сервер запустится снова.

## Usage

```
/skill:1c-ai-kimi:web-stop
```

## Параметры подключения

Прочитай `.v8-project.json` из корня проекта. Если задан `webPath` — используй как `-ApachePath`.
По умолчанию `tools/apache24` от корня проекта.

## Команда

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/web-stop.ps1" <параметры>
```

### Параметры скрипта

| Параметр | Обязательный | Описание |
|----------|:------------:|----------|
| `-ApachePath <путь>` | нет | Корень Apache (по умолчанию `tools/apache24`) |

## После выполнения

Предложи пользователю:
- **Перезапуск** — `/skill:1c-ai-kimi:web-publish <база>` (повторный вызов поднимет Apache с существующими публикациями)
- **Удаление публикаций** — `/skill:1c-ai-kimi:web-unpublish <имя>` или `/skill:1c-ai-kimi:web-unpublish --all`

## Примеры

```powershell
# Остановить Apache
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/web-stop.ps1"

# С указанием пути
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/web-stop.ps1" -ApachePath "C:\tools\apache24"
```

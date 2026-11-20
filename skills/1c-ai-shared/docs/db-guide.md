# Базы данных 1С

Навыки группы `/db-*` позволяют управлять информационными базами 1С из Kimi Code Code: создавать базы, загружать и выгружать конфигурации, обновлять БД, запускать предприятие, загружать изменения из Git.

## Навыки

| Навык | Скрипт | Описание |
|-------|:------:|----------|
| `/skill:1c-ai-kimi:db-list` | — | Управление реестром баз (.v8-project.json) |
| `/skill:1c-ai-kimi:db-create` | — | Создание информационной базы |
| `/skill:1c-ai-kimi:db-dump-cf` | — | Выгрузка конфигурации в CF-файл |
| `/skill:1c-ai-kimi:db-load-cf` | — | Загрузка конфигурации из CF-файла |
| `/skill:1c-ai-kimi:db-dump-xml` | `.ps1` | Выгрузка конфигурации в XML-файлы (полная/инкрементальная/частичная) |
| `/skill:1c-ai-kimi:db-load-xml` | `.ps1` | Загрузка конфигурации из XML-файлов (полная/частичная) |
| `/skill:1c-ai-kimi:db-update` | — | Обновление конфигурации БД |
| `/skill:1c-ai-kimi:db-run` | — | Запуск 1С:Предприятие |
| `/skill:1c-ai-kimi:db-load-git` | `.ps1` | Загрузка изменений из Git в базу |

## Рабочий цикл

```
.v8-project.json → /skill:1c-ai-kimi:db-create → /skill:1c-ai-kimi:db-load-cf или /skill:1c-ai-kimi:db-load-xml → /skill:1c-ai-kimi:db-update → /skill:1c-ai-kimi:db-run
                                                                    ↑
                                 /skill:1c-ai-kimi:db-dump-xml ←→ правки в исходниках → /skill:1c-ai-kimi:db-load-git → /skill:1c-ai-kimi:db-update
```

### Типичный цикл разработки

1. **Настройка** — `/skill:1c-ai-kimi:db-list add` зарегистрировать базу в `.v8-project.json`
2. **Создание** — `/skill:1c-ai-kimi:db-create` создать базу (если нет)
3. **Загрузка** — `/skill:1c-ai-kimi:db-load-xml` или `/skill:1c-ai-kimi:db-load-cf` загрузить конфигурацию
4. **Обновление** — `/skill:1c-ai-kimi:db-update` применить к БД
5. **Работа** — редактирование XML-исходников
6. **Синхронизация** — `/skill:1c-ai-kimi:db-load-git` загрузить изменения из Git
7. **Обновление** — `/skill:1c-ai-kimi:db-update` применить
8. **Запуск** — `/skill:1c-ai-kimi:db-run` открыть предприятие

## Формат `.v8-project.json`

Файл размещается в корне проекта (рядом с `.git/`).

```json
{
  "v8path": "C:\\Program Files\\1cv8\\8.3.25.1257\\bin",
  "databases": [
    {
      "id": "dev",
      "name": "Разработка",
      "type": "file",
      "path": "C:\\Bases\\MyApp_Dev",
      "user": "Admin",
      "password": "",
      "aliases": ["dev", "разработка"],
      "branches": ["dev", "develop", "feature/*"],
      "configSrc": "C:\\WS\\myapp\\cfsrc"
    },
    {
      "id": "test",
      "name": "Тестовая",
      "type": "server",
      "server": "srv01",
      "ref": "MyApp_Test",
      "user": "Admin",
      "password": "123",
      "aliases": ["test", "тест"]
    }
  ],
  "default": "dev"
}
```

### Поля базы данных

| Поле | Тип | Обязательное | Описание |
|------|-----|:------------:|----------|
| `id` | string | да | Уникальный идентификатор |
| `name` | string | да | Имя |
| `type` | `"file"` / `"server"` | да | Тип подключения |
| `path` | string | для file | Каталог файловой базы |
| `server` | string | для server | Адрес сервера |
| `ref` | string | для server | Имя базы на сервере |
| `user` | string | нет | Пользователь 1С |
| `password` | string | нет | Пароль |
| `aliases` | string[] | нет | Альтернативные имена |
| `branches` | string[] | нет | Git-ветки или glob-паттерны (`release/*`, `feature/*`) |
| `configSrc` | string | нет | Каталог XML-выгрузки |

### Разрешение базы

Все навыки `db-*` (а также `epf-build`, `epf-dump`, `erf-build`, `erf-dump`) используют единый алгоритм:

1. Если пользователь указал **параметры подключения** (путь, сервер) — используй напрямую
2. Если указал **базу по имени** — ищи: `id` → `aliases` (с учётом морфологии) → `name` (нечёткое)
3. Если **не указал** — сопоставь текущую ветку Git с `branches` (точно или по glob-паттерну)
4. Fallback на `default`
5. Если не найдено — спроси пользователя
6. После выполнения: если использованная база не зарегистрирована — предложи добавить через `/skill:1c-ai-kimi:db-list add`

## Сценарии использования

### Создать базу и загрузить конфигурацию

```
> Создай файловую базу C:\Bases\Test и загрузи в неё конфигурацию из C:\WS\cfsrc
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-create` → `/skill:1c-ai-kimi:db-load-xml -Mode Full` → предложит `/skill:1c-ai-kimi:db-update`.

### Загрузить изменения из Git

```
> Загрузи мои последние правки в базу разработки
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-load-git dev -Source All` → предложит `/skill:1c-ai-kimi:db-update`.

### Выгрузить конфигурацию

```
> Выгрузи конфигурацию из тестовой базы в C:\WS\cfsrc
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-dump-xml test C:\WS\cfsrc -Mode Full`.

### Работа с расширениями

```
> Выгрузи расширение МоёРасширение из базы dev в C:\WS\ext_src
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-dump-xml dev C:\WS\ext_src -Extension МоёРасширение`.

```
> Загрузи расширение обратно в базу
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-load-xml C:\WS\ext_src dev -Extension МоёРасширение` → предложит `/skill:1c-ai-kimi:db-update -Extension МоёРасширение`.

### Запустить предприятие

```
> Запусти базу разработки
```

Kimi Code вызовет `/skill:1c-ai-kimi:db-run dev`.

## Спецификации

- [build-spec.md](build-spec.md) — пакетный режим конфигуратора 1С (CREATEINFOBASE, DESIGNER, ENTERPRISE, параметры, коды возврата)

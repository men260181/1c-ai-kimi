# Подсистемы и командный интерфейс

Навыки групп `/subsystem-*` и `/interface-*` позволяют анализировать, создавать, редактировать и проверять подсистемы 1С и их командный интерфейс — XML-файлы Subsystem и CommandInterface.xml из выгрузки конфигурации.

## Навыки

| Навык | Параметры | Описание |
|-------|-----------|----------|
| `/skill:1c-ai-kimi:inspect` | `<SubsystemPath> [-Mode] [-Name]` | Анализ структуры подсистемы: состав, дочерние, CI, дерево иерархии (5 режимов, включая full) |
| `/skill:1c-ai-kimi:subsystem-expert` | `<JsonPath> <OutputDir> [-Parent]` | Генерация подсистемы из JSON DSL: XML + регистрация в Configuration.xml |
| `/skill:1c-ai-kimi:subsystem-expert` | `<SubsystemPath> -Operation <op> -Value "<value>"` | Точечное редактирование: 5 операций (add/remove content/child, set-property) |
| `/skill:1c-ai-kimi:validate` | `<SubsystemPath> [-MaxErrors 30]` | Валидация структурной корректности: 13 проверок |
| `/skill:1c-ai-kimi:subsystem-expert` | `<CIPath> -Operation <op> -Value "<value>"` | Настройка CommandInterface.xml: 6 операций (hide/show/place/order) |
| `/skill:1c-ai-kimi:validate` | `<CIPath> [-MaxErrors 30]` | Валидация CommandInterface.xml: 13 проверок |

## Рабочий цикл

```
Описание раздела (текст) → JSON DSL → /skill:1c-ai-kimi:subsystem-expert → XML → /skill:1c-ai-kimi:validate
                                                             ↕ /skill:1c-ai-kimi:subsystem-expert  → /skill:1c-ai-kimi:inspect
                                        /skill:1c-ai-kimi:subsystem-expert → CommandInterface.xml → /skill:1c-ai-kimi:validate
```

1. Kimi Code формирует JSON-определение подсистемы (имя, состав, дочерние, картинка)
2. `/skill:1c-ai-kimi:subsystem-expert` генерирует XML-файл подсистемы и регистрирует в Configuration.xml
3. `/skill:1c-ai-kimi:subsystem-expert` вносит точечные изменения: добавление объектов, дочерних подсистем, изменение свойств
4. `/skill:1c-ai-kimi:subsystem-expert` настраивает командный интерфейс: скрытие/показ команд, размещение в группах, порядок
5. `/skill:1c-ai-kimi:validate` и `/skill:1c-ai-kimi:validate` проверяют корректность XML
6. `/skill:1c-ai-kimi:inspect` выводит компактную сводку для визуальной проверки

## JSON DSL — формат подсистемы

Подсистемы описываются в JSON:

### Минимальный пример

```json
{
  "name": "Тест"
}
```

Умолчания: `includeInCommandInterface = true`, `useOneCommand = false`, synonym генерируется из name.

### Полный пример

```json
{
  "name": "Продажи",
  "synonym": "Продажи",
  "comment": "",
  "includeInCommandInterface": true,
  "useOneCommand": false,
  "explanation": "Управление продажами и взаимодействием с клиентами",
  "picture": "CommonPicture.Продажи",
  "content": ["Catalog.Товары", "Document.Заказ", "Report.Продажи"],
  "children": ["Настройки", "Отчёты"]
}
```

### Свойства

| Свойство | Тип | Умолчание | Описание |
|----------|-----|-----------|----------|
| `name` | string | *(обязательно)* | Идентификатор подсистемы |
| `synonym` | string | из name | Отображаемое имя |
| `comment` | string | `""` | Комментарий |
| `includeInCommandInterface` | bool | `true` | Включать в командный интерфейс |
| `useOneCommand` | bool | `false` | Режим одной команды (требует ровно 1 элемент в content) |
| `explanation` | string | `""` | Описание раздела (подсказка) |
| `picture` | string | — | Ссылка на общую картинку (`CommonPicture.Имя`) |
| `content` | string[] | `[]` | Состав: `"Тип.Имя"` (Catalog.X, Document.Y, Report.Z, ...) |
| `children` | string[] | `[]` | Имена дочерних подсистем |

## Командный интерфейс — операции

Навык `/skill:1c-ai-kimi:subsystem-expert` управляет файлом `CommandInterface.xml` подсистемы.

### Форматы ссылок на команды

| Формат | Пример |
|--------|--------|
| StandardCommand | `Catalog.Товары.StandardCommand.OpenList` |
| Command | `Report.Продажи.Command.Отчёт` |
| CommonCommand | `CommonCommand.МояКоманда` |

### Операции

| Операция | Значение | Описание |
|----------|----------|----------|
| `hide` | `"Cmd.Name"` или массив | Скрыть команду (CommandsVisibility, false) |
| `show` | `"Cmd.Name"` или массив | Показать команду (CommandsVisibility, true) |
| `place` | `{"command":"...","group":"CommandGroup.X"}` | Разместить команду в группе |
| `order` | `{"group":"...","commands":[...]}` | Задать порядок команд в группе |
| `subsystem-order` | `["Subsystem.X.Subsystem.A",...]` | Порядок дочерних подсистем |
| `group-order` | `["NavigationPanelOrdinary",...]` | Порядок групп |

### Примеры

```powershell
# Скрыть команду
... -CIPath Subsystems/Продажи/Ext/CommandInterface.xml -Operation hide -Value "Catalog.Товары.StandardCommand.OpenList"

# Показать команду
... -Operation show -Value "Report.Продажи.Command.Отчёт"

# Разместить в группе
... -Operation place -Value '{"command":"Report.X.Command.Y","group":"CommandGroup.Отчеты"}'

# Задать порядок подсистем
... -Operation subsystem-order -Value '["Subsystem.X.Subsystem.A","Subsystem.X.Subsystem.B"]'
```

## Сценарии использования

### Анализ структуры подсистем

```
> Покажи дерево подсистем конфигурации
```

Kimi Code вызовет `/skill:1c-ai-kimi:inspect` (tree → overview → ci) и опишет:
- иерархию подсистем с маркерами [CI], [OneCmd], [Скрыт]
- состав каждой подсистемы (объекты по типам)
- настройки командного интерфейса (видимость, размещение, порядок)

### Создание подсистемы по описанию

```
> Создай подсистему Продажи: справочник Товары, документ Заказ, отчёт Продажи.
> Дочерние подсистемы: Настройки, Отчёты. Картинка — CommonPicture.Продажи.
```

Kimi Code сформирует JSON:
```json
{
  "name": "Продажи",
  "synonym": "Продажи",
  "content": ["Catalog.Товары", "Document.Заказ", "Report.Продажи"],
  "children": ["Настройки", "Отчёты"],
  "picture": "CommonPicture.Продажи"
}
```

И вызовет `/skill:1c-ai-kimi:subsystem-expert` → `/skill:1c-ai-kimi:validate` → `/skill:1c-ai-kimi:inspect`.

### Добавление объектов в подсистему

```
> Добавь Document.Счёт и Report.Задолженность в подсистему Продажи
```

Kimi Code вызовет `/skill:1c-ai-kimi:subsystem-expert` с операцией `add-content`:
```powershell
... -SubsystemPath Subsystems/Продажи.xml -Operation add-content -Value '["Document.Счёт","Report.Задолженность"]'
```

### Настройка командного интерфейса

```
> Скрой команду открытия списка товаров и размести отчёт Продажи в группе Отчёты
```

Kimi Code вызовет `/skill:1c-ai-kimi:subsystem-expert`:
```powershell
# Скрыть команду
... -CIPath Subsystems/Продажи/Ext/CommandInterface.xml -Operation hide -Value "Catalog.Товары.StandardCommand.OpenList"

# Разместить в группе
... -Operation place -Value '{"command":"Report.Продажи.Command.Отчёт","group":"CommandGroup.Отчёты"}'
```

### Проверка подсистемы

```
> Проверь подсистему Subsystems/Продажи.xml
```

Kimi Code вызовет `/skill:1c-ai-kimi:validate` и `/skill:1c-ai-kimi:validate`, покажет результат: ошибки (невалидный XML, отсутствующие файлы, дубликаты) и предупреждения.

## Структура файлов подсистемы

```
Subsystems/
├── ИмяПодсистемы.xml                    # Определение подсистемы (UUID, свойства, Content)
└── ИмяПодсистемы/
    ├── Ext/
    │   └── CommandInterface.xml          # Командный интерфейс (видимость, размещение, порядок)
    └── Subsystems/                       # Вложенные подсистемы
        ├── Дочерняя.xml
        └── Дочерняя/
            └── Ext/
                └── CommandInterface.xml
```

Регистрация в `Configuration.xml`:
```xml
<ChildObjects>
    <Subsystem>ИмяПодсистемы</Subsystem>
</ChildObjects>
```

## Спецификация

- [1c-subsystem-spec.md](1c-subsystem-spec.md) — XML-формат подсистем, CommandInterface.xml, namespace, элементы

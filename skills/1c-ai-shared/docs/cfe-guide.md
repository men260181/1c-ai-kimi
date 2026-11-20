# Расширения конфигурации (CFE)

Навыки группы `/cfe-*` позволяют создавать, заимствовать объекты, перехватывать методы, проверять и анализировать расширения конфигурации 1С.

## Навыки

| Навык | Параметры | Описание |
|-------|-----------|----------|
| `/skill:1c-ai-kimi:cfe-init` | `<Name> [-Purpose Patch\|Customization\|AddOn] [-CompatibilityMode]` | Создание расширения (scaffold XML-исходников) |
| `/skill:1c-ai-kimi:cfe-borrow` | `-ExtensionPath <path> -ConfigPath <path> -Object "Type.Name"` | Заимствование объектов из конфигурации |
| `/skill:1c-ai-kimi:cfe-patch-method` | `-ExtensionPath <path> -ModulePath "Type.Name.Module" -MethodName "X" -InterceptorType Before` | Генерация перехватчика метода |
| `/skill:1c-ai-kimi:validate` | `<ExtensionPath> [-MaxErrors 30]` | Валидация структурной корректности (9 проверок) |
| `/skill:1c-ai-kimi:cfe-diff` | `-ExtensionPath <path> -ConfigPath <path> [-Mode A\|B]` | Анализ расширения и проверка переноса |

## Рабочий цикл

```
cf-info (версия, совместимость)
    ↓
/skill:1c-ai-kimi:cfe-init → scaffold расширения
    ↓
/skill:1c-ai-kimi:cfe-borrow → заимствование объектов из конфигурации
    ↓
/skill:1c-ai-kimi:cfe-patch-method → перехват методов
    ↓
/skill:1c-ai-kimi:validate → проверка корректности
    ↓
/skill:1c-ai-kimi:cfe-diff Mode A → обзор изменений
```

## Типичные сценарии

### Создание расширения для исправления бага

```
> Создай расширение для исправления бага в справочнике Контрагенты,
  конфигурация ERP в C:\cfsrc\erp
```

Kimi Code выполнит:
1. `/skill:1c-ai-kimi:inspect C:\cfsrc\erp -Mode brief` — получить версию и режим совместимости
2. `/skill:1c-ai-kimi:cfe-init` — создать расширение с нужным `CompatibilityMode`
3. `/skill:1c-ai-kimi:cfe-borrow` — заимствовать `Catalog.Контрагенты`
4. `/skill:1c-ai-kimi:cfe-patch-method` — создать перехватчик нужного метода
5. `/skill:1c-ai-kimi:validate` — проверить результат

### Анализ существующего расширения

```
> Покажи что изменено в расширении src/
```

Kimi Code вызовет `/skill:1c-ai-kimi:cfe-diff -Mode A` и покажет: заимствованные объекты, перехватчики, собственные объекты.

### Проверка переноса изменений

```
> Проверь, все ли изменения из расширения перенесены в конфигурацию
```

Kimi Code вызовет `/skill:1c-ai-kimi:cfe-diff -Mode B` — найдёт блоки `#Вставка` и проверит их наличие в конфигурации.

## cfe-init — создание расширения

Параметры:

| Параметр | Описание | По умолчанию |
|----------|----------|--------------|
| `Name` | Имя расширения (обязат.) | — |
| `Synonym` | Синоним | = Name |
| `NamePrefix` | Префикс собственных объектов | = Name + "_" |
| `OutputDir` | Каталог | `src` |
| `Purpose` | Назначение | `Customization` |
| `Version` | Версия | — |
| `Vendor` | Поставщик | — |
| `CompatibilityMode` | Режим совместимости | `Version8_3_24` |
| `NoRole` | Без основной роли | false |

Создаёт:
```
<OutputDir>/
├── Configuration.xml         # Свойства расширения
├── Languages/
│   └── Русский.xml           # Язык (Adopted)
└── Roles/                    # Если не -NoRole
    └── <Prefix>ОсновнаяРоль.xml
```

Назначение расширения (`Purpose`):
- `Patch` — исправление ошибок (минимальные изменения, только перехватчики)
- `Customization` — доработка (реквизиты, формы, модули)
- `AddOn` — дополнение (полноценный функционал)

## cfe-borrow — заимствование объектов

Заимствует объекты из основной конфигурации в расширение. Создаёт минимальные XML-файлы с `ObjectBelonging=Adopted` и `ExtendedConfigurationObject`.

Формат `-Object`:
- `Catalog.Контрагенты` — справочник
- `CommonModule.РаботаСФайлами` — общий модуль
- `Enum.ВидыОплат` — перечисление
- `Document.Заказ ;; Catalog.Товары` — несколько объектов через `;;`

Поддерживаемые типы: Catalog, Document, Enum, CommonModule, Report, DataProcessor, ExchangePlan, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, ChartOfAccounts, ChartOfCharacteristicTypes, ChartOfCalculationTypes, BusinessProcess, Task, и другие (44 типа).

## cfe-patch-method — перехват методов

Генерирует `.bsl` файл с декоратором перехвата для заимствованного объекта.

Параметры:

| Параметр | Описание |
|----------|----------|
| `ModulePath` | `Catalog.X.ObjectModule`, `CommonModule.Y`, `Catalog.X.Form.Z` |
| `MethodName` | Имя перехватываемого метода |
| `InterceptorType` | `Before` / `After` / `ModificationAndControl` |
| `Context` | `НаСервере` / `НаКлиенте` / `НаСервереБезКонтекста` |
| `IsFunction` | Добавить `Возврат` |

Типы перехватчиков:

| Тип | Декоратор | Когда использовать |
|-----|-----------|-------------------|
| `Before` | `&Перед` | Выполнить код до вызова оригинального метода |
| `After` | `&После` | Выполнить код после вызова оригинального метода |
| `ModificationAndControl` | `&ИзменениеИКонтроль` | Полная замена тела метода с маркерами `#Вставка`/`#Удаление` |

Пример генерируемого кода (`Before`):
```bsl
&НаСервере
&Перед("ПриЗаписи")
Процедура Расш1_ПриЗаписи()
	// TODO: код перед вызовом оригинального метода
КонецПроцедуры
```

## cfe-validate — проверки

| # | Проверка | Уровень |
|---|----------|---------|
| 1 | XML well-formedness, MetaDataObject/Configuration, version | ERROR |
| 2 | InternalInfo: 7 ContainedObject, валидные ClassId | ERROR |
| 3 | Extension properties: ObjectBelonging=Adopted, Name, Purpose, NamePrefix, KeepMapping | ERROR |
| 4 | Enum-значения (4 свойства) | ERROR |
| 5 | ChildObjects: валидные типы, нет дубликатов, порядок | ERROR/WARN |
| 6 | DefaultLanguage ссылается на существующий Language | ERROR |
| 7 | Файлы языков существуют | WARN |
| 8 | Каталоги объектов существуют | WARN |
| 9 | Заимствованные объекты: ObjectBelonging=Adopted, ExtendedConfigurationObject UUID | ERROR/WARN |

## cfe-diff — режимы

### Mode A — обзор расширения

Для каждого объекта показывает:
- `[BORROWED]` — заимствованный: перехватчики, собственные реквизиты/формы
- `[OWN]` — собственный: количество реквизитов, ТЧ, форм

### Mode B — проверка переноса

Для каждого `&ИзменениеИКонтроль` проверяет, перенесены ли блоки `#Вставка` в конфигурацию:
- `[TRANSFERRED]` — код найден в конфигурации
- `[NOT_TRANSFERRED]` — код не найден
- `[NEEDS_REVIEW]` — нет блоков `#Вставка` или модуль конфигурации не найден

## Связь с другими навыками

- `/skill:1c-ai-kimi:inspect` — получение версии и совместимости конфигурации перед `cfe-init`
- `/skill:1c-ai-kimi:meta-compile` — создание собственных объектов расширения (реквизиты, ТЧ)
- `/skill:1c-ai-kimi:form-compile`, `/skill:1c-ai-kimi:form-edit` — создание и модификация форм расширения
- `/skill:1c-ai-kimi:validate` — всегда проверяйте расширение после изменений

## Спецификации

- [1c-extension-spec.md](1c-extension-spec.md) — XML-формат выгрузки расширений конфигурации (CFE)

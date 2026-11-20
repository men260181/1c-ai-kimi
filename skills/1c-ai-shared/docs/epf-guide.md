# Внешние обработки и отчёты (EPF / ERF)

Навыки для создания, модификации и сборки внешних обработок (`.epf`) и внешних отчётов (`.erf`) 1С:Предприятия 8.3 из XML-исходников.

## Навыки обработок (EPF)

| Навык | Параметры | Описание |
|-------|-----------|----------|
| `/skill:1c-ai-kimi:epf-expert` | `<Name> [Synonym]` | Создать новую обработку (корневой XML + модуль объекта) |
| `/skill:1c-ai-kimi:epf-expert` | `<ProcessorName> <FormName> [Synonym]` | Добавить управляемую форму к обработке |
| `/skill:1c-ai-kimi:epf-expert` | `<ProcessorName>` | Собрать EPF из XML (через 1cv8.exe) |
| `/skill:1c-ai-kimi:epf-expert` | `<EpfFile>` | Разобрать EPF в XML (через 1cv8.exe) |
| `/skill:1c-ai-kimi:epf-expert` | `<ProcessorName> <Вид>` | Добавить регистрацию БСП (СведенияОВнешнейОбработке) |
| `/skill:1c-ai-kimi:epf-expert` | `<ProcessorName> <Идентификатор>` | Добавить команду в дополнительную обработку БСП |
| `/skill:1c-ai-kimi:validate` | `<ObjectPath> [-MaxErrors 30]` | Валидация структурной корректности обработки (10 проверок) |

## Внешние отчёты (ERF)

| Навык | Параметры | Описание |
|-------|-----------|----------|
| `/skill:1c-ai-kimi:erf-expert` | `<ReportName> [Synonym] [--WithSKD]` | Создать новый отчёт (корневой XML + модуль объекта + опционально СКД) |
| `/skill:1c-ai-kimi:erf-expert` | `<ReportName>` | Собрать ERF из XML (через 1cv8.exe) |
| `/skill:1c-ai-kimi:erf-expert` | `<ErfFile>` | Разобрать ERF в XML (через 1cv8.exe) |
| `/skill:1c-ai-kimi:validate` | `<ObjectPath> [-MaxErrors 30]` | Валидация структурной корректности отчёта (10 проверок) |

Флаг `--WithSKD` создаёт макет `ОсновнаяСхемаКомпоновкиДанных` и привязывает его к `MainDataCompositionSchema`.

## Универсальные навыки

Работают с любыми объектами — обработками, отчётами, справочниками, документами и др.

| Навык | Параметры | Описание |
|-------|-----------|----------|
| `/skill:1c-ai-kimi:mxl-expert` | `<ObjectName> <TemplateName> <TemplateType>` | Добавить макет (HTML, Text, SpreadsheetDocument, BinaryData, DataCompositionSchema) |
| `/skill:1c-ai-kimi:mxl-expert` | `<ObjectName> <TemplateName>` | Удалить макет |
| `/skill:1c-ai-kimi:help-add` | `<ObjectName>` | Добавить встроенную справку (Help.xml + HTML) |
| `/skill:1c-ai-kimi:form-remove` | `<ObjectName> <FormName>` | Удалить форму |

Для отчётов: при добавлении макета типа DataCompositionSchema автоматически заполняется `MainDataCompositionSchema` (если пуст).

Навыки удаления (`template-remove`, `form-remove`) не вызываются Kimi Code автоматически — только по явной команде пользователя.

## Сценарии использования

Не обязательно запоминать команды и параметры. Просто опишите задачу своими словами — Kimi Code сам подберёт нужные навыки.

### Обработка с формой

Типичная обработка для манипуляций с данными — форма для пользователя, модуль объекта для логики.

```
> Создай обработку ЗагрузкаПрайса с формой
```

Kimi Code выполнит `/skill:1c-ai-kimi:epf-expert` и `/skill:1c-ai-kimi:epf-expert` с правильными параметрами.

### Внешняя печатная форма

Обработка с макетом табличного документа, подключаемая через механизм дополнительных обработок БСП к конкретному документу.

```
> Создай внешнюю печатную форму для документа Реализация. Макет — табличный документ.
```

Kimi Code создаст обработку, добавит макет SpreadsheetDocument, вызовет `/skill:1c-ai-kimi:epf-expert` с видом ПечатнаяФорма и назначением, сгенерирует `СведенияОВнешнейОбработке()` и процедуру `Печать()`.

### Внешний отчёт с СКД

```
> Создай внешний отчёт ОстаткиНаСкладе с СКД
```

Kimi Code выполнит `/skill:1c-ai-kimi:erf-expert ОстаткиНаСкладе --WithSKD`, затем предложит заполнить схему компоновки через `/skill:1c-ai-kimi:skd-compile`.

### Доработка существующей обработки

```
> Добавь справку с описанием как пользоваться обработкой
```

Kimi Code вызовет `/skill:1c-ai-kimi:help-add` и предложит отредактировать HTML.

```
> Добавь ещё одну команду печати — накладная
```

Kimi Code вызовет `/skill:1c-ai-kimi:epf-expert`, добавит команду в `СведенияОВнешнейОбработке()` и блок обработки в процедуру `Печать()`.

```
> Собери
```

Kimi Code вызовет `/skill:1c-ai-kimi:epf-expert` или `/skill:1c-ai-kimi:erf-expert` в зависимости от типа объекта.

### Примеры слеш-команд

Слеш-команды работают для случаев, когда хочется точного контроля:

```
> /skill:1c-ai-kimi:epf-expert МояОбработка "Моя обработка"
> /skill:1c-ai-kimi:epf-expert МояОбработка Форма
> /skill:1c-ai-kimi:mxl-expert МояОбработка Макет HTML
> /skill:1c-ai-kimi:help-add МояОбработка
> /skill:1c-ai-kimi:epf-expert МояОбработка

> /skill:1c-ai-kimi:erf-expert МойОтчёт --WithSKD
> /skill:1c-ai-kimi:mxl-expert МойОтчёт ДопМакет SpreadsheetDocument
> /skill:1c-ai-kimi:erf-expert МойОтчёт
```

## Структура каталогов

После `/skill:1c-ai-kimi:epf-expert` создаётся структура:

```
src/
├── МояОбработка.xml                          # Корневой файл метаданных
└── МояОбработка/
    └── Ext/
        └── ObjectModule.bsl                  # Модуль объекта
```

После `/skill:1c-ai-kimi:epf-expert` и `/skill:1c-ai-kimi:mxl-expert`:

```
src/
├── МояОбработка.xml
└── МояОбработка/
    ├── Ext/
    │   └── ObjectModule.bsl
    ├── Forms/
    │   ├── Форма.xml                         # Метаданные формы
    │   └── Форма/
    │       └── Ext/
    │           ├── Form.xml                  # Описание формы
    │           └── Form/
    │               └── Module.bsl            # Модуль формы
    └── Templates/
        ├── Макет.xml                         # Метаданные макета
        └── Макет/
            └── Ext/
                └── Template.html             # Содержимое макета
```

После `/skill:1c-ai-kimi:erf-expert МойОтчёт --WithSKD`:

```
src/
├── МойОтчёт.xml                              # Корневой файл (ExternalReport)
└── МойОтчёт/
    ├── Ext/
    │   └── ObjectModule.bsl                  # Модуль объекта
    └── Templates/
        ├── ОсновнаяСхемаКомпоновкиДанных.xml
        └── ОсновнаяСхемаКомпоновкиДанных/
            └── Ext/
                └── Template.xml              # Пустая СКД
```

Первая добавленная форма автоматически становится основной (DefaultForm). Флаг `--main` нужен только для переназначения основной формы на другую.

## Технические детали

- Все XML-файлы создаются в **UTF-8 с BOM** (как в реальных выгрузках 1С)
- PowerShell-скрипты используют `System.Xml.XmlDocument` для модификации корневого XML
- UUID генерируются через `[guid]::NewGuid()`
- ClassId обработки: `c3831ec8-d8d5-4f93-8a22-f9bfae07327f`
- ClassId отчёта: `e41aff26-25cf-4bb6-b6c1-3f478a75f374`
- Порядок элементов в `ChildObjects`: TabularSections → Forms → Templates
- Первая форма автоматически назначается основной (DefaultForm)
- Навыки БСП (`epf-bsp-*`) не используют скрипты — Kimi Code модифицирует код напрямую через Read/Edit
- Для отчётов: `/skill:1c-ai-kimi:mxl-expert` с типом DataCompositionSchema автоматически заполняет `MainDataCompositionSchema`

## Спецификации

- [XML-формат выгрузки обработок](1c-epf-spec.md) — структура XML-файлов, namespace, элементы форм
- [XML-формат внешних отчётов](1c-erf-spec.md) — отличия ERF от EPF, Properties, MainDataCompositionSchema
- [Встроенная справка](1c-help-spec.md) — Help.xml, HTML-страницы, кнопка справки на форме
- [Сборка и разборка EPF/ERF](build-spec.md) — команды `1cv8.exe`, параметры, коды возврата

---
name: form-add
description: >
  Этот скилл MUST быть вызван когда нужно добавить управляемую форму к существующему объекту конфигурации (справочник, документ, обработка).
  SHOULD также вызывать после meta-compile когда объекту нужны формы.
  Do NOT использовать для создания формы из JSON-определения — используй form-compile; для добавления к EPF — используй epf-add-form.
---

# /skill:1c-ai-kimi:form-add — Добавление формы к объекту конфигурации

Создаёт управляемую форму (metadata XML + Form.xml + Module.bsl) и регистрирует её в корневом XML объекта конфигурации (Document, Catalog, InformationRegister и др.).

## Usage

```
/skill:1c-ai-kimi:form-add <ObjectPath> <FormName> [Purpose] [Synonym] [--set-default]
```

| Параметр    | Обязательный | По умолчанию | Описание                                     |
|-------------|:------------:|--------------|----------------------------------------------|
| ObjectPath  | да           | —            | Путь к XML-файлу объекта (Documents/Док.xml)  |
| FormName    | да           | —            | Имя формы (ФормаДокумента)                    |
| Purpose     | нет          | Object       | Назначение: Object, List, Choice, Record      |
| Synonym     | нет          | = FormName   | Синоним формы                                 |
| --set-default | нет        | авто         | Установить как форму по умолчанию             |

## Команда

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/form-add.ps1" -ObjectPath "<ObjectPath>" -FormName "<FormName>" [-Purpose "<Purpose>"] [-Synonym "<Synonym>"] [-SetDefault]
```

## Purpose — назначение формы

| Purpose | Допустимые типы объектов | Основной реквизит | DefaultForm-свойство |
|---------|-------------------------|-------------------|---------------------|
| Object  | Document, Catalog, DataProcessor, Report, ExternalDataProcessor, ExternalReport, ChartOf*, ExchangePlan, BusinessProcess, Task | Объект (тип: *Object.Имя) | DefaultObjectForm (DefaultForm для DataProcessor/Report/ExternalDataProcessor/ExternalReport) |
| List    | Все кроме DataProcessor | Список (DynamicList) | DefaultListForm |
| Choice  | Document, Catalog, ChartOf*, ExchangePlan, BusinessProcess, Task | Список (DynamicList) | DefaultChoiceForm |
| Record  | InformationRegister | Запись (InformationRegisterRecordManager) | DefaultRecordForm |

## Что создаётся

```
<ObjectDir>/Forms/
├── <FormName>.xml                    # Метаданные формы (UUID)
└── <FormName>/
    └── Ext/
        ├── Form.xml                  # Описание формы (logform namespace)
        └── Form/
            └── Module.bsl           # BSL-модуль с 5 регионами + ПриСозданииНаСервере
```

## Что модифицируется

- `<ObjectPath>` — добавляется `<Form>` в `ChildObjects` (перед `<Template>` или `<TabularSection>`), обновляется Default*Form (автоматически если пустое, или явно при `--set-default`)

## Поддерживаемые типы объектов

Document, Catalog, DataProcessor, Report, ExternalDataProcessor, ExternalReport, InformationRegister, ChartOfAccounts, ChartOfCharacteristicTypes, ExchangePlan, BusinessProcess, Task

## Примеры

```
# Форма документа
/skill:1c-ai-kimi:form-add Documents/АвансовыйОтчет.xml ФормаДокумента --purpose Object

# Форма списка каталога
/skill:1c-ai-kimi:form-add Catalogs/Контрагенты.xml ФормаСписка --purpose List

# Форма записи регистра сведений
/skill:1c-ai-kimi:form-add InformationRegisters/КурсыВалют.xml ФормаЗаписи --purpose Record

# Форма выбора с синонимом
/skill:1c-ai-kimi:form-add Catalogs/Номенклатура.xml ФормаВыбора --purpose Choice --synonym "Выбор номенклатуры"

# Установить как форму по умолчанию
/skill:1c-ai-kimi:form-add Documents/Заказ.xml ФормаДокументаНовая --purpose Object --set-default
```

## Workflow

1. `/skill:1c-ai-kimi:form-add` — создать каркас формы
2. `/skill:1c-ai-kimi:form-compile` или `/skill:1c-ai-kimi:form-edit` — наполнить Form.xml элементами
3. `/skill:1c-ai-kimi:validate` — проверить корректность
4. `/skill:1c-ai-kimi:inspect` — проанализировать результат

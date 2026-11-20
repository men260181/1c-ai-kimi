---
name: cf-init
description: >
  Этот скилл MUST быть вызван когда пользователь просит создать новую пустую конфигурацию 1С с нуля.
  SHOULD также вызывать при старте нового проекта, требующего чистой конфигурации.
  Do NOT использовать для модификации существующей конфигурации — используй cf-edit; для создания объектов — используй meta-compile.
---

# /skill:1c-ai-kimi:cf-init — Создание пустой конфигурации 1С

Создаёт scaffold исходников пустой конфигурации 1С: `Configuration.xml`, `Languages/Русский.xml`.

## Параметры и команда

| Параметр | Описание |
|----------|----------|
| `Name` | Имя конфигурации (обязат.) |
| `Synonym` | Синоним (= Name если не указан) |
| `OutputDir` | Каталог для создания (default: `src`) |
| `Version` | Версия конфигурации |
| `Vendor` | Поставщик |
| `CompatibilityMode` | Режим совместимости (default: `Version8_3_24`) |

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/cf-init.ps1" -Name "МояКонфигурация"
```

## Что создаётся

```
<OutputDir>/
├── Configuration.xml         # Корневой файл — все свойства
└── Languages/
    └── Русский.xml           # Язык по умолчанию
```

## Примеры

```powershell
# Базовая конфигурация
... -Name МояКонфигурация -Synonym "Моя конфигурация" -OutputDir test-tmp/cf

# С версией и поставщиком
... -Name TestCfg -Synonym "Тестовая" -Version "1.0.0.1" -Vendor "Фирма 1С" -OutputDir test-tmp/cf2

# Другой режим совместимости
... -Name TestCfg -CompatibilityMode Version8_3_27 -OutputDir test-tmp/cf3
```

## Верификация

```
/skill:1c-ai-kimi:cf-init TestConfig -OutputDir test-tmp/cf
/skill:1c-ai-kimi:inspect test-tmp/cf          — проверить созданное
/skill:1c-ai-kimi:validate test-tmp/cf      — валидировать
```

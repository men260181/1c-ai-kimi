---
name: role-expert
description: >
  Этот скилл MUST быть вызван когда нужно создать новую роль 1С с набором прав на объекты.
  SHOULD также вызывать при настройке разграничения доступа для новой функциональности.
  Do NOT использовать для анализа роли — используй inspect; для валидации — validate;
  для изменения существующей роли — meta-edit.
---

# /skill:1c-ai-kimi:role-expert — Создание роли 1С из JSON DSL

Принимает JSON-определение роли → генерирует `Roles/Имя.xml` (метаданные) и `Roles/Имя/Ext/Rights.xml` (права). UUID автоматически.

## Usage

```
/skill:1c-ai-kimi:role-expert <JsonPath> <RolesDir>
```

| Параметр | Описание |
|----------|----------|
| `JsonPath` | Путь к JSON-определению роли |
| `RolesDir` | Каталог `Roles/` в исходниках конфигурации |

## Команда

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/role-compile.ps1" -JsonPath "<json>" -OutputDir "<RolesDir>"
```

`<Role>ИмяРоли</Role>` автоматически добавляется в `<ChildObjects>` файла `Configuration.xml` (ожидается в parent от `RolesDir`).

## DSL-формат

Описание JSON DSL для определения роли: `${KIMI_SKILL_DIR}/dsl-reference.md`

## Смежные операции

| Задача | Скилл |
|--------|-------|
| Анализ прав роли | `/skill:1c-ai-kimi:inspect` (режим role-info) |
| Валидация роли | `/skill:1c-ai-kimi:validate` (режим role) |
| Изменение свойств объекта | `/skill:1c-ai-kimi:meta-edit` |

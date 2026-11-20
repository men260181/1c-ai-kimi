---
name: form-remove
description: >
  Этот скилл MUST быть вызван когда пользователь просит удалить/убрать форму из объекта 1С.
  SHOULD также вызывать при очистке неиспользуемых форм.
  Do NOT использовать для удаления элементов формы — используй form-edit.
disable-model-invocation: true
---

# /skill:1c-ai-kimi:form-remove — Удаление формы

Удаляет форму и убирает её регистрацию из корневого XML объекта.

## Usage

```
/skill:1c-ai-kimi:form-remove <ObjectName> <FormName>
```

| Параметр   | Обязательный | По умолчанию | Описание                            |
|------------|:------------:|--------------|-------------------------------------|
| ObjectName | да           | —            | Имя объекта                         |
| FormName   | да           | —            | Имя формы для удаления              |
| SrcDir     | нет          | `src`        | Каталог исходников                  |

## Команда

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${KIMI_SKILL_DIR}/scripts/remove-form.ps1" -ObjectName "<ObjectName>" -FormName "<FormName>" [-SrcDir "<SrcDir>"]
```

## Что удаляется

```
<SrcDir>/<ObjectName>/Forms/<FormName>.xml     # Метаданные формы
<SrcDir>/<ObjectName>/Forms/<FormName>/         # Каталог формы (рекурсивно)
```

## Что модифицируется

- `<SrcDir>/<ObjectName>.xml` — убирается `<Form>` из `ChildObjects`
- Если удаляемая форма была DefaultForm — очищается значение DefaultForm

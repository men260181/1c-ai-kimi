# 1C AI Development Kit для Kimi Code

Готовый плагин Kimi Code с **55 навыками разработки на 1С:Предприятие 8.3**: метаданные, управляемые формы, СКД, расширения, роли, подсистемы, информационные базы, EPF/ERF, MXL, веб-клиент и тестирование.

Проект является адаптацией открытого комплекта [anymasoft/1c-ai](https://github.com/anymasoft/1c-ai). Сведения об исходном проекте и изменениях находятся в [NOTICE.md](NOTICE.md), благодарности авторам — в [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

## Импорт на свой компьютер

Требуется актуальная версия Kimi Code с поддержкой плагинов. Для установки по прямой ссылке репозиторий должен быть публичным.

Выполните в командной строке Kimi Code:

```text
/plugins install https://github.com/men260181/1c-ai-kimi
```

После установки откройте новую сессию:

```text
/new
```

Вместо `/new` можно выполнить `/reload`.

**Импорт не требует `git clone`, копирования каталога `skills`, скачивания ZIP или запуска PowerShell-установщика.** Плагин устанавливается на уровне пользователя и действует во всех проектах.

Проверка установки:

```text
/plugins list
/plugins info 1c-ai-kimi
/skill:1c-ai-kimi:form-patterns
```

### Обновление

Повторно выполните установку из репозитория и перезагрузите возможности:

```text
/plugins install https://github.com/men260181/1c-ai-kimi
/reload
```

Также можно открыть `/plugins`, найти установленный плагин и выбрать обновление.

### Удаление

```text
/plugins remove 1c-ai-kimi
/reload
```

## Программное обеспечение для работы навыков

Сам импорт плагина требует только Kimi Code. Дополнительное ПО зависит от используемых навыков.

| Программное обеспечение | Для чего требуется | Примечания |
|---|---|---|
| **Kimi Code Desktop или Kimi Code CLI** | Загрузка и вызов навыков | Нужна версия с поддержкой `/plugins install <GitHub URL>` |
| **Windows 10/11 и PowerShell 5.1+** | Основные сценарии генерации и проверки XML, работы с конфигурацией и базами | PowerShell 5.1 уже входит в Windows. Глобально менять политику выполнения не требуется: навыки используют `-ExecutionPolicy Bypass` только для отдельного запуска проверенного файла |
| **1С:Предприятие 8.3.24+** | Загрузка и выгрузка конфигураций, обновление ИБ, сборка EPF/ERF, публикация веб-клиента | Нужны `1cv8.exe`, подходящая лицензия и доступ к информационной базе. Путь обычно имеет вид `C:\Program Files\1cv8\<версия>\bin` |
| **Git 2.x** | `db-load-git`, контроль версий и командная разработка | Для импорта плагина Git не нужен |
| **Python 3.12 с Python Launcher (`py`)** | `img-grid` и дополнительные Python-утилиты | В Windows установите Python с опцией `py launcher`. Для `img-grid` дополнительно нужна Pillow |
| **Pillow** | Наложение сетки на изображение в `img-grid` | Установка: `py -3 -m pip install Pillow` |
| **Node.js 18+ и npm** | `web-test`, `playwright-test`, локальный Playwright MCP | Проверка: `node --version` и `npm --version` |
| **Chromium для Playwright** | UI-тесты и автоматизация веб-клиента | В тестовом проекте: `npx playwright install chromium`. Навык `web-test` содержит собственную инструкцию первоначальной настройки |
| **Apache 2.4 и веб-компоненты 1С** | `web-publish`, `web-info`, `web-stop`, `web-unpublish` | `web-publish` может скачать portable Apache. Для `wsap24.dll` нужен каталог `bin` платформы 1С |
| **ffmpeg** | Запись видео в расширенных сценариях `web-test` | Необязательно для обычных UI-проверок |

### Минимальный набор для разработки XML и работы с базой 1С

1. Kimi Code.
2. Windows с PowerShell 5.1+.
3. 1С:Предприятие 8.3.24+.
4. Git.

Python, Pillow, Node.js, Playwright, Apache и ffmpeg устанавливайте только для соответствующих сценариев.

### Проверка Python и Pillow

```powershell
py -3 --version
py -3 -m pip install Pillow
py -3 -c "import PIL; print(PIL.__version__)"
```

### Проверка Node.js и Playwright

```powershell
node --version
npm --version
```

Для автономных UI-тестов в проекте после создания тестовой инфраструктуры:

```powershell
npm install
npx playwright install chromium
```

## MCP-серверы

MCP-серверы **не входят в плагин** и не являются обязательными для базовых навыков генерации XML. Они нужны только для соответствующих расширенных возможностей:

- `1c-help-mcp` — сервер документации 1С или совместимый codemetadata;
- `bsp-patterns` — MCP с паттернами БСП/SSL;
- `1c-test-runner` — `1c-ai-debug` MCP и установленное в базе расширение `AI_Debug`;
- `1c-web-session` — Playwright MCP;
- проверки BSL и поиск шаблонов — соответствующие syntax checker, templates и BSL LSP MCP.

Настройка выполняется командой `/mcp-config` или в файле `.kimi-code/mcp.json` проекта. После изменения MCP-конфигурации откройте новую сессию. Адреса серверов и учётные данные должны быть вашими; в плагине нет преднастроенной чужой инфраструктуры.

## Использование

Навыки вызываются автоматически по описанию задачи. Ручной вызов использует пространство имён плагина:

```text
/skill:1c-ai-kimi:db-list
/skill:1c-ai-kimi:meta-compile
/skill:1c-ai-kimi:form-compile
/skill:1c-ai-kimi:inspect
/skill:1c-ai-kimi:validate
```

Для подготовки структуры нового проекта:

```text
/skill:1c-ai-kimi:1c-project-init
```

Навыки удаления могут быть намеренно ограничены ручным вызовом. Операции с информационными базами сначала выполняйте на разработческих копиях.

### Основные группы

| Группа | Навыки |
|---|---|
| Конфигурация и метаданные | `cf-init`, `cf-edit`, `meta-compile`, `meta-edit`, `meta-remove` |
| Формы | `form-add`, `form-compile`, `form-edit`, `form-patterns`, `form-remove`, `help-add` |
| Расширения | `cfe-init`, `cfe-borrow`, `cfe-patch-method`, `cfe-diff` |
| Базы данных | `db-create`, `db-list`, `db-run`, `db-update`, `db-dump-cf`, `db-load-cf`, `db-dump-xml`, `db-load-xml`, `db-load-git` |
| Внешние объекты и макеты | `epf-expert`, `erf-expert`, `mxl-expert` |
| СКД, роли и подсистемы | `skd-compile`, `skd-edit`, `role-expert`, `subsystem-expert` |
| Инспекция и проверка | `inspect`, `validate` |
| Веб-клиент и тестирование | `web-publish`, `web-info`, `web-stop`, `web-unpublish`, `web-test`, `1c-web-session`, `1c-test-runner`, `playwright-test` |
| Проектирование и совместная работа | `brainstorm`, `write-plan`, `subagent-dev`, `1c-project-init`, `1c-help-mcp`, `1c-query-opt`, `bsp-patterns`, `img-grid` |
| OpenSpec и сессии | `openspec-proposal`, `openspec-apply`, `openspec-archive`, `session-save`, `session-restore`, `session-retro` |

## Если навыки уже скопированы вручную

Не используйте одновременно этот плагин и старую ручную копию тех же навыков в `~/.kimi-code/skills`: иначе в каталоге появятся дубли с разными именами вызова. Оставьте один способ установки.

## Лицензия

Проект распространяется под лицензией MIT. Оригинальный текст лицензии сохранён в [LICENSE](LICENSE). Обязательно ознакомьтесь с [NOTICE.md](NOTICE.md) и [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

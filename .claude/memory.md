# Память проекта «Air & Paper»

> Центральный файл проектного контекста для Claude Code. Закоммичен в репозиторий,
> поэтому доступен под любой учётной записью, открывшей проект.
> Точка авто-загрузки — корневой `CLAUDE.md` (импортирует этот файл и `ToDo.md`).

## Проект

- **AirAndPaper** — **многопользовательская** 3D-игра на **Unity 6** (`6000.0.33f1`, URP) про бумажный самолётик с симуляцией полётной физики. Студия-разработчик — **PaperFly**.
- Имена: **PaperFly** — студия (верхний сегмент namespace), **AirAndPaper** — игра. Корневой namespace кода: `PaperFly.AirAndPaper.*`.
- Целевые платформы: **мобильные — Android и iOS** (ввод через виртуальные джойстики; есть также клавиатурный ввод через new Input System). Выбор бэкенда ввода — `InputInstaller` (Zenject) + `PlatformType`.
- Над проектом работает **команда**.
- Стек/зависимости: URP, Cinemachine (камера `CameramanController`, FOV от скорости), Input System, AI Navigation, Timeline (UPM); Zenject (DI), Odin/Sirenix, Utf8Json, NuGetForUnity (не-UPM); NoesisGUI (XAML-UI, UPM git-зависимость).
- LFS: `*.exr`, `*.glb` (см. `.gitattributes`).

## Целевая структура каталогов

Финальная нормализованная структура и инженерное обоснование ключевых решений — в [`structure.md`](../structure.md) (корень репозитория).

## Важные факты по зависимостям

- **Noesis** подключается как **UPM git-зависимость** (Add package from git URL, приватный репо) — одна строка в `manifest.json`, физически резолвится в gitignore-нутый `Library/PackageCache`. НЕ submodule, НЕ embedded. Сейчас на ветке master строки в manifest нет (устаревший csproj ссылается на отсутствующий пакет).
- **Odin** (актуальная 4.0) поддерживает кастомный путь установки (`PathLookup.asset`/`SirenixAssetPaths`) и сам корректно обновляется на любом расположении — переносить безопасно.
- В игровом коде сейчас НЕТ ни одного `.asmdef` — монолитная `Assembly-CSharp`.

## Отложенные задачи

См. [`ToDo.md`](ToDo.md).

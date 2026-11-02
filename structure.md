# Целевая структура проекта «Air & Paper» (Unity 6)

> Итоговая нормализованная структура каталогов, к которой приводится проект.

```
Game/                                  ← корень репозитория
├── Assets/
│   ├── Backend/
│   ├── Client/                       ← КОРЕНЬ кода и контента игры (вместо _Project)
│   │   ├── Configuration/
│   │   │   ├── Addressables/         (бывш. AddresableAssetData — настройки/группы/профили Addressables)
│   │   │   ├── Rendering/            (бывш. Renderer/ — URP RPAsset, Renderers, Volume Profiles)
│   │   │   └── Input/                (FlightInput.inputactions + генерируемый класс)
│   │   ├── Content/                  ← raw-исходники (Models, Textures, Sprites, Materials, Animations), было размазано по Resources/*
│   │   │   ├── Animations/
│   │   │   ├── Audio/
│   │   │   ├── Graphics/             (2D UI-графика — вектор/спрайты интерфейса)
│   │   │   ├── Fonts/
│   │   │   ├── Localization/         (бывш. Resources/Localizations)
│   │   │   ├── Materials/
│   │   │   ├── Models/               (FBX, GLB-LFS)
│   │   │   ├── Textures/
│   │   │   └── Sprites/
│   │   ├── Editor/
│   │   ├── Resources/                (ТОЛЬКО то, что реально грузится через Resources.Load)
│   │   ├── Reuse/
│   │   │   ├── Prefabricated/
│   │   │   └── Scriptable/
│   │   ├── Scenes/
│   │   │   ├── Internal/
│   │   │   └── Views/
│   │   └── src/
│   │       ├── Contracts/
│   │       ├── Data/
│   │       │   ├── Models/
│   │       │   └── Types/
│   │       ├── Ex/
│   │       ├── Gamedesign/
│   │       ├── Gameplay/
│   │       │   ├── Gamemodes/
│   │       │   └── Plane/
│   │       ├── Hub/                  (около-игровой UI / meta: экраны — отдельными каталогами по имени, кроме MainWindow)
│   │       │   ├── Base/
│   │       │   ├── SplashScreen/
│   │       │   ├── MainWindowViewModel.cs
│   │       │   ├── MainWindowView.xaml.cs
│   │       │   └── MainWindowView.xaml
│   │       ├── Infrastructure/
│   │       │   ├── Camera/
│   │       │   └── Input/
│   │       ├── Installers/
│   │       │   └── Switches/
│   │       ├── Services/
│   │       └── Tests/
│   ├── Packages/                     ← всё, что НЕ через UPM (.unitypackage / Asset Store): Zenject, Sirenix/Odin, Utf8Json, NuGet + влитый Joystick Pack
│   │   ├── JoystickPack/
│   │   ├── NuGetForUnity/            (сам инструмент NuGetForUnity)
│   │   ├── NuGetPackages/            (управляется NuGetForUnity автоматически; repositoryPath в NuGet.config)
│   │   ├── Sirenix/                  (Odin)
│   │   ├── Utf8Json/
│   │   └── Zenject/
│   ├── Plugins/                      ← Native-плагины (платформозависимые)
│   │   ├── Android/
│   │   └── iOS/
│   └── NuGet.config
├── Library/                          ← автогенерируемый кэш — не трогать никогда, .gitignore
├── Packages/                         ← UPM-зависимости (Cinemachine, URP, Input System, AI Navigation, Noesis как git-пакет)
└── ProjectSettings/
```

## Ключевые решения

### Ассеты и ресурсы вынесены из `Resources/`в `Content/`

`Resources/` — зарезервированная папка Unity с жёсткой семантикой: всё её содержимое **безусловно** включается в билд (без tree-shaking — даже неиспользуемые ассеты), упаковывается в единый бандл и доступно только по строковому пути через `Resources.Load`. Прямых ссылок нет → ассеты не выгружаются автоматически и не верифицируются на этапе сборки. Хранение там всего арта раздувает размер билда и увеличивает время старта (весь бандл индексируется при инициализации).

Raw-исходники (`Models`, `Textures`, `Sprites`, `Materials`, `Animations`, `Audio`, `Localization`) вынесены в обычный каталог `Content/`, где работают по прямым ссылкам/Addressables — с ленивой загрузкой, выгрузкой и контролем зависимостей на этапе сборки. В `Resources/` остаётся **только** то, что действительно требует загрузки по строковому пути в рантайме. Это снимает безусловный вклад арта в билд и убирает антипаттерн «всё через `Resources.Load`».

### Подключаемые пакеты разведены по источникам

Каждый механизм управления зависимостями имеет **ровно одно** расположение; смешивать их нельзя, иначе теряется граница «управляемое автоматически vs вендоренное вручную» и ломается стратегия VCS.

#### Корневой `Packages/` — домен UPM
`manifest.json` фиксирует зависимости, UPM резолвит их в `Library/PackageCache` (read-only, под `.gitignore`). В репозиторий попадают только манифест и lock-файл. **Noesis** подключён сюда как **git-зависимость** (одна строка-ссылка в манифесте) — пакет восстанавливается в gitignore-нутый `PackageCache`, поэтому его ~1k файлов не засоряют репозиторий. Это «resolved-зависимости», а не исходники проекта.

#### `Assets/Packages/` — не-UPM импорты
То, что поставляется как `.unitypackage` / Asset Store / ручной drop и не имеет UPM-дистрибуции (Zenject, Odin, Utf8Json, JoystickPack, сам инструмент NuGetForUnity). Эти артефакты **коммитятся** в VCS как часть проекта — UPM их не восстановит. Каждая библиотека — отдельный подкаталог.

#### `Assets/Packages/NuGetPackages/` — выход NuGetForUnity
Изолированная песочница (`repositoryPath` в `NuGet.config`), куда инструмент **автоматически** скачивает NuGet-пакеты и их транзитивные зависимости. Восстанавливается из `packages.config`, поэтому может уходить под `.gitignore`. Вынесено в отдельный подкаталог сознательно: (1) не смешивать авто-управляемое с вендоренным; (2) держать рабочую директорию инструмента изолированной от ручных пакетов; (3) сделать gitignore тривиальным (одна строка).

#### `Plugins/` — только для native-плагинов
`Plugins/` — зарезервированная папка Unity, здесь оставлена как **задел на будущее**: под нативные SDK (аналитика, реклама, платформенные интеграции), которые раскладываются по платформенным подпапкам `Android/` и `iOS/`. Подпапки дают Unity авто-конфигурацию таргет-платформы/архитектуры (Gradle, манифесты, ABI) — конвенция, дополняющая настройки импортёра.

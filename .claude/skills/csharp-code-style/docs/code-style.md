# C# Code Style — регламент проекта

Источник правды по стилю кода. Этот документ — референс, читается людьми
(ревью, онбординг новичков) и агентом (Claude Code), но не содержит
инструкций «как агент должен работать» — это вынесено в SKILL.md.

При расхождении этого документа и автоматических правил из `.editorconfig` —
приоритет у этого документа.

---

## §1 Общие принципы

- Не удалять методы расширения и инфраструктурные классы, даже если на них
  «нет ссылок» в текущем графе вызовов. Подобный код часто используется
  через DI, рефлексию, source generators.
- Не объединять рефакторинг стиля и изменение бизнес-логики в одном коммите.
- Один коммит = одно намерение.

---

## §2 Отступы и переносы

### Базовые правила

- Отступ — 4 пробела (TAB при сохранении расширяется в 4 пробела).
- Максимальная длина строки — ориентир 140 символов, hard limit отсутствует
  (читаемость важнее).
- Пустые строки — между логическими блоками, не больше одной подряд.
- Перед `return`, `throw`, `if`, `foreach`, `using` — пустая строка от
  предшествующего кода.

### Составное выражение в присваивании

Когда в правой части `=`, `+=`, `-=` и т.п. составное выражение из 2+ операндов
с операторами:

- Знак `=` (или `+=`, `-=`) — в конце первой строки, после имени переменной.
- Первый операнд — на следующей строке с +1 TAB от переменной.
- Каждый последующий оператор + операнд — на отдельной строке, операнды
  выровнены под первым.
- Оператор стоит **перед** операндом, не после.

```csharp
// ПРАВИЛЬНО
this.PitchInput =
   -this.PitchAngle
  * this.autoPitchLevel;

// ПРАВИЛЬНО
this.PitchInput -=
    Mathf.Abs(
      this.bankedTurnAmount
    * this.bankedTurnAmount
    * this.autoTurnPitch);

// ЗАПРЕЩЕНО
this.PitchInput = -this.PitchAngle * this.autoPitchLevel;
```

### Конкатенация строк

```csharp
// ПРАВИЛЬНО
private static string BuildUrl(Settings settings)
    => "https://graph.instagram.com/access_token"
     + "?grant_type=ig_exchange_token"
     + $"&client_secret={settings.ClientSecret}"
     + $"&access_token={settings.AccessToken}";

// ЗАПРЕЩЕНО
private static string BuildUrl(Settings settings)
    => "https://graph.instagram.com/access_token" + "?grant_type=ig_exchange_token";
```

### Арифметика

```csharp
// ПРАВИЛЬНО
var score =
    successRate
  * parameters.Uptime
  * inversePing
  * speedFactor
  * parameters.Weight
  - parameters.PingMs / 100.0;

// ЗАПРЕЩЕНО
var score = successRate * parameters.Uptime * inversePing * speedFactor;
```

### Вложенные выражения

Каждый уровень вложенности имеет свои столбцы операндов и операторов.

```csharp
var result =
    Math.Exp(
        -Math.Pow(x - mu, 2)
      / (2 * Math.Pow(sigma, 2)))
  / (sigma * Math.Sqrt(2 * Math.PI))
  + (offset * logicalScale)
  - (correctionFactor / smoothingValue);
```

### Интерполяция в составной строке

```csharp
// ПРАВИЛЬНО
var message =
    $"User {user.Name}"
  + $" (ID: {user.Id})"
  + $" has {user.OrderCount} orders";

// ЗАПРЕЩЕНО
var message = $"User {user.Name}" + $" (ID: {user.Id})" + $" has {user.OrderCount} orders";
```

### LINQ

Каждый метод цепочки — с новой строки, с +1 TAB от источника.

```csharp
public IEnumerable<Account> GetActiveVerifiedAccounts(IEnumerable<Account> accounts)
    => accounts
        .Where(account => account.IsActive)
        .Where(account => account.IsVerified)
        .OrderByDescending(account => account.CreatedAt)
        .Select(account => account);

public void Foo()
{
    var filteredAccounts =
        accounts
            .Where(account => account.IsActive)
            .Where(account => account.IsVerified)
            .OrderByDescending(account => account.CreatedAt)
            .Select(account => account)
            .ToList();
}
```

### Составное булевое выражение

Операторы `||` и `&&` — в начале строки.

```csharp
if (string.IsNullOrEmpty(str1)
 || string.IsNullOrEmpty(str2))
{
    ...
}

public IEnumerable<Account> GetEligibleAccounts(IEnumerable<Account> accounts)
    => accounts
        .Where(account =>
            account.IsActive
            && account.IsVerified
            && !account.IsBlocked)
        .ToList();
```

### Throw

- Перед `throw` — пустая строка.
- `new` — на следующей строке после `throw`.
- Последний символ `w` от `throw` и `new` — на одной и той же позиции
  в строке (вертикальное выравнивание).

```csharp
throw
  new InvalidOperationException("Сообщение об ошибке.");

catch (HttpRequestException ex)
{
    this.logger.LogError(ex, "Ошибка.");

    throw;
}
```

### Expression-body (`=>`)

`=>` — на новой строке, с +1 TAB от объявления.

```csharp
public bool IsExpired
    => DateTime.UtcNow.AddDays(2) > this.AccessTokenUpdatedAt.AddSeconds(this.ExpiresInSeconds);

public Task SaveAsync<T>(string key, T value)
    => this.client.SetSecretAsync(
        this.NormalizeKey(key),
        JsonSerializer.Serialize(value));
```

### Return

Перед `return` — пустая строка от предшествующего кода.

```csharp
var result = this.Compute();

return result;
```

---

## §3 Именование

### Запреты

- Сокращения: `res`, `usr`, `msg`, `btn`, `cnt`, `cfg`, `ctx`, `repo`, `svc`.
- Бессмысленные имена: `data`, `info`, `value`, `item`, `obj`, `temp`.

### Префиксы

- Булевые переменные и свойства — с префиксом `is`, `has`, `can`, `should`.
- Интерфейсы — с префикса `I` (`IUserRepository`).
- Параметры обобщённых типов — с префикса `T` (`TKey`, `TValue`).

### Часть речи

- Классы — существительные (`UserRepository`, `TokenValidator`).
- Методы — начинаются с глагола (`GetAsync`, `Validate`, `BuildUrl`).

### Неизбыточность

Если в классе одна фабрика — называй `factory`, не `httpClientFactory`.
Не уточняй то, что и так понятно из контекста класса.

```csharp
// ПРАВИЛЬНО
var isExpired = token.ExpiresAt < DateTime.UtcNow;
var hasAdminAccess = user.Role == Role.Admin;
var response = await this.GetAsync(id);
var tokenLifetimeSeconds = token.ExpiresInSeconds;

// ЗАПРЕЩЕНО
var res = await this.GetAsync(id);
var expired = token.ExpiresAt < DateTime.UtcNow;
var data = await this.client.GetAsync(url);
```

### Casing

- `PascalCase` — типы, public/protected/internal члены, константы,
  static readonly поля.
- `camelCase` — параметры, локальные переменные, private поля
  (без подчёркивания).

---

## §4 Структура проекта

- Все абстрактные классы и интерфейсы → `Abstractions/`.
- Все базовые классы → `Base/`.

```
Providers/
├── Abstractions/
│   ├── ISubscribersCountProvider.cs
│   └── ITokenProvider.cs
├── Base/
│   └── SubscribersCountHttpProvider.cs
├── Instagram/
│   ├── Models/
│   └── InstagramProvider.cs
└── TikTok/
    ├── Models/
    └── TikTokProvider.cs
```

---

## §5 Пространства имён (using)

### Порядок блоков

1. Системные (`System.*`)
2. Microsoft (`Microsoft.*`)
3. Сторонние библиотеки (3rd party)
4. Внутренние библиотеки (submodules, dll)
5. Текущий проект
6. Алиасы (namespace — с маленькой буквы, класса — с большой)
7. Статичные `using static` (избегать)

Внутри каждого блока — алфавитный порядок. Между блоками — пустая строка.

```csharp
// Системные
using System.IO;
using System.Linq;

// Microsoft
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;

// 3rd party
using AutoMapper.Internal;
using FluentValidation;

// Внутренние библиотеки
using Demo.Infrastructure.Models;

// Текущий проект
using Demo.Domain;
using Demo.Domain.Providers;

// Алиасы namespace-а — с маленькой буквы
using settings = Demo.Models.Settings;

// Алиасы класса — с большой буквы
using Math = Demo.Providers.Math;

// Статичные using-и
using static Demo.Common.AppConstants;
```

---

## §6 Классы

### Принципы

- Один класс — одна ответственность. При нарушении — разбивай.
- При дублировании свойств/логики — выноси в базовый класс или интерфейс.
- Класс без наследников — `sealed`.
- При разрастании — допускается `partial`. Имя файла: `ClassName.PartName.cs`.

### Порядок блоков внутри класса

1. Поля
2. Свойства
3. Конструкторы
4. Методы
5. Вложенные классы

### Конструкторы

- Сортируются по убыванию числа параметров.
- 2+ параметров — каждый на отдельной строке.
- Допускаются primary-конструкторы (C# 12+).

```csharp
// Primary-конструктор
public sealed class InstagramProvider(
    IOptions<Instagram> instagram,
    IHttpClientFactory factory,
    ISecretStore store)
    : SubscribersCountHttpProvider(factory)
{
    ...
}

// Обычный конструктор
public InstagramProvider(
    IOptions<Instagram> instagram,
    IHttpClientFactory factory,
    ISecretStore store)
    : base(factory)
{
    this.factory = factory;
    this.store = store;
}

// Один параметр — одна строка
public TokenValidator(ISecretStore store)
{
    ...
}
```

### Порядок методов

1. По модификатору: `protected` → `private` → `public`.
2. Внутри модификатора по перегрузке: `override` → `abstract` → `virtual`
   → обычные.
3. Внутри перегрузки — по убыванию числа параметров.

### Порядок методов в ASP.NET контроллерах и сервисах/репозиториях

1. Export (возвращает файлы)
2. GetMany → GetAll → Get
3. Create
4. Update
5. Delete

---

## §7 Документация (комментарии)

### XML-документация

- Описание метода **не** содержит слово «метод», описание класса — «класс».
- Комментарии в тегах — одна строка, заканчивается точкой.
- `<param/>`, `<returns/>`, `<exception/>` — никогда не пустые.
- При реализации интерфейса — `<inheritdoc/>`.
- Если у реализации есть особенности — собственный комментарий вместо
  `<inheritdoc/>`.

```csharp
/// <summary>Получает подписчиков по идентификатору аккаунта.</summary>
/// <param name="accountId">Идентификатор аккаунта.</param>
/// <returns>Список подписчиков.</returns>
/// <exception cref="InvalidOperationException">Если аккаунт не найден.</exception>
public Task<List<Subscriber>> GetSubscribersAsync(Guid accountId)
```

```csharp
// Стандартный случай
/// <inheritdoc/>
public Task<int> GetSubscribersCountAsync(string accountId)

// Особенности реализации
/// <summary>
/// Получает количество подписчиков через TikTok API.
/// Результат кешируется на 15 минут, поскольку TikTok ограничивает частоту запросов.
/// </summary>
public Task<int> GetSubscribersCountAsync(string accountId)
```

### Inline-комментарии

Внутри методов комментировать только нетривиальные вычисления с неочевидными
константами.

```csharp
// Алгоритм ранжирования Hacker News: чем старше пост, тем быстрее падает рейтинг.
// Показатель степени 1.8 — эмпирически подобранный коэффициент затухания.
var score =
    (double)upvotes
  / Math.Pow(ageHours + 2, 1.8);
```

---

## §8 Атрибуты

- Каждый атрибут — в отдельных квадратных скобках на отдельной строке.
- Не объединять несколько атрибутов в одних скобках.
- Не размещать атрибуты на одной строке с объявлением.

```csharp
// ПРАВИЛЬНО
[HttpGet]
[Authorize]
[ProducesResponseType(StatusCodes.Status200OK)]
public Task<IActionResult> GetAsync()

// ЗАПРЕЩЕНО
[HttpGet, Authorize]
public Task<IActionResult> GetAsync()
```

---

## §9 Явные квалификаторы `this` и `base`

- `this.` — при обращении к членам текущего класса.
- `base.` — при обращении к членам родительского класса.
- Без квалификатора — никогда (для членов класса).

```csharp
public sealed class InstagramProvider : SubscribersCountHttpProvider
{
    private readonly ISecretStore store;

    public InstagramProvider(
        IHttpClientFactory factory,
        ISecretStore store)
        : base(factory)
    {
        this.store = store;
    }

    public override async Task<int> GetSubscribersCountAsync(string accountId)
    {
        var token = await this.LoadTokenAsync();

        return await base.GetSubscribersCountAsync(accountId);
    }
}
```

---

## §10 Ключевые слова

### catch

- Имя переменной — всегда `ex`.
- Голый `Exception` без необходимости не перехватывать — сужать тип.
- Пустой `catch`-блок не оставлять.
- Логировать детали исключения.
- Для повторного выброса — `throw;` (сохраняет stack trace).
- При оборачивании — оригинальное исключение передавать как `innerException`.

```csharp
// ПРАВИЛЬНО
catch (HttpRequestException ex)
{
    this.logger.LogError(ex, "Ошибка при получении данных от Instagram API.");

    throw;
}

// ПРАВИЛЬНО — оборачивание
catch (JsonException ex)
{
    this.logger.LogError(ex, "Ошибка десериализации токена.");

    throw
      new InvalidOperationException("Не удалось десериализовать токен Instagram.", ex);
}

// ЗАПРЕЩЕНО — голый Exception, нет логирования, потерян innerException
catch (Exception ex)
{
    throw
      new InvalidOperationException("Что-то пошло не так.");
}
```

### if

- Всегда фигурные скобки, даже для однострочного тела.

```csharp
// ПРАВИЛЬНО
if (token.IsExpired)
{
    await this.RefreshTokenAsync(token);
    await this.SaveTokenAsync(token);
}

// ЗАПРЕЩЕНО
if (token.IsExpired)
    await this.RefreshTokenAsync(token);
```

### Regex

- Всегда `[GeneratedRegex]`, не инлайн `new Regex(...)`.

### using

- Всегда фигурные скобки для `using`.
- Исключение: несколько последовательных `using` подряд — допустима форма
  `using var`.

```csharp
// ПРАВИЛЬНО
using (var stream = new FileStream(path, FileMode.Open))
{
    ...
}

// ИСКЛЮЧЕНИЕ
using var reader = new StreamReader(path);
using var writer = new StreamWriter(output);
```

---

## §11 Методы и параметры

### Принципы метода

- Один метод — одна вещь. Название содержит «и» — разбивать.
- Размер — не более 20–30 строк (один экран).

### Правило параметров (объявление и вызов)

- 2+ параметра/аргумента — каждый на отдельной строке.
- Первый параметр/аргумент — на новой строке после `(`, с +1 TAB от метода.
- Применяется и к объявлению, и к вызову.
- Не оставлять первый параметр на строке с именем метода и выравнивать
  остальные по скобке.

### Правило переноса при вызове с присваиванием

**Универсальный детектор: если в строке есть `= ИМЯ(...)` или
`= НЕЧТО.ИМЯ(...)`, и внутри скобок 2 или больше аргументов через
запятые — это нарушение. Точка.**

Перечисленные ниже факторы НЕ являются исключениями и НЕ влияют на
применение правила:

- Длина итоговой строки.
- Длина имени метода или типа.
- Краткость аргументов (литералы, переменные одной буквы, `-1`, `0f`, `null`).
- Тип вызова: статический метод, instance-метод, конструктор `new`,
  метод расширения, fluent-метод, generic-метод.
- Совпадение левой части и одного из аргументов (`x = Foo(x, ...)`):
  это всё ещё вызов с 2+ аргументами, не «обновление переменной».
- Левая часть — свойство (`this.X = ...`), поле, локальная переменная,
  индексатор (`array[i] = ...`).
- Контекст: внутри метода, внутри лямбды, внутри switch-выражения,
  внутри тернарного.

Все случаи ниже — **нарушения**, требующие переписать в многострочную форму:

```csharp
// Self-assignment — НАРУШЕНИЕ
this.ThrottleInput = Mathf.Clamp(this.ThrottleInput, -1, 1);
this.PitchInput = Mathf.Clamp(this.PitchInput, -1f, 1f);
position.x = Mathf.Lerp(position.x, target.x, dt);

// Короткий статический метод — НАРУШЕНИЕ
var flatRight = Vector3.Cross(Vector3.up, flatForward);
var min = Math.Min(a, b);
var path = Path.Combine(root, fileName);

// Свойство присваивается из вызова — НАРУШЕНИЕ
this.Position = Vector3.Lerp(start, end, t);
this.Velocity = Vector3.ClampMagnitude(velocity, maxSpeed);

// Аргументы — литералы — НАРУШЕНИЕ (литералы не отменяют правило)
var color = new Color(1f, 0f, 0f);
var bounds = new Bounds(Vector3.zero, Vector3.one);
```

- При вызове с **1 аргументом** + присваивание → одна строка:
  `var x = Foo(a);` — переносов нет.
- При вызове с **2+ аргументами** + присваивание → перенос **после** `=`:

```
var name =
    Method(
        arg1,
        argN);
```

Структура отступов для 2+ аргументов с присваиванием:

1. `var name =` — строка присваивания, заканчивается знаком `=`.
2. `    Method(` — следующая строка, +1 TAB от `var`. Имя метода и
   открывающая скобка. Если есть `await` — `    await this.Method(`.
3. `        arg1,` — следующая строка, +2 TAB от `var`. Первый аргумент.
4. `        argN);` — последний аргумент, закрывающая скобка, `;`.

### Корректные переписывания нарушений выше

```csharp
// Self-assignment
this.ThrottleInput =
    Mathf.Clamp(
        this.ThrottleInput,
        -1,
        1);

this.PitchInput =
    Mathf.Clamp(
        this.PitchInput,
        -1f,
        1f);

position.x =
    Mathf.Lerp(
        position.x,
        target.x,
        dt);

// Короткий статический метод
var flatRight =
    Vector3.Cross(
        Vector3.up,
        flatForward);

var min =
    Math.Min(
        a,
        b);

var path =
    Path.Combine(
        root,
        fileName);

// Свойство присваивается из вызова
this.Position =
    Vector3.Lerp(
        start,
        end,
        t);

this.Velocity =
    Vector3.ClampMagnitude(
        velocity,
        maxSpeed);

// Литералы как аргументы
var color =
    new Color(
        1f,
        0f,
        0f);

var bounds =
    new Bounds(
        Vector3.zero,
        Vector3.one);
```

### Полные примеры

```csharp
// ═══════════════════════════════════════════
// ОБЪЯВЛЕНИЕ
// ═══════════════════════════════════════════
// ПРАВИЛЬНО
protected async Task<string> GetJsonResponseAsync(
    string request,
    AuthenticationHeaderValue authentication,
    CancellationToken cancellationToken)

// ЗАПРЕЩЕНО — параметры на одной строке
protected async Task<string> GetJsonResponseAsync(string request, AuthenticationHeaderValue authentication, CancellationToken cancellationToken)

// ЗАПРЕЩЕНО — первый параметр на строке с методом, остальные выровнены по скобке
private void SetAngle(float currentAngle,
                      int animHash,
                      float input,
                      float maxAngle,
                      float delta)

// ═══════════════════════════════════════════
// ВЫЗОВ С ПРИСВАИВАНИЕМ — 1 аргумент
// ═══════════════════════════════════════════
// ПРАВИЛЬНО — одна строка
var hash = Animator.StringToHash("Roll");
var token = await this.LoadTokenAsync();
var encoded = Convert.ToBase64String(bytes);
this.IsActive = this.Validate(token);

// ЗАПРЕЩЕНО — ненужный перенос для 1 аргумента
var hash =
    Animator.StringToHash("Roll");
```

### Разбиение метода с двумя ответственностями

```csharp
// ЗАПРЕЩЕНО — метод делает две вещи
private async Task FetchAndSaveTokenAsync()
{
    var token = await this.client.GetTokenAsync();
    await this.store.SaveAsync("instagram-token", token);
}

// ПРАВИЛЬНО — разделено
private async Task<Token> FetchTokenAsync()
    => await this.client.GetTokenAsync();

private async Task SaveTokenAsync(Token token)
    => await this.store.SaveAsync(
        "instagram-token",
        token);
```

---

## §12 Константы

- Магические строки, числа и конфигурационные ключи — в `Constants.cs`.
- Не дублировать статичные значения по проекту.
- Структурировать по вложенным статичным классам по домену.

```csharp
internal static class Constants
{
    internal static class Instagram
    {
        internal const string TokenSecretKey = "instagram-token";

        internal const string BaseUrl = "https://graph.instagram.com";

        internal const int TokenExpirationBufferDays = 2;
    }

    internal static class TikTok
    {
        internal const string TokenSecretKey = "tiktok-token";

        internal const string BaseUrl = "https://open.tiktokapis.com";
    }
}
```

---

## §13 Сравнение строк

- Только `string.Equals(a, b, StringComparison.OrdinalIgnoreCase)`.
- Не использовать `a == b` для строк.
- Не использовать `a.Equals(b, ...)` — только статичный `string.Equals`.

```csharp
// ПРАВИЛЬНО
if (string.Equals(token.Type, "Bearer", StringComparison.OrdinalIgnoreCase))
{
    ...
}

// ЗАПРЕЩЕНО
if (token.Type == "Bearer")
{
    ...
}

// ЗАПРЕЩЕНО
if (token.Type.Equals("Bearer", StringComparison.OrdinalIgnoreCase))
{
    ...
}
```

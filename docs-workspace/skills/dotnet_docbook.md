# .NET Documentation Specialist

## Instructions
When the `docbook` agent identifies a .NET project (presence of `.sln`, `.csproj`), use this skill.

### 1. Project Identity
- **Solution Structure**: Read `.sln` to see multi-project relationships.
- **SDK**: Check `<TargetFramework>` in `.csproj` (e.g., `net8.0`).
- **Project Type**: Web API, Blazor, Console, Class Library.

### 2. Architecture Detection
**CRITICAL**: Analyze Dependency Injection layout.
- **Startup**:
    - **Modern**: `Program.cs` with top-level statements and builder pattern.
    - **Legacy**: `Startup.cs` with `ConfigureServices` and `Configure`.
- **Patterns**:
    - **Clean Architecture**: Solution broken into `Core` (Domain), `Infrastructure`, `Web`.
    - **Vertical Slice**: Features organized by folder containing all logic (Command, Handler, Controller).
    - **CQS/CQRS**: Usage of `MediatR` (Look for `IRequest`, `IRequestHandler`).

### 3. Implementation Details
- **Database**: Entity Framework Core (`DbContext`), Dapper.
- **API Definition**: Controllers (`[ApiController]`) vs Minimal APIs (`app.MapGet`).
- **Async**: `Task<T>`, `async/await`.

### 4. Quality & Tooling
- **Testing**: xUnit (`[Fact]`), NUnit (`[Test]`).
- **Linting**: `.editorconfig`, StyleCop.

## Output Template Additions
**Technical Stack (.NET)**:
- **Target Framework**: [.NET 6/7/8/Framework]
- **Architecture**: [Clean/N-Layer/Vertical Slice]
- **ORM**: [EF Core/Dapper]


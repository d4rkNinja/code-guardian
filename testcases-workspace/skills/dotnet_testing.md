# .NET / C# Test Generation

## Overview
.NET and C# applications require comprehensive testing strategies focusing on ASP.NET Core APIs, service layers, and Entity Framework integrations. This guide provides patterns using xUnit, NUnit, MSTest, and FluentAssertions.

## Testing Framework Selection

### **xUnit** (Recommended for new projects)
- **Best for**: Modern .NET applications
- **Strengths**: Clean syntax, parallel execution, extensibility
- **Version**: Use xUnit 2.4+ for .NET 6/7/8

### **NUnit** (Enterprise standard)
- **Best for**: Existing projects, complex test scenarios
- **Strengths**: Rich assertion library, test fixtures, parameterized tests

### **MSTest** (Microsoft's framework)
- **Best for**: Visual Studio integration
- **Strengths**: Native MS tooling support, datacdriven tests

### **Moq** (Mocking)
- **Best for**: Mocking dependencies
- **Strengths**: Fluent API, LINQ-based verification

### **FluentAssertions**
- **Best for**: Readable assertions
- **Strengths**: Natural language assertions, detailed error messages

---

## Test Generation Patterns

### **1. ASP.NET Core API Testing**

#### **Example: Testing API with WebApplicationFactory**
```csharp
// tests/Integration/Api/UsersApiTests.cs
using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace MyApp.Tests.Integration.Api;

public class UsersApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UsersApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CreateUser_WithValidData_ReturnsCreated()
    {
        // Arrange
        var newUser = new
        {
            Email = "test@example.com",
            Username = "testuser",
            Password = "SecurePass123!"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/users", newUser);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var createdUser = await response.Content.ReadFromJsonAsync<UserDto>();
        createdUser.Should().NotBeNull();
        createdUser!.Email.Should().Be(newUser.Email);
        createdUser.Username.Should().Be(newUser.Username);
        createdUser.Id.Should().NotBeEmpty();
    }

    [Fact]
    public async Task CreateUser_WithInvalidEmail_ReturnsBadRequest()
    {
        var invalidUser = new { Email = "invalid-email", Username = "user" };

        var response = await _client.PostAsJsonAsync("/api/users", invalidUser);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
        var error = await response.Content.ReadFromJsonAsync<ValidationProblemDetails>();
        error!.Errors.Should().ContainKey("Email");
    }

    [Fact]
    public async Task GetUser_WithValidId_ReturnsUser()
    {
        var userId = await CreateTestUserAsync();

        var response = await _client.GetAsync($"/api/users/{userId}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var user = await response.Content.ReadFromJsonAsync<UserDto>();
        user!.Id.Should().Be(userId);
    }

    [Fact]
    public async Task GetUser_WithInvalidId_ReturnsNotFound()
    {
        var response = await _client.GetAsync("/api/users/00000000-0000-0000-0000-000000000000");
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Theory]
    [InlineData("")]
    [InlineData("short")]
    [InlineData("no-at-sign.com")]
    public async Task CreateUser_WithInvalidEmails_ReturnsBadRequest(string invalidEmail)
    {
        var user = new { Email = invalidEmail, Username = "test", Password = "Pass123!" };

        var response = await _client.PostAsJsonAsync("/api/users", user);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
```

---

### **2. Service Layer Testing**

```csharp
// tests/Unit/Services/PaymentServiceTests.cs
using Moq;
using FluentAssertions;
using Xunit;

namespace MyApp.Tests.Unit.Services;

public class PaymentServiceTests
{
    private readonly Mock<IPaymentRepository> _paymentRepositoryMock;
    private readonly Mock<IOrderRepository> _orderRepositoryMock;
    private readonly Mock<IPaymentGateway> _paymentGatewayMock;
    private readonly PaymentService _sut;

    public PaymentServiceTests()
    {
        _paymentRepositoryMock = new Mock<IPaymentRepository>();
        _orderRepositoryMock = new Mock<IOrderRepository>();
        _paymentGatewayMock = new Mock<IPaymentGateway>();
        _sut = new PaymentService(
            _paymentRepositoryMock.Object,
            _orderRepositoryMock.Object,
            _paymentGatewayMock.Object
        );
    }

    [Fact]
    public async Task ProcessPayment_WithValidData_ShouldSucceed()
    {
        // Arrange
        var order = new Order { Id = 1, Amount = 99.99m, Status = "PENDING" };
        var chargeResult = new ChargeResult { Success = true, TransactionId = "txn_123" };

        _orderRepositoryMock
            .Setup(x => x.GetByIdAsync(1))
            .ReturnsAsync(order);

        _paymentGatewayMock
            .Setup(x => x.ChargeAsync(It.IsAny<decimal>(), It.IsAny<string>()))
            .ReturnsAsync(chargeResult);

        // Act
        var result = await _sut.ProcessPaymentAsync(1, "tok_valid_card");

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
        result.TransactionId.Should().Be("txn_123");

        _paymentGatewayMock.Verify(
            x => x.ChargeAsync(99.99m, "tok_valid_card"),
            Times.Once
        );

        _orderRepositoryMock.Verify(
            x => x.UpdateAsync(It.Is<Order>(o => 
                o.Status == "PAID" && 
                o.TransactionId == "txn_123"
            )),
            Times.Once
        );
    }

    [Fact]
    public async Task ProcessPayment_WhenPaymentFails_ShouldRollback()
    {
        // Arrange
        var order = new Order { Id = 1, Amount = 99.99m, Status = "PENDING" };

        _orderRepositoryMock
            .Setup(x => x.GetByIdAsync(1))
            .ReturnsAsync(order);

        _paymentGatewayMock
            .Setup(x => x.ChargeAsync(It.IsAny<decimal>(), It.IsAny<string>()))
            .ThrowsAsync(new PaymentGatewayException("Payment declined"));

        // Act
        Func<Task> act = async () => await _sut.ProcessPaymentAsync(1, "tok_declined");

        // Assert
        await act.Should().ThrowAsync<PaymentProcessingException>()
            .WithMessage("*Payment failed*");

        _orderRepositoryMock.Verify(
            x => x.UpdateAsync(It.IsAny<Order>()),
            Times.Never
        );
    }
}
```

---

### **3. Entity Framework Integration Testing**

```csharp
// tests/Integration/Repositories/UserRepositoryTests.cs
using Microsoft.EntityFrameworkCore;
using FluentAssertions;
using Xunit;

namespace MyApp.Tests.Integration.Repositories;

public class UserRepositoryTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly UserRepository _repository;

    public UserRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        _repository = new UserRepository(_context);
    }

    [Fact]
    public async Task Create_Should SaveUserToDatabase()
    {
        // Arrange
        var user = new User
        {
            Email = "test@example.com",
            Username = "testuser",
            PasswordHash = "hashed_password"
        };

        // Act
        var created = await _repository.CreateAsync(user);
        await _context.SaveChangesAsync();

        // Assert
        created.Id.Should().NotBeEmpty();
        var found = await _context.Users.FindAsync(created.Id);
        found.Should().NotBeNull();
        found!.Email.Should().Be("test@example.com");
    }

    [Fact]
    public async Task FindByEmail_Should ReturnUser_WhenExists()
    {
        // Arrange
        var user = new User { Email = "unique@example.com", Username = "unique" };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        // Act
        var found = await _repository.FindByEmailAsync("unique@example.com");

        // Assert
        found.Should().NotBeNull();
        found!.Username.Should().Be("unique");
    }

    [Fact]
    public async Task FindByEmail_Should ReturnNull_WhenNotExists()
    {
        var found = await _repository.FindByEmailAsync("nonexistent@example.com");
        found.Should().BeNull();
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
```

---

## Testing Checklist for .NET APIs

- [ ] All API endpoints tested with WebApplicationFactory
- [ ] Service layer tested with Moq
- [ ] Entity Framework repositories tested with InMemoryDatabase
- [ ] Model validation tested with FluentValidation
- [ ] Authentication and authorization tested
- [ ] Exception middleware tested
- [ ] Database transactions tested
- [ ] Use FluentAssertions for readable tests
- [ ] Tests run in parallel
- [ ] Code coverage >= 80%

---

## References
- [xUnit Documentation](https://xunit.net/)
- [FluentAssertions](https://fluentassertions.com/)
- [Moq Documentation](https://github.com/moq/moq4)
- [ASP.NET Core Testing](https://learn.microsoft.com/en-us/aspnet/core/test/)

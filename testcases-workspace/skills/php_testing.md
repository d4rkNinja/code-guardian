# PHP Test Generation

## Overview
PHP applications use PHPUnit and Pest for testing Laravel, Symfony, and custom PHP applications.

## Testing Frameworks

### **PHPUnit** (Standard)
- Industry standard for PHP testing
- Rich assertion library
- Version: PHPUnit 10+ for PHP 8+

### **Pest** (Modern alternative for Laravel)
- Elegant testing syntax
- Built on PHPUnit
- Laravel-focused

---

## Test Patterns

### **1. Laravel HTTP Testing**

```php
<?php
// tests/Feature/UserApiTest.php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_user_with_valid_data(): void
    {
        // Arrange
        $userData = [
            'email' => 'test@example.com',
            'username' => 'testuser',
            'password' => 'SecurePass123!',
        ];

        // Act
        $response = $this->postJson('/api/users', $userData);

        // Assert
        $response->assertStatus(201)
                 ->assertJson([
                     'email' => 'test@example.com',
                     'username' => 'testuser',
                 ])
                 ->assertJsonMissing(['password']);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
        ]);
    }

    public function test_rejects_invalid_email(): void
    {
        $response = $this->postJson('/api/users', [
            'email' => 'invalid-email',
            'username' => 'testuser',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email']);
    }

    public function test_requires_authentication_for_profile(): void
    {
        $response = $this->getJson('/api/users/me');
        $response->assertStatus(401);
    }

    public function test_returns_user_profile_when_authenticated(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->getJson('/api/users/me');

        $response->assertStatus(200)
                 ->assertJson(['id' => $user->id]);
    }
}
```

### **2. Service Layer Testing**

```php
<?php

namespace Tests\Unit\Services;

use App\Services\PaymentService;
use App\Models\Order;
use App\Gateways\PaymentGateway;
use Mockery;
use Tests\TestCase;

class PaymentServiceTest extends TestCase
{
    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function test_processes_payment_successfully(): void
    {
        // Arrange
        $order = new Order(['id' => 1, 'amount' => 99.99]);
        $mockGateway = Mockery::mock(PaymentGateway::class);
        $mockGateway->shouldReceive('charge')
                    ->once()
                    ->with(99.99, 'tok_valid')
                    ->andReturn(['success' => true, 'transaction_id' => 'txn_123']);

        $service = new PaymentService($mockGateway);

        // Act
        $result = $service->processPayment($order, 'tok_valid');

        // Assert
        $this->assertTrue($result['success']);
        $this->assertEquals('txn_123', $result['transaction_id']);
    }
}
```

### **3. Pest Syntax (Laravel)**

```php
<?php
// tests/Feature/UserApiTest.php

use App\Models\User;

it('creates user with valid data', function () {
    $response = $this->postJson('/api/users', [
        'email' => 'test@example.com',
        'username' => 'testuser',
    ]);

    $response->assertStatus(201);
    expect($response->json('email'))->toBe('test@example.com');
});

it('requires authentication', function () {
    $this->getJson('/api/users/me')->assertStatus(401);
});

it('returns user profile when authenticated', function () {
    $user = User::factory()->create();

    $this->actingAs($user)
         ->getJson('/api/users/me')
         ->assertStatus(200)
         ->assertJson(['id' => $user->id]);
});
```

---

## Testing Checklist

- [ ] Use RefreshDatabase for database tests
- [ ] HTTP tests for all API endpoints
- [ ] Service layer tested with Mockery
- [ ] Database factories for test data
- [ ] Authentication tested
- [ ] Validation tested
- [ ] Use Pest for modern Laravel projects

---

## References
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Testing](https://laravel.com/docs/testing)
- [Pest PHP](https://pestphp.com/)

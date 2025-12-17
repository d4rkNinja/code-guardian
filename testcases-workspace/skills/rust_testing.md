# Rust Test Generation

## Overview
Rust uses built-in testing with focus on unit tests, integration tests, and async testing with tokio.

## Testing Tools

### **Built-in test framework**
- `#[test]` attribute for unit tests
- `tests/` directory for integration tests
- `cargo test` command

### **mockall** (Mocking)
- Mock traits and structs
- `mockall = "0.12"`

### **tokio-test** (Async testing)
- Testing async code
- `tokio-test = "0.4"`

---

## Test Patterns

### **1. Unit Tests**

```rust
// src/models/user.rs

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation_with_valid_data() {
        let user = User::new("test@example.com", "testuser");

        assert_eq!(user.email(), "test@example.com");
        assert_eq!(user.username(), "testuser");
        assert!(user.id().is_some());
    }

    #[test]
    fn test_user_email_validation() {
        let result = User::new("invalid-email", "testuser");

        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Invalid email format");
    }

    #[test]
    #[should_panic(expected = "Username cannot be empty")]
    fn test_empty_username_panics() {
        User::new("test@example.com", "");
    }
}
```

### **2. Integration Tests**

```rust
// tests/api_tests.rs

use my_app::{create_app, User};
use axum::http::StatusCode;
use axum_test::TestServer;

#[tokio::test]
async fn test_create_user_endpoint() {
    // Arrange
    let app = create_app();
    let server = TestServer::new(app).unwrap();

    let user_data = serde_json::json!({
        "email": "test@example.com",
        "username": "testuser"
    });

    // Act
    let response = server.post("/api/users")
        .json(&user_data)
        .await;

    // Assert
    assert_eq!(response.status_code(), StatusCode::CREATED);
    
    let body: User = response.json();
    assert_eq!(body.email, "test@example.com");
}

#[tokio::test]
async fn test_get_user_not_found() {
    let app = create_app();
    let server = TestServer::new(app).unwrap();

    let response = server.get("/api/users/nonexistent").await;

    assert_eq!(response.status_code(), StatusCode::NOT_FOUND);
}
```

### **3. Mocking with mockall**

```rust
use mockall::*;
use mockall::predicate::*;

#[automock]
trait UserRepository {
    fn create(&self, user: &User) -> Result<User, String>;
    fn find_by_email(&self, email: &str) -> Option<User>;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_service_creates_user() {
        // Arrange
        let mut mock_repo = MockUserRepository::new();
        let test_user = User::new("test@example.com", "testuser");

        mock_repo.expect_create()
            .with(eq(test_user.clone()))
            .times(1)
            .returning(|user| Ok(user.clone()));

        let service = UserService::new(mock_repo);

        // Act
        let result = service.create_user(&test_user);

        // Assert
        assert!(result.is_ok());
    }
}
```

---

## Testing Checklist

- [ ] Unit tests in same file as code
- [ ] Integration tests in `tests/` directory
- [ ] Use `#[tokio::test]` for async tests
- [ ] Mock traits with mockall
- [ ] Test error cases with `Result` types
- [ ] Run `cargo test` for all tests
- [ ] Code coverage with `cargo tarpaulin`

---

## References
- [Rust Book - Testing](https://doc.rust-lang.org/book/ch11-00-testing.html)
- [mockall](https://docs.rs/mockall/latest/mockall/)
- [tokio Testing](https://tokio.rs/tokio/topics/testing)

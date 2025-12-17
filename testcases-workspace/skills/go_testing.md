# Go Test Generation

## Overview
Go applications use the built-in testing package with a focus on table-driven tests, HTTP handler testing, and interface mocking.

## Testing Tools

### **testing** (Built-in)
- Standard library testing package
- Simple, effective, no dependencies

### **testify** (Popular third-party)
- Assertions and mocking
- `github.com/stretchr/testify`

### **httptest** (HTTP testing)
- Built-in HTTP testing utilities
- Mock HTTP servers

---

## Test Patterns

### **1. HTTP Handler Testing**

```go
// users_test.go
package api_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCreateUser(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    map[string]string
		expectedStatus int
		expectedError  string
	}{
		{
			name: "valid user creation",
			requestBody: map[string]string{
				"email":    "test@example.com",
				"username": "testuser",
			},
			expectedStatus: http.StatusCreated,
		},
		{
			name: "invalid email",
			requestBody: map[string]string{
				"email":    "invalid-email",
				"username": "testuser",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  "invalid email format",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPost, "/api/users", bytes.NewReader(body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			// Act
			CreateUserHandler(w, req)

			// Assert
			assert.Equal(t, tt.expectedStatus, w.Code)
			
			if tt.expectedError != "" {
				var resp map[string]string
				json.Unmarshal(w.Body.Bytes(), &resp)
				assert.Contains(t, resp["error"], tt.expectedError)
			}
		})
	}
}
```

### **2. Service Layer Testing**

```go
package service_test

import (
	"context"
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Mock repository
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) Create(ctx context.Context, user *User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func TestUserService_CreateUser(t *testing.T) {
	// Arrange
	mockRepo := new(MockUserRepository)
	service := NewUserService(mockRepo)
	
	user := &User{Email: "test@example.com", Username: "testuser"}
	mockRepo.On("Create", mock.Anything, user).Return(nil)

	// Act
	err := service.CreateUser(context.Background(), user)

	// Assert
	assert.NoError(t, err)
	mockRepo.AssertExpectations(t)
}

func TestUserService_CreateUser_DuplicateEmail(t *testing.T) {
	mockRepo := new(MockUserRepository)
	service := NewUserService(mockRepo)
	
	user := &User{Email: "duplicate@example.com"}
	mockRepo.On("Create", mock.Anything, user).Return(errors.New("duplicate email"))

	err := service.CreateUser(context.Background(), user)

	assert.Error(t, err)
	assert.Contains(t, err.Error(), "duplicate")
}
```

---

## Testing Checklist

- [ ] Use table-driven tests for similar scenarios
- [ ] Test HTTP handlers with httptest
- [ ] Mock dependencies with interfaces
- [ ] Use subtests for organization
- [ ] Test error cases explicitly
- [ ] Run tests with `-race` flag
- [ ] Code coverage >= 80%

---

## References
- [Go Testing Package](https://pkg.go.dev/testing)
- [Testify](https://github.com/stretchr/testify)
- [HTTP Testing](https://pkg.go.dev/net/http/httptest)

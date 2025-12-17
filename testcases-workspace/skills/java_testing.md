# Java / Kotlin Test Generation

## Overview
Java and Kotlin applications require robust testing strategies focusing on Spring Boot APIs, service layers, and JPA integrations. This guide provides comprehensive patterns using JUnit 5, Mockito, and Spring Boot Test.

## Testing Framework Selection

### **JUnit 5** (Jupiter - Recommended)
- **Best for**: All Java/Kotlin projects
- **Strengths**: Modern annotations, parameterized tests, extensions, nested tests
- **Version**: Use JUnit 5.9+ for latest features

### **Mockito** (Mocking Framework)
- **Best for**: Unit testing with dependencies
- **Strengths**: Clean syntax, argument matchers, verification
- **Version**: Mockito 5+ with Java 11+

### **Spring Boot Test**
- **Best for**: Spring applications
- **Strengths**: @SpringBootTest, @WebMvcTest, auto-configuration
- **Integration**: Works seamlessly with JUnit 5

### **RestAssured** (API Testing)
- **Best for**: REST API testing
- **Strengths**: Fluent API, JSON/XML support, authentication
- **Alternative**: MockMvc for Spring applications

---

## Test Generation Patterns

### **1. REST API Testing (Spring Boot)**

#### **Example: Testing REST Controller with MockMvc**
```java
// src/test/java/com/example/api/UserApiTest.java
package com.example.api;

import com.example.model.User;
import com.example.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserApiTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserService userService;

    @Test
    void shouldCreateUserWithValidData() throws Exception {
        // Arrange
        User newUser = new User(null, "test@example.com", "TestUser");
        User savedUser = new User(1L, "test@example.com", "TestUser");
        when(userService.createUser(any(User.class))).thenReturn(savedUser);

        // Act & Assert
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(newUser)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.username").value("TestUser"));
    }

    @Test
    void shouldRejectInvalidEmail() throws Exception {
        User invalidUser = new User(null, "invalid-email", "TestUser");

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidUser)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors").exists());
    }

    @Test
    void shouldReturnUserById() throws Exception {
        User user = new User(1L, "test@example.com", "TestUser");
        when(userService.findById(1L)).thenReturn(Optional.of(user));

        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.email").value("test@example.com"));
    }

    @Test
    void shouldReturn404ForNonExistentUser() throws Exception {
        when(userService.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void shouldRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isUnauthorized());
    }
}
```

#### **Example: Testing with RestAssured**
```java
package com.example.api;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserApiIntegrationTest {

    @LocalServerPort
    private int port;

    @BeforeEach
    void setUp() {
        RestAssured.port = port;
    }

    @Test
    void shouldCreateAndRetrieveUser() {
        // Create user
        Integer userId = given()
                .contentType(ContentType.JSON)
                .body("""
                    {
                        "email": "test@example.com",
                        "username": "testuser",
                        "password": "SecurePass123!"
                    }
                    """)
                .when()
                .post("/api/users")
                .then()
                .statusCode(201)
                .body("email", equalTo("test@example.com"))
                .body("username", equalTo("testuser"))
                .extract().path("id");

        // Retrieve user
        given()
                .when()
                .get("/api/users/" + userId)
                .then()
                .statusCode(200)
                .body("id", equalTo(userId))
                .body("email", equalTo("test@example.com"));
    }
}
```

---

### **2. Service Layer Testing**

```java
package com.example.service;

import com.example.model.Payment;
import com.example.model.Order;
import com.example.repository.PaymentRepository;
import com.example.repository.OrderRepository;
import com.example.external.PaymentGateway;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock
    private PaymentRepository paymentRepository;

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private PaymentGateway paymentGateway;

    @InjectMocks
    private PaymentService paymentService;

    private Order testOrder;

    @BeforeEach
    void setUp() {
        testOrder = new Order(1L, BigDecimal.valueOf(99.99), "PENDING");
    }

    @Test
    void shouldSuccessfullyProcessPayment() {
        // Arrange
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(paymentGateway.charge(any(), any())).thenReturn(
                new PaymentGateway.ChargeResult(true, "txn_123456")
        );
        when(paymentRepository.save(any(Payment.class))).thenAnswer(i -> i.getArgument(0));

        // Act
        PaymentResult result = paymentService.processPayment(1L, "tok_valid_card");

        // Assert
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getTransactionId()).isEqualTo("txn_123456");

        verify(paymentGateway).charge(
                eq(BigDecimal.valueOf(99.99)),
                eq("tok_valid_card")
        );
        verify(orderRepository).save(argThat(order ->
                order.getStatus().equals("PAID") &&
                order.getTransactionId().equals("txn_123456")
        ));
        verify(paymentRepository).save(any(Payment.class));
    }

    @Test
    void shouldRollbackOnPaymentFailure() {
        // Arrange
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(paymentGateway.charge(any(), any())).thenThrow(
                new PaymentGatewayException("Payment declined")
        );

        // Act & Assert
        assertThatThrownBy(() -> paymentService.processPayment(1L, "tok_declined"))
                .isInstanceOf(PaymentProcessingException.class)
                .hasMessageContaining("Payment failed");

        // Verify order status unchanged
        verify(orderRepository, never()).save(any(Order.class));
        verify(paymentRepository, never()).save(any(Payment.class));
    }

    @Test
    void shouldThrowExceptionForNonExistentOrder() {
        when(orderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> paymentService.processPayment(999L, "tok_card"))
                .isInstanceOf(OrderNotFoundException.class);
    }
}
```

---

### **3. JPA Repository Integration Testing**

```java
package com.example.repository;

import com.example.model.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;

@DataJpaTest
class UserRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    @Test
    void shouldSaveAndFindUser() {
        // Arrange
        User user = new User(null, "test@example.com", "testuser");

        // Act
        User savedUser = userRepository.save(user);
        entityManager.flush();

        // Assert
        Optional<User> found = userRepository.findById(savedUser.getId());
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("test@example.com");
    }

    @Test
    void shouldFindUserByEmail() {
        User user = new User(null, "unique@example.com", "uniqueuser");
        entityManager.persist(user);
        entityManager.flush();

        Optional<User> found = userRepository.findByEmail("unique@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getUsername()).isEqualTo("uniqueuser");
    }

    @Test
    void shouldReturnEmptyForNonExistentEmail() {
        Optional<User> found = userRepository.findByEmail("nonexistent@example.com");
        assertThat(found).isEmpty();
    }

    @Test
    void shouldFindAllActiveUsers() {
        entityManager.persist(new User(null, "active1@example.com", "user1", true));
        entityManager.persist(new User(null, "active2@example.com", "user2", true));
        entityManager.persist(new User(null, "inactive@example.com", "user3", false));
        entityManager.flush();

        List<User> activeUsers = userRepository.findByActiveTrue();

        assertThat(activeUsers).hasSize(2);
        assertThat(activeUsers).allMatch(User::isActive);
    }
}
```

---

## Spring Boot Integration Testing Best Practices

### **Using@SpringBootTest for Full Integration**
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(locations = "classpath:application-test.properties")
class OrderFulfillmentIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void shouldCompleteOrderFulfillmentWorkflow() {
        // Full integration test with real database
    }
}
```

### **Using TestContainers for Database Testing**
```java
@Testcontainers
@SpringBootTest
class DatabaseIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Test
    void testDatabaseOperations() {
        // Test with real PostgreSQL container
    }
}
```

---

## Testing Checklist for Java/Kotlin APIs

- [ ] All REST endpoints have integration tests
- [ ] Service layer tested with mocked dependencies
- [ ] JPA repositories tested with @DataJpaTest
- [ ] Request validation tested (Bean Validation)
- [ ] Authentication and authorization tested
- [ ] Exception handling tested
- [ ] Database transactions tested
- [ ] External services are mocked
- [ ] Tests use AssertJ for fluent assertions
- [ ] Code coverage >= 80% for critical paths

---

## References
- [JUnit 5 Documentation](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [Spring Boot Testing](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing)
- [TestContainers](https://www.testcontainers.org/)

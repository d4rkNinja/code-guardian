# Python Test Generation

## Overview
Python applications require systematic test generation focusing on API endpoints, service layers, and business logic. This guide provides comprehensive patterns using Pytest, unittest, and framework-specific testing tools.

## Testing Framework Selection

### **Pytest** (Recommended)
- **Best for**: All Python projects, especially Django, Flask, FastAPI
- **Strengths**: Simple syntax, powerful fixtures, parametrization, excellent plugin ecosystem
- **Version**: Use Pytest 8+ for latest features

### **unittest** (Standard library)
- **Best for**: Projects avoiding external dependencies
- **Strengths**: Built-in, no installation required, familiar to Java developers

### **Framework-Specific**
- **Django**: Django Test Client, pytest-django
- **Flask**: Flask Test Client
- **FastAPI**: TestClient (based on Starlette)

---

## Test Generation Patterns

### **1. API Endpoint Testing (FastAPI/Flask/Django)**

#### **FastAPI Example with TestClient**
```python
# tests/integration/api/test_users.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.main import app
from app.models import User
from tests.fixtures.factories import create_test_user, get_auth_token

client = TestClient(app)

class TestUsersAPI:
    """Integration tests for Users API endpoints"""
    
    def test_create_user_with_valid_data(self, db_session: Session):
        """Should successfully create user with valid registration data"""
        # Arrange
        user_data = {
            "email": "test@example.com",
            "username": "testuser",
            "password": "SecurePass123!"
        }
        
        # Act
        response = client.post("/api/users", json=user_data)
        
        # Assert
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == user_data["email"]
        assert data["username"] == user_data["username"]
        assert "password" not in data  # Should not return password
        assert "id" in data
        
        # Verify database state
        user = db_session.query(User).filter_by(email=user_data["email"]).first()
        assert user is not None
        assert user.username == user_data["username"]
    
    def test_create_user_with_invalid_email(self, db_session: Session):
        """Should reject user creation with malformed email"""
        invalid_data = {
            "email": "not-an-email",
            "username": "testuser",
            "password": "SecurePass123!"
        }
        
        response = client.post("/api/users", json=invalid_data)
        
        assert response.status_code == 422
        assert "email" in response.json()["detail"][0]["loc"]
    
    def test_create_user_with_duplicate_email(self, db_session: Session):
        """Should prevent duplicate email addresses"""
        # Arrange - create first user
        existing_user = create_test_user(db_session, email="duplicate@example.com")
        
        # Act - attempt duplicate
        duplicate_data = {
            "email": "duplicate@example.com",
            "username": "different_username",
            "password": "Password123!"
        }
        response = client.post("/api/users", json=duplicate_data)
        
        # Assert
        assert response.status_code == 409
        assert "already exists" in response.json()["detail"]
    
    def test_get_user_profile_requires_authentication(self):
        """Should return 401 for unauthenticated profile request"""
        response = client.get("/api/users/me")
        assert response.status_code == 401
    
    def test_get_user_profile_with_valid_token(self, db_session: Session):
        """Should return user profile with valid JWT token"""
        # Arrange
        user = create_test_user(db_session)
        token = get_auth_token(user)
        
        # Act
        response = client.get(
            "/api/users/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        # Assert
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user.id
        assert data["email"] == user.email
    
    @pytest.mark.parametrize("user_id,expected_status", [
        ("valid-uuid-here", 200),
        ("nonexistent-id", 404),
        ("invalid-format", 400),
    ])
    def test_get_user_by_id_various_scenarios(self, db_session: Session, user_id: str, expected_status: int):
        """Should handle various user ID scenarios appropriately"""
        if expected_status == 200:
            user = create_test_user(db_session)
            user_id = str(user.id)
        
        response = client.get(f"/api/users/{user_id}")
        assert response.status_code == expected_status
```

---

### **2. Service Layer Testing**

#### **Example: Testing Service with Database Operations**
```python
# tests/integration/services/test_payment_service.py
import pytest
from decimal import Decimal
from unittest.mock import Mock, patch

from app.services.payment import PaymentService
from app.models import Order, Payment
from tests.fixtures.factories import create_test_user, create_test_order

class TestPaymentService:
    """Integration tests for Payment Service"""
    
    @pytest.fixture
    def payment_service(self, db_session):
        """Create payment service with mocked gateway"""
        mock_gateway = Mock()
        return PaymentService(db_session, payment_gateway=mock_gateway)
    
    def test_process_payment_success(self, db_session, payment_service):
        """Should successfully process valid payment and update order"""
        # Arrange
        user = create_test_user(db_session)
        order = create_test_order(db_session, user_id=user.id, amount=Decimal('99.99'))
        
        payment_service.payment_gateway.charge.return_value = {
            'success': True,
            'transaction_id': 'txn_123456'
        }
        
        # Act
        result = payment_service.process_payment(
            order_id=order.id,
            card_token='tok_valid_card'
        )
        
        # Assert
        assert result['success'] is True
        assert result['transaction_id'] == 'txn_123456'
        
        # Verify gateway called correctly
        payment_service.payment_gateway.charge.assert_called_once_with(
            amount=9999,  # cents
            currency='USD',
            source='tok_valid_card',
            metadata={'order_id': str(order.id)}
        )
        
        # Verify database state
        db_session.refresh(order)
        assert order.status == 'paid'
        assert order.transaction_id == 'txn_123456'
        
        # Verify payment record created
        payment = db_session.query(Payment).filter_by(order_id=order.id).first()
        assert payment is not None
        assert payment.amount == Decimal('99.99')
    
    def test_process_payment_failure_rollback(self, db_session, payment_service):
        """Should rollback order status on payment failure"""
        # Arrange
        order = create_test_order(db_session, status='pending')
        original_status = order.status
        
        payment_service.payment_gateway.charge.side_effect = Exception('Payment declined')
        
        # Act & Assert
        with pytest.raises(Exception, match='Payment declined'):
            payment_service.process_payment(order_id=order.id, card_token='tok_declined')
        
        # Verify order status unchanged
        db_session.refresh(order)
        assert order.status == original_status
        
        # Verify no payment record created
        payment_count = db_session.query(Payment).filter_by(order_id=order.id).count()
        assert payment_count == 0
    
    def test_refund_payment_success(self, db_session, payment_service):
        """Should successfully refund completed payment"""
        # Arrange
        payment = create_completed_payment(db_session)
        payment_service.payment_gateway.refund.return_value = {
            'success': True,
            'refund_id': 'ref_123'
        }
        
        # Act
        result = payment_service.refund_payment(payment.id)
        
        # Assert
        assert result['success'] is True
        payment_service.payment_gateway.refund.assert_called_once_with(
            payment.transaction_id
        )
        
        db_session.refresh(payment)
        assert payment.status == 'refunded'
```

---

### **3. Complex Workflow Testing**

#### **Example: Multi-Step Business Process**
```python
# tests/integration/workflows/test_order_fulfillment.py
import pytest
from unittest.mock import Mock

from app.workflows.order_fulfillment import OrderFulfillmentService
from tests.fixtures.factories import (
    create_test_order,
    create_test_product,
    mock_email_service,
    mock_inventory_service
)

class TestOrderFulfillmentWorkflow:
    """Integration tests for order fulfillment workflow"""
    
    @pytest.fixture
    def fulfillment_service(self, db_session):
        """Create fulfillment service with mocked dependencies"""
        email_service = mock_email_service()
        inventory_service = mock_inventory_service()
        
        return OrderFulfillmentService(
            db_session=db_session,
            email_service=email_service,
            inventory_service=inventory_service
        )
    
    def test_complete_order_fulfillment_workflow(
        self, db_session, fulfillment_service
    ):
        """Should complete full order fulfillment from payment to shipping"""
        # Arrange
        product = create_test_product(db_session, stock=10)
        order = create_test_order(
            db_session,
            items=[{'product_id': product.id, 'quantity': 2}],
            status='paid'
        )
        
        # Act
        result = fulfillment_service.fulfill_order(order.id)
        
        # Assert workflow completion
        assert result['success'] is True
        assert result['tracking_number'] is not None
        
        # Verify inventory decremented
        fulfillment_service.inventory_service.decrement_stock.assert_called_once_with(
            product.id, 2
        )
        
        # Verify shipping email sent
        fulfillment_service.email_service.send.assert_called_once()
        email_call = fulfillment_service.email_service.send.call_args
        assert email_call[1]['template'] == 'order_shipped'
        assert email_call[1]['to'] == order.customer_email
        
        # Verify database state
        db_session.refresh(order)
        assert order.status == 'shipped'
        assert order.tracking_number == result['tracking_number']
        assert order.shipped_at is not None
    
    def test_handle_out_of_stock_gracefully(self, db_session, fulfillment_service):
        """Should handle out-of-stock scenario without partial updates"""
        # Arrange
        product = create_test_product(db_session, stock=0)
        order = create_test_order(
            db_session,
            items=[{'product_id': product.id, 'quantity': 1}],
            status='paid'
        )
        
        fulfillment_service.inventory_service.decrement_stock.side_effect = \
            ValueError('Insufficient stock')
        
        # Act & Assert
        with pytest.raises(ValueError, match='Insufficient stock'):
            fulfillment_service.fulfill_order(order.id)
        
        # Verify no emails sent
        fulfillment_service.email_service.send.assert_not_called()
        
        # Verify order status unchanged
        db_session.refresh(order)
        assert order.status == 'paid'
        assert order.tracking_number is None
```

---

## Pytest Best Practices

### **Fixtures for Test Setup**
```python
# conftest.py (shared fixtures)
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope='session')
def engine():
    """Create test database engine"""
    return create_engine('sqlite:///:memory:')

@pytest.fixture(scope='function')
def db_session(engine):
    """Create fresh database session for each test"""
    Session = sessionmaker(bind=engine)
    session = Session()
    
    yield session
    
    session.rollback()
    session.close()

@pytest.fixture(autouse=True)
def reset_database(engine):
    """Reset database schema before each test"""
    Base.metadata.create_all(engine)
    yield
    Base.metadata.drop_all(engine)
```

### **Parametrized Tests**
```python
@pytest.mark.parametrize('email,expected_valid', [
    ('valid@example.com', True),
    ('invalid-email', False),
    ('missing@domain', False),
    ('user@domain.com', True),
])
def test_email_validation(email: str, expected_valid: bool):
    """Test email validation with various inputs"""
    result = is_valid_email(email)
    assert result == expected_valid
```

### **Mocking External Services**
```python
from unittest.mock import patch, Mock

@patch('app.services.email.smtp_client')
def test_send_email(mock_smtp):
    """Test email sending with mocked SMTP"""
    email_service = EmailService()
    email_service.send('test@example.com', 'Subject', 'Body')
    
    mock_smtp.send.assert_called_once()
```

---

## Testing Checklist for Python APIs

- [ ] All API endpoints have integration tests
- [ ] Database operations use test database/in-memory DB
- [ ] External services are mocked appropriately
- [ ] Tests use fixtures for setup and teardown
- [ ] Parametrized tests for similar scenarios
- [ ] Async functions tested with pytest-asyncio
- [ ] Code coverage >= 80% for critical paths
- [ ] Tests are isolated and can run in parallel
- [ ] Exception handling tested thoroughly
- [ ] Test data factories for consistent test data

---

## References
- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [Django Testing](https://docs.djangoproject.com/en/stable/topics/testing/)
- [Python Testing Best Practices](https://realpython.com/pytest-python-testing/)

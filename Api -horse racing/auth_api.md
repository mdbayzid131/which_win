# Authentication and User Management API Documentation

This document describes all endpoints defined under `/api/v1/auth` in [auth.route.ts](file:///d:/Anar/WEB-STA/goldenTak/GoldenTak-server/src/app/modules/auth/auth.route.ts). It is divided into:
1. **Device Auth** (Mobile App clients)
2. **Admin Auth** (Dashboard login & password management)
3. **Admin User Management** (Dashboard administration)

---

## 1. Device Authentication (Mobile App)

### A. Device Login / Register
Verifies a device, registering a new user if it is seen for the first time, and returns a JWT token containing subscription state.
- **URL**: `/api/v1/auth/device-login`
- **Method**: `POST`
- **Auth Required**: No
- **Request Body**:
  ```json
  {
    "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Device logged in successfully",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "cuid_user_123",
        "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
        "role": "USER",
        "language": "en",
        "subscription": {
          "id": "cuid_sub_123",
          "plan": "PREMIUM",
          "isActive": true,
          "endDate": "2026-07-02T12:00:00.000Z"
        }
      }
    }
  }
  ```

### B. Purchase Subscription (Device)
Activates or updates the subscription of a device.
- **URL**: `/api/v1/auth/purchase-subscription`
- **Method**: `POST`
- **Auth Required**: No
- **Request Body**:
  ```json
  {
    "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
    "planId": "plan_weekly_cuid",
    "duration": "WEEKLY"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Subscription updated successfully",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "cuid_user_123",
        "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
        "role": "USER",
        "subscription": {
          "id": "cuid_sub_123",
          "plan": "1 Week Premium",
          "isActive": true,
          "endDate": "2026-06-09T12:00:00.000Z"
        }
      }
    }
  }
  ```

---

## 2. Admin Authentication (Dashboard)

### A. Admin Login
Logs in an administrator using email and password.
- **URL**: `/api/v1/auth/login`
- **Method**: `POST`
- **Auth Required**: No
- **Request Body**:
  ```json
  {
    "email": "admin@gmail.com",
    "password": "password123"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Login successful",
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "cuid_admin_123",
        "email": "admin@gmail.com",
        "name": "Admin",
        "role": "ADMIN"
      }
    }
  }
  ```

### B. Change Password
Allows an logged-in admin to change their password.
- **URL**: `/api/v1/auth/change-password`
- **Method**: `POST`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Request Body**:
  ```json
  {
    "oldPassword": "password123",
    "newPassword": "newpassword123"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Password changed successfully"
  }
  ```

### C. Forgot Password
Initiates password recovery by sending an OTP verification code to the admin's email.
- **URL**: `/api/v1/auth/forgot-password`
- **Method**: `POST`
- **Auth Required**: No
- **Request Body**:
  ```json
  {
    "email": "admin@gmail.com"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "OTP code sent to email"
  }
  ```

### D. Verify OTP
Verifies the recovery OTP code.
- **URL**: `/api/v1/auth/verify-otp`
- **Method**: `POST`
- **Auth Required**: No
- **Request Body**:
  ```json
  {
    "email": "admin@gmail.com",
    "otp": "1234"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "OTP verified successfully",
    "data": {
      "verificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```

### E. Reset Password
Resets the password to a new value using the verification token.
- **URL**: `/api/v1/auth/reset-password`
- **Method**: `POST`
- **Auth Required**: No
- **Headers**:
  - `Authorization: Bearer <verificationToken>`
- **Request Body**:
  ```json
  {
    "password": "myNewResetPassword123"
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Password reset successfully"
  }
  ```

---

## 3. Admin User Management

### A. Get All Users (Paginated)
Lists all users registered in the database.
- **URL**: `/api/v1/auth/users`
- **Method**: `GET`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Query Parameters**:
  - `page` (number, default: 1)
  - `limit` (number, default: 10)
  - `searchTerm` (string, optional)
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Users retrieved successfully",
    "meta": {
      "page": 1,
      "limit": 10,
      "total": 120
    },
    "data": [
      {
        "id": "cuid_user_1",
        "deviceId": "device_uuid_999",
        "email": "user1@example.com",
        "name": "User One",
        "role": "USER",
        "createdAt": "2026-05-01T12:00:00.000Z",
        "subscription": {
          "plan": "PREMIUM",
          "isActive": true,
          "endDate": "2026-07-01T12:00:00.000Z"
        }
      }
    ]
  }
  ```

### B. Get Currently Logged-in Users
Retrieves users active in the system recently.
- **URL**: `/api/v1/auth/current-login-users`
- **Method**: `GET`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Current active users fetched successfully",
    "data": [
      {
        "id": "cuid_user_1",
        "deviceId": "device_uuid_999",
        "email": "user1@example.com",
        "role": "USER"
      }
    ]
  }
  ```

### C. Update User Subscription
Manually updates subscription plans or expirations for a specific user.
- **URL**: `/api/v1/auth/users/update-subscription`
- **Method**: `POST`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Request Body**:
  ```json
  {
    "userId": "cuid_user_1",
    "plan": "PREMIUM",
    "durationDays": 30
  }
  ```
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "User subscription updated successfully",
    "data": {
      "id": "cuid_sub_1",
      "userId": "cuid_user_1",
      "plan": "PREMIUM",
      "startDate": "2026-06-02T12:00:00.000Z",
      "endDate": "2026-07-02T12:00:00.000Z",
      "isActive": true
    }
  }
  ```

### D. Get User By ID
Fetches details of a specific user.
- **URL**: `/api/v1/auth/users/:id`
- **Method**: `GET`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "User details fetched successfully",
    "data": {
      "id": "cuid_user_1",
      "deviceId": "device_uuid_999",
      "email": "user1@example.com",
      "role": "USER",
      "subscription": {
        "plan": "PREMIUM",
        "isActive": true,
        "endDate": "2026-07-02T12:00:00.000Z"
      }
    }
  }
  ```

### E. Get User Growth Statistics
Retrieves registrations and active count metrics over time.
- **URL**: `/api/v1/auth/stats`
- **Method**: `GET`
- **Auth Required**: Yes (`ADMIN` role)
- **Headers**:
  - `Authorization: Bearer <admin_token>`
- **Response Example**:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "User stats fetched successfully",
    "data": {
      "totalUsers": 120,
      "activePremiumUsers": 45,
      "freeUsers": 75,
      "growthRate": 12.5
    }
  }
  ```

# Splash Screen API Documentation

This document describes the API integration for the **Splash Screen** of the Which Win application (`Splash.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/auth/device-login`
- **Method**: `POST`
- **Auth Required**: No (Public)
- **Content-Type**: `application/json`

---

## 2. Request Fields
| Field Name | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `deviceId` | `string` | Unique hardware identifier of the mobile device (UUID, IDFV, or Android ID) | `"FFDHDJHUUJYDGGBHIUUHD#@"` |

### Example Request Body
```json
{
  "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@"
}
```

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `DeviceLoginResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `message` | `string` | Status message from the server |
| `data` | `object` | Contains authentication and profile details |
| `data.token` | `string` | JWT Session Token to be stored in the app and used for all subsequent requests in the `Authorization: Bearer <token>` header. Contains encoded user profile and subscription status |
| `data.user` | `object` | Registered user record |
| `data.user.id` | `string` | Unique database identifier of the user |
| `data.user.deviceId` | `string` | Device identifier registered with this account |
| `data.user.role` | `string` | System role (e.g. `USER`, `ADMIN`) |
| `data.user.language` | `string` | Selected language code (defaults to `"en"`) |
| `data.user.subscription` | `object` | Current subscription information, if any |
| `data.user.subscription.plan` | `string` | Active plan name (e.g. `"PREMIUM"`, `"FREE"`) |
| `data.user.subscription.isActive` | `boolean` | Tells if subscription is currently active |
| `data.user.subscription.endDate` | `string` | Expiration date of the subscription in ISO string format (or `null`) |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Device logged in successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjbGlxaXR5dGwwMDAwM3I1...",
    "user": {
      "id": "cuid_user_12345",
      "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
      "role": "USER",
      "language": "tr",
      "subscription": {
        "id": "cuid_sub_12345",
        "userId": "cuid_user_12345",
        "plan": "PREMIUM",
        "startDate": "2026-06-01T12:00:00.000Z",
        "endDate": "2026-07-01T12:00:00.000Z",
        "isActive": true
      }
    }
  }
}
```

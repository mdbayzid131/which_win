# Subscription Screens API Documentation

This document describes the API integration for the **Subscription Screens** of the Which Win application (`Subcription.png` & `Subcription (1).png`).

---

## 1. Get Available Subscription Plans
- **URL**: `/api/v1/subscription/plans`
- **Method**: `GET`
- **Auth Required**: No (Public)
- **Content-Type**: `application/json`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `data` | `array` | List of available subscription plans |
| `data[].id` | `string` | Unique identifier of the subscription plan |
| `data[].name` | `string` | Name of the plan (e.g. `"1 Week"`, `"1 Month"`, `"1 Year"`) |
| `data[].duration` | `string` | Billing frequency enum (`WEEKLY`, `MONTHLY`, `YEARLY`) |
| `data[].price` | `number` | Numeric price value (e.g. `349.00`, `1199.00`, `7999.00`) |
| `data[].features` | `array` | List of features included in the plan |

### Response Example
```json
{
  "success": true,
  "message": "Subscription plans retrieved successfully",
  "data": [
    {
      "id": "plan_weekly_cuid",
      "name": "1 Week",
      "duration": "WEEKLY",
      "price": 349.00,
      "features": ["7 Days Premium Access", "AI predictions", "Realtime race metrics"]
    },
    {
      "id": "plan_monthly_cuid",
      "name": "1 Month",
      "duration": "MONTHLY",
      "price": 1199.00,
      "features": ["30 Days Premium Access", "AI predictions", "Realtime race metrics"]
    },
    {
      "id": "plan_yearly_cuid",
      "name": "1 Year",
      "duration": "YEARLY",
      "price": 7999.00,
      "features": ["365 Days Premium Access", "AI predictions", "Realtime race metrics"]
    }
  ]
}
```

---

## 2. Purchase / Activate Subscription (Device)
- **URL**: `/api/v1/auth/purchase-subscription`
- **Method**: `POST`
- **Auth Required**: No (Identified by deviceId)
- **Content-Type**: `application/json`

### Request Fields
| Field Name | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `deviceId` | `string` | Unique device identifier | `"FFDHDJHUUJYDGGBHIUUHD#@"` |
| `planId` | `string` | Selected plan ID | `"plan_weekly_cuid"` |
| `duration` | `string` | Selected duration (`WEEKLY`, `MONTHLY`, `YEARLY`) | `"WEEKLY"` |

### Example Request Body
```json
{
  "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
  "planId": "plan_weekly_cuid",
  "duration": "WEEKLY"
}
```

### Response Example
```json
{
  "success": true,
  "message": "Subscription updated successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjbGlxaXR5dGwwMDAwM3I1...",
    "user": {
      "id": "cuid_user_12345",
      "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
      "role": "USER",
      "subscription": {
        "id": "cuid_sub_12345",
        "plan": "1 Week Premium",
        "startDate": "2026-06-02T23:35:00.000Z",
        "endDate": "2026-06-09T23:35:00.000Z",
        "isActive": true
      }
    }
  }
}
```

---

## 3. UI State Handling (Figma: `Subcription.png` vs `Subcription (1).png`)
- **Checking Subscription**: On load, check the `isActive` state of the subscription (stored in the JWT payload or user state).
- **If Inactive**: Redirect the user to the "Active Plan Not Found" screen (`Subcription.png`).
- **If User clicks "Subscribe Now"**: Load the plans list (`GET /api/v1/subscription/plans`), select `"1 Week"` as default (Most Preferred), and display checkout choices (`Subcription (1).png`).
- **If User clicks "Restore Purchases"**: Call `POST /api/v1/auth/device-login` again with the `deviceId` to re-fetch the latest database subscription state, updating the local store.

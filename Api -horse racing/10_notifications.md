# Notifications Screen API Documentation

This document describes the API integration for the **Notifications Screen** of the Which Win application (`Notification.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/notification`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer <token>`)
- **Headers**:
  - `Authorization: Bearer <token>`

---

## 2. Request Fields
### Query Parameters
None required. Optional pagination parameters:
- `page` (number)
- `limit` (number)

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `NotificationsResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `message` | `string` | Status message from the server |
| `data` | `array` | List of notifications for the logged-in user |
| `data[].id` | `string` | Unique identifier of the notification |
| `data[].type` | `string` | Notification type: `SYSTEM`, `PREDICTION_READY`, `RACE_STARTING`, `RACE_FINISHED`, `SUBSCRIPTION_EXPIRING` |
| `data[].title` | `string` | Header / Title of the notification |
| `data[].message` | `string` | Message body text |
| `data[].isRead` | `boolean` | Read status |
| `data[].createdAt` | `string` | Timestamp when the notification was created |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Notifications fetched successfully",
  "data": [
    {
      "id": "notif_cuid_1",
      "type": "RACE_STARTING",
      "title": "Match Starting Soon",
      "message": "Raja Casablanca vs Wydad starts in 30 minutes",
      "isRead": false,
      "createdAt": "2026-06-02T23:33:38.000Z"
    },
    {
      "id": "notif_cuid_2",
      "type": "PREDICTION_READY",
      "title": "Prediction Update",
      "message": "New AI prediction available for tonight's matches",
      "isRead": true,
      "createdAt": "2026-06-02T22:35:38.000Z"
    },
    {
      "id": "notif_cuid_3",
      "type": "SUBSCRIPTION_EXPIRING",
      "title": "Subscription Reminder",
      "message": "Your subscription expires in 3 days",
      "isRead": false,
      "createdAt": "2026-06-02T21:35:38.000Z"
    }
  ]
}
```

---

## 5. Additional Endpoints for Notification Actions

### A. Mark Notification as Read
- **URL**: `/api/v1/notification/:id/read`
- **Method**: `PATCH`
- **Response**: `{ "success": true, "message": "Notification marked as read" }`

### B. Mark All Notifications as Read
- **URL**: `/api/v1/notification/mark-all-read`
- **Method**: `PATCH`
- **Response**: `{ "success": true, "message": "All notifications marked as read" }`

### C. Register Device Push Token (FCM)
- **URL**: `/api/v1/notification/register-token`
- **Method**: `PATCH`
- **Body**:
  ```json
  {
    "fcmToken": "fcm_token_string_here",
    "platform": "ios"
  }
  ```
- **Response**: `{ "success": true, "message": "Device token registered successfully" }`

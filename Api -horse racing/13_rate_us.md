# Rate Us / Feedback API Documentation

This document describes the API integration for the **Rate Us Screen** of the Which Win application (`RAte.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/rating` (or `/api/v1/feedback`)
- **Method**: `POST`
- **Auth Required**: No (Public or authenticated by token)
- **Content-Type**: `application/json`

---

## 2. Request Fields
| Field Name | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `deviceId` | `string` | Unique device identifier | `"FFDHDJHUUJYDGGBHIUUHD#@"` |
| `rating` | `number` | Numerical rating (integer between 1 and 5 stars) | `5` |
| `comment` | `string` | Optional: additional textual feedback | `"This app has increased my prediction accuracy. Excellent work!"` |

### Example Request Body
```json
{
  "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
  "rating": 5,
  "comment": "This app has increased my prediction accuracy. Excellent work!"
}
```

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `FeedbackSubmitResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the rating was successfully recorded |
| `message` | `string` | Status message from the server |

### Response Example
```json
{
  "success": true,
  "message": "Rating submitted successfully! Thank you for your feedback."
}
```

---

## 4. UI Mapping Guide (Figma: `RAte.png`)
- **Star Selector**: Display five star icons. Keep track of the tapped star index (1-5).
- **Submit Button**: Active once a star index is selected (i.e. `rating > 0`). When clicked, send the payload with `rating` and optional text.
- **Success Alert**: Display a toast or popup thanking the user for their feedback upon receiving `success: true`.

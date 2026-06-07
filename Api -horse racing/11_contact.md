# Contact Screen API Documentation

This document describes the API integration for the **Contact Screen** of the Which Win application (`Contact.png`).

---

## 1. Description
The Contact page displays public channels (Email, Telegram, Website) for getting in touch with customer support. Additionally, it can support a contact form submission to send email messages to the support team.

---

## 2. Channels (Static / Config Info)
The contact channels shown in the screen are:
- **Email**: `support@whichwin.com`
- **Telegram**: `@whichwin_support`
- **Website**: `www.whichwin.com`

---

## 3. Submit Feedback/Contact Form Endpoint
- **URL**: `/api/v1/contact`
- **Method**: `POST`
- **Auth Required**: No (Public)
- **Content-Type**: `application/json`

---

## 4. Request Fields
| Field Name | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `name` | `string` | Name of the sender | `"John Doe"` |
| `email` | `string` | Contact email address of the sender | `"johndoe@example.com"` |
| `subject` | `string` | Subject of the inquiry | `"Subscription Payment Issue"` |
| `message` | `string` | The detailed query / message text | `"I purchased a 1-month plan but it is not showing active on my device ID."` |

### Example Request Body
```json
{
  "name": "John Doe",
  "email": "johndoe@example.com",
  "subject": "Subscription Payment Issue",
  "message": "I purchased a 1-month plan but it is not showing active on my device ID."
}
```

---

## 5. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `ContactSubmitResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the mail was sent successfully |
| `message` | `string` | Status message from the server |

### Response Example
```json
{
  "success": true,
  "message": "Contact message sent successfully! We will get in touch soon."
}
```

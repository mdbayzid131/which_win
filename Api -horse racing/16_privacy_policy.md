# Privacy Policy API Documentation

This document describes the API integration for the **Privacy Policy Screen** of the Which Win application (`privecy.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/legal/:type`
- **Method**: `GET`
- **Auth Required**: No (Public)
- **Content-Type**: `application/json`

---

## 2. Request Fields
### Path Parameters
| Parameter | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `type` | `string` | The type of legal document (`TERMS_AND_CONDITIONS` or `PRIVACY_POLICY`) | `"PRIVACY_POLICY"` |

### Example Request URL
`GET /api/v1/legal/PRIVACY_POLICY`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `LegalDocumentResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `message` | `string` | Status message from the server |
| `data` | `object` | The legal document object |
| `data.id` | `string` | Unique identifier in the database |
| `data.type` | `string` | The document type tag |
| `data.content` | `string` | Detailed rich text or markdown content of the privacy policy |
| `data.updatedAt` | `string` | Last modified date of the document |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Legal document retrieved successfully",
  "data": {
    "id": "legal_cuid_2",
    "type": "PRIVACY_POLICY",
    "content": "Information We Collect\n\nWe collect information you provide directly to us, including name, email address, and usage data.\n\nHow We Use Your Information\n\nWe use the information to provide, maintain, and improve our services, and to communicate with you.\n\nData Security\n\nWe take reasonable measures to help protect your personal information from loss, theft, misuse and unauthorized access.",
    "createdAt": "2026-06-02T12:00:00.000Z",
    "updatedAt": "2026-06-02T12:00:00.000Z"
  }
}
```

---

## 5. UI Mapping Guide (Figma: `privecy.png`)
- **Rendering Content**: Render the content string `data.content` in the app using a text viewer that supports formatting (paragraphs, newlines, bold headings).
- **Back Navigation**: Allows the user to navigate back to the main settings/menu screen.

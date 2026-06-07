# Terms and Conditions API Documentation

This document describes the API integration for the **Terms and Conditions Screen** of the Which Win application (`Trems.png`).

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
| `type` | `string` | The type of legal document (`TERMS_AND_CONDITIONS` or `PRIVACY_POLICY`) | `"TERMS_AND_CONDITIONS"` |

### Example Request URL
`GET /api/v1/legal/TERMS_AND_CONDITIONS`

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
| `data.content` | `string` | Detailed rich text or markdown content of the terms and conditions |
| `data.updatedAt` | `string` | Last modified date of the document |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Legal document retrieved successfully",
  "data": {
    "id": "legal_cuid_1",
    "type": "TERMS_AND_CONDITIONS",
    "content": "1. Acceptance of Terms\n\nBy accessing and using Which Win, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. Use License\n\nPermission is granted to temporarily download one copy of the materials for personal, non-commercial transitory viewing only.\n\n3. Disclaimer\n\nThe materials on Which Win are provided on an 'as is' basis. We make no warranties, expressed or implied.",
    "createdAt": "2026-06-02T12:00:00.000Z",
    "updatedAt": "2026-06-02T12:00:00.000Z"
  }
}
```

---

## 5. UI Mapping Guide (Figma: `Trems.png`)
- **Rendering Content**: The content string `data.content` can be rendered in the app using a text viewer that supports formatting (paragraphs, newlines, bold headings).
- **Back Navigation**: Allows the user to navigate back to the main settings/menu screen.

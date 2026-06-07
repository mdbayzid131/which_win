# Bulletin Home Screen API Documentation

This document describes the API integration for the **Bulletin Home Screen** of the Which Win application (`home.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/race`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer <token>`)
- **Headers**:
  - `Authorization: Bearer <token>`

---

## 2. Request Fields (Query Parameters)
| Parameter | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `date` | `string` | Date of races in ISO format or YYYY-MM-DD | `"2026-05-22"` |
| `status` | `string` | Filter races by status (`UPCOMING`, `LIVE`, `FINISHED`) | `"UPCOMING"` |
| `location` | `string` | Filter races by course name | `"Saint-Cloud"` |
| `page` | `number` | Page number for pagination | `1` |
| `limit` | `number` | Page size for pagination | `50` |

### Example Request URL
`GET /api/v1/race?date=2026-05-22&page=1&limit=50`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RacesResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `message` | `string` | Status message from the server |
| `meta` | `object` | Pagination metadata |
| `meta.page` | `number` | Current page |
| `meta.limit` | `number` | Number of items per page |
| `meta.total` | `number` | Total number of matching races |
| `meta.totalPage` | `number` | Total pages available |
| `data` | `array` | List of race objects |
| `data[].id` | `string` | Internal database ID of the race |
| `data[].externalId` | `string` | Rapid API external ID of the race |
| `data[].name` | `string` | Race title / name |
| `data[].date` | `string` | Scheduled race date |
| `data[].time` | `string` | Post time (local time, HH:MM format) |
| `data[].location` | `string` | Course/Meeting name (e.g. `"Royal Ascot"`, `"Saint-Cloud"`) |
| `data[].country` | `string` | Country of the course (e.g. `"United Kingdom"`, `"France"`) |
| `data[].trackType` | `string` | Surface description (e.g. `"Turf"`, `"Sand"`, `"Synthetic"`) |
| `data[].distance` | `string` | Distance (e.g. `"5f 212y"`, `"1600m"`) |
| `data[].prize` | `string` | Total prize purse value (e.g. `"₺850,000"`, `"£14,490"`) |
| `data[].status` | `string` | Status: `UPCOMING`, `LIVE`, or `FINISHED` |
| `data[]._count.entries` | `number` | Total number of runner entries declared in the race |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Races fetched successfully",
  "meta": {
    "page": 1,
    "limit": 50,
    "total": 3,
    "totalPage": 1
  },
  "data": [
    {
      "id": "cuid_race_01",
      "externalId": "33913",
      "name": "De Vaureal Claiming Stakes",
      "date": "2026-05-22T00:00:00.000Z",
      "time": "11:43",
      "location": "Saint-Cloud",
      "country": "France",
      "trackType": "Turf",
      "distance": "5f 212y",
      "prize": "₺850,000",
      "status": "LIVE",
      "createdAt": "2026-06-02T12:00:00.000Z",
      "updatedAt": "2026-06-02T12:00:00.000Z",
      "_count": {
        "entries": 12
      }
    },
    {
      "id": "cuid_race_02",
      "externalId": "33914",
      "name": "Royal Ascot Gold Cup",
      "date": "2026-05-22T00:00:00.000Z",
      "time": "15:30",
      "location": "Royal Ascot",
      "country": "United Kingdom",
      "trackType": "Turf",
      "distance": "2m 4f",
      "prize": "₺1,500,000",
      "status": "UPCOMING",
      "createdAt": "2026-06-02T12:00:00.000Z",
      "updatedAt": "2026-06-02T12:00:00.000Z",
      "_count": {
        "entries": 8
      }
    }
  ]
}
```

---

## 5. UI Mapping & Grouping Guide (Figma: `home.png`)
To achieve the design where races are grouped by Country and Course/Meeting:
1. **Grouping**: Group the flat race list `data` in the frontend by `country` (first key) and `location` (second key).
2. **Flags**: Render the appropriate country flag using the `country` string (e.g. map `"United Kingdom"` to the UK flag).
3. **Dropdown Count**: Render the total number of races in the meeting group.
4. **Live Indicator**: If any race in the group has `status: "LIVE"`, render the orange `"LIVE"` badge on the meeting card header.

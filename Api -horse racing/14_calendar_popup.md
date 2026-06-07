# Calendar Popup API Documentation

This document describes the API integration for the **Calendar Date Picker Modal** of the Which Win application (`Pop Up Calender.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/race/dates`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer <token>`)
- **Headers**:
  - `Authorization: Bearer <token>`

---

## 2. Request Fields (Query Parameters)
| Parameter | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `month` | `string` | Optional: Filter dates in a specific month (YYYY-MM format) | `"2026-05"` |

### Example Request URL
`GET /api/v1/race/dates?month=2026-05`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceDatesResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `data` | `array` | List of YYYY-MM-DD date strings that have scheduled races in the database |

### Response Example
```json
{
  "success": true,
  "message": "Race dates fetched successfully",
  "data": [
    "2026-05-01",
    "2026-05-02",
    "2026-05-03",
    "2026-05-05",
    "2026-05-06",
    "2026-05-07",
    "2026-05-08",
    "2026-05-09",
    "2026-05-10",
    "2026-05-11",
    "2026-05-12",
    "2026-05-13",
    "2026-05-14",
    "2026-05-15",
    "2026-05-16",
    "2026-05-17",
    "2026-05-18",
    "2026-05-19",
    "2026-05-20",
    "2026-05-21",
    "2026-05-22",
    "2026-05-23",
    "2026-05-24",
    "2026-05-25",
    "2026-05-26",
    "2026-05-27",
    "2026-05-28",
    "2026-05-29",
    "2026-05-30",
    "2026-05-31"
  ]
}
```

---

## 4. UI Mapping Guide (Figma: `Pop Up Calender.png`)
- **Green Dot Indicator**: When rendering each day of the calendar month (e.g. May 2026), check if the formatted date (e.g. `"2026-05-04"`) is present in the `data` array. If yes, draw a small green dot below the day number in the grid.
- **Date Selection**: When the user selects a day (e.g. clicking `4`), update the header selected label to `"Monday, May 4, 2026"` and fetch the races for that date via `GET /api/v1/race?date=2026-05-04`.

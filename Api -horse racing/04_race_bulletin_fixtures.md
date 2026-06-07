# Race Bulletin / Fixtures API Documentation

This document describes the API integration for the **Race Bulletin / Fixtures Page** of the Which Win application (`Fixturer.png`).

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
| `date` | `string` | Selected date (YYYY-MM-DD format) | `"2025-05-05"` |
| `location` | `string` | The selected racecourse/meeting name | `"Royal Ascot - Gold Cup"` |

### Example Request URL
`GET /api/v1/race?date=2025-05-05&location=Royal%20Ascot%20-%20Gold%20Cup`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceListResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `message` | `string` | Status message from the server |
| `data` | `array` | List of races scheduled for the location/date |
| `data[].id` | `string` | Internal database ID of the race |
| `data[].name` | `string` | Name/Number of the race (e.g. `"Race 1"`, `"Race 2"`) |
| `data[].time` | `string` | Start/Post time of the race (HH:MM format) |
| `data[].trackType` | `string` | Track type surface (e.g. `"Turf"`, `"Sand"`, `"Synthetic"`) |
| `data[].distance` | `string` | Race track distance (e.g. `"1200m"`, `"1600m"`) |
| `data[].prize` | `string` | Race purse value (e.g. `"₺850,000"`) |
| `data[]._count.entries` | `number` | Total number of runner horses entered |
| `data[].tahmin1X` | `string` | Optional: short prediction summary code (e.g., `"1X"`) |
| `data[].predictionMessage` | `string` | Highlights prediction text (e.g. `"Who beat whom: AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 GOLDEN ARROW"`) |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Races fetched successfully",
  "data": [
    {
      "id": "race_cuid_1",
      "name": "Race 1",
      "time": "13:45",
      "trackType": "Turf",
      "distance": "1200m",
      "prize": "₺850,000",
      "status": "UPCOMING",
      "tahmin1X": "1X",
      "predictionMessage": "Who beat whom: AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 GOLDEN ARROW",
      "_count": {
        "entries": 8
      }
    },
    {
      "id": "race_cuid_2",
      "name": "Race 2",
      "time": "14:20",
      "trackType": "Sand",
      "distance": "1600m",
      "prize": "₺1,200,000",
      "status": "UPCOMING",
      "tahmin1X": "1X",
      "predictionMessage": "Who beat whom: AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 GOLDEN ARROW",
      "_count": {
        "entries": 10
      }
    },
    {
      "id": "race_cuid_3",
      "name": "Race 3",
      "time": "15:00",
      "trackType": "Turf",
      "distance": "2000m",
      "prize": "₺650,000",
      "status": "UPCOMING",
      "tahmin1X": "1X",
      "predictionMessage": "Who beat whom: AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 GOLDEN ARROW",
      "_count": {
        "entries": 7
      }
    }
  ]
}
```

---

## 5. UI Mapping Guide (Figma: `Fixturer.png`)
- **Race Number Circle**: Render the `data[].name` or list index (e.g. green circle containing `1` for `"Race 1"`).
- **Tags**: Render two tags: one for class/condition (derived or fallback e.g. `"Handicap"`) and one for surface (`data[].trackType`).
- **Prize**: Render `data[].prize` (e.g. `₺850,000`) in green.
- **Horse Count**: Render `_count.entries` + `" horses"`.
- **Prediction Box**: Render the `predictionMessage` value at the bottom of the card, highlighting it in yellow.

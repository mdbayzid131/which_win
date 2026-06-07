# Race Statistics Tab API Documentation

This document describes the API integration for the **Race Statistics Tab** of the Which Win application (`statistics.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/race/:id/statistics`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer <token>`)
- **Headers**:
  - `Authorization: Bearer <token>`

---

## 2. Request Fields
### Path Parameters
| Parameter | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `id` | `string` | Internal database ID of the race | `"race_cuid_2"` |

### Example Request URL
`GET /api/v1/race/race_cuid_2/statistics`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceStatisticsResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `data` | `object` | Stats object containing 8 sections |
| `data.earnings` | `array` | Top horse earnings with name, amount and bar percentage |
| `data.origin` | `array` | Percentage distribution of horse origin countries |
| `data.distance` | `array` | Past win counts of entered horses at various distances |
| `data.track` | `array` | Performance breakdown (Wins and Runs/Losses) on Turf vs Sand tracks |
| `data.city` | `array` | Percentage distribution of horse runs across different racecourse cities |
| `data.jockey` | `array` | Win rate percentages for the top jockeys riding in this race |
| `data.coRaces` | `array` | Head-to-head records (Wins-Losses) when these runners faced each other in past co-races |
| `data.bestTime` | `array` | Best recorded times of runners at the race distance/course |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Race statistics compiled successfully",
  "data": {
    "earnings": [
      { "horseName": "AKSI SEDA", "amount": "₺500K", "percentage": 100 },
      { "horseName": "GOLDEN ARROW", "amount": "₺420K", "percentage": 84 },
      { "horseName": "VENOM", "amount": "₺285K", "percentage": 57 }
    ],
    "origin": [
      { "country": "Turkey", "percentage": 60 },
      { "country": "UK", "percentage": 20 },
      { "country": "IE", "percentage": 20 }
    ],
    "distance": [
      { "label": "1200m", "detail": "W3", "percentage": 100 },
      { "label": "1600m", "detail": "W2", "percentage": 66 },
      { "label": "2000m", "detail": "W1", "percentage": 33 }
    ],
    "track": [
      { "surface": "Turf", "detail": "W4 L2", "percentage": 80 },
      { "surface": "Sand", "detail": "W1 L3", "percentage": 40 }
    ],
    "city": [
      { "name": "Istanbul", "percentage": 58 },
      { "name": "Ankara", "percentage": 30 }
    ],
    "jockey": [
      { "name": "A.Can", "percentage": 68 },
      { "name": "M.Kaya", "percentage": 45 }
    ],
    "coRaces": [
      { "horseName": "VENOM", "score": "3-2", "percentage": 80 },
      { "horseName": "GOLDEN ARROW", "score": "3-1", "percentage": 60 }
    ],
    "bestTime": [
      { "horseName": "AKSI SEDA", "time": "1:12.45", "percentage": 95 },
      { "horseName": "VENOM", "time": "1:13.10", "percentage": 85 }
    ]
  }
}
```

---

## 5. UI Mapping Guide (Figma: `statistics.png`)
- Render an 8-card grid:
  1. **EARNINGS**: Render list of horses and their earnings with green progress bars based on the `percentage` field.
  2. **ORIGIN**: Render country names and percentages with green progress bars.
  3. **DISTANCE**: Display distance label (e.g. `1200m`) and win count (e.g. `W3`) with progress bars.
  4. **TRACK**: Display Turf vs Sand wins/losses (e.g. `W4 L2`) with progress bars.
  5. **CITY**: Display course cities (e.g. `Istanbul 58%`) with progress bars.
  6. **JOCKEY**: Display jockey short names and win rates (e.g. `A.Can: 68%`) with progress bars.
  7. **CO-RACES**: Display horse head-to-head score (e.g. `VENOM 3-2`) with progress bars.
  8. **BEST TIME**: Display horse best times (e.g. `AKSI SEDA 1:12.45`) with progress bars.

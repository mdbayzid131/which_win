# Horse Details Popup API Documentation

This document describes the API integration for the **Horse Details Popup** modal of the Which Win application (`View Details pop up.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/horse/:id`
- **Method**: `GET`
- **Auth Required**: Yes (`Bearer <token>`)
- **Headers**:
  - `Authorization: Bearer <token>`

---

## 2. Request Fields
### Path Parameters
| Parameter | Type | Description | Example Value |
| :--- | :--- | :--- | :--- |
| `id` | `string` | Internal database ID of the horse | `"horse_cuid_1"` |

### Example Request URL
`GET /api/v1/horse/horse_cuid_1`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `HorseDetailsResponse`

### Response Field Descriptions
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `data` | `object` | Complete horse profile and race results |
| `data.name` | `string` | Horse Name (e.g. `"AKSI SEDA"`) |
| `data.age` | `number` | Horse Age in years (e.g., `5`) |
| `data.color` | `string` | Color description (e.g., `"Chestnut"`) |
| `data.country` | `string` | Country of origin code (e.g., `"TR"`, `"GB"`) |
| `data.sireName` | `string` | Father name |
| `data.damName` | `string` | Mother name |
| `data.owner` | `string` | Owner name |
| `data.trainer` | `string` | Trainer name |
| `data.totalEarnings` | `number` | Total earnings (e.g. `500000`) |
| `data.bestTime` | `string` | Best time (e.g. `"1:12.45"`) |
| `data.bestTimeLocation`| `string` | Best time course (e.g. `"Istanbul"`) |
| `data.wins` | `number` | Total career wins |
| `data.totalRaces` | `number` | Total career races |
| `data.seconds` | `number` | Total career 2nd places |
| `data.thirds` | `number` | Total career 3rd places |
| `data.results` | `array` | List of past race results, containing the last 6 races |
| `data.results[].position` | `number` | Finishing position (e.g. `1`, `2`, `3`) |
| `data.results[].race.name` | `string` | Name of the race (e.g. `"Race 1"`) |
| `data.results[].race.distance` | `string` | Distance of the race (e.g. `"1200m"`) |
| `data.results[].race.trackType` | `string`| Track type (e.g. `"Turf"`, `"Sand"`) |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Horse profile retrieved successfully",
  "data": {
    "id": "horse_cuid_1",
    "externalId": "67274",
    "name": "AKSI SEDA",
    "age": 5,
    "color": "Chestnut",
    "sex": "m",
    "sireName": "STORM CAT",
    "damName": "REGAL LADY",
    "owner": "Ali Yılmaz",
    "trainer": "Mehmet Demir",
    "country": "TR",
    "totalRaces": 40,
    "wins": 6,
    "seconds": 5,
    "thirds": 4,
    "fourths": 2,
    "totalEarnings": 500000,
    "bestTime": "1:12.45",
    "bestTimeLocation": "Istanbul",
    "createdAt": "2026-06-02T12:00:00.000Z",
    "updatedAt": "2026-06-02T12:00:00.000Z",
    "results": [
      {
        "id": "result_01",
        "position": 3,
        "time": "1:13.12",
        "earnings": 15000,
        "race": {
          "id": "race_06",
          "name": "Race 6",
          "distance": "1200m",
          "trackType": "Turf"
        }
      },
      {
        "id": "result_02",
        "position": 2,
        "time": "1:12.98",
        "earnings": 25000,
        "race": {
          "id": "race_05",
          "name": "Race 5",
          "distance": "1200m",
          "trackType": "Turf"
        }
      },
      {
        "id": "result_03",
        "position": 3,
        "time": "1:13.05",
        "earnings": 15000,
        "race": {
          "id": "race_04",
          "name": "Race 4",
          "distance": "1200m",
          "trackType": "Turf"
        }
      },
      {
        "id": "result_04",
        "position": 2,
        "time": "1:12.80",
        "earnings": 25000,
        "race": {
          "id": "race_03",
          "name": "Race 3",
          "distance": "1200m",
          "trackType": "Turf"
        }
      },
      {
        "id": "result_05",
        "position": 1,
        "time": "1:12.45",
        "earnings": 80000,
        "race": {
          "id": "race_02",
          "name": "Race 2",
          "distance": "1200m",
          "trackType": "Turf"
        }
      },
      {
        "id": "result_06",
        "position": 1,
        "time": "1:12.60",
        "earnings": 80000,
        "race": {
          "id": "race_01",
          "name": "Race 1",
          "distance": "1200m",
          "trackType": "Turf"
        }
      }
    ]
  }
}
```

---

## 5. UI Mapping & Calculations Guide (Figma: `View Details pop up.png`)

### 1. Stats Banner Calculations
- **Win Rate %**: `(wins / totalRaces) * 100` -> format as `"15% Win"`.
- **Top 3 Rate %**: `((wins + seconds + thirds) / totalRaces) * 100` -> format as `"38% Top 3"`.
- **Avg Position**: Sum of finishing positions in `results` divided by the count -> format as `"6.2 Avg"`.

### 2. Grid Cards Mapping
- **HP Score**: Retrieve from the entry in the current race (fallback to `94`).
- **Earnings**: Format `totalEarnings` as a currency string (e.g. `"₺500,000"`).
- **Best Time**: Concatenate `bestTime` + `" "` + `bestTimeLocation` (e.g. `"1.12.45 Istanbul"`).
- **Last 6**: Join the positions of the last 6 races in chronological order (e.g. `"323211"`).

### 3. Race History List
- For the last 6 races in `results`, render a row:
  - **Position Badge**:
    - Position 1: Bright Green Badge
    - Position 2: Medium Green Badge
    - Position 3: Yellow/Gold Badge
    - Position >= 4: Grey/Red Badge
  - **Race Name**: Render `race.name`.
  - **Details**: Render `race.distance` + `" • "` + `race.trackType` (e.g. `"1200m • Turf"`).

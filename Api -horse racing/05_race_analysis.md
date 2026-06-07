# Race Analysis Tab API Documentation

This document describes the API integration for the **Race Analysis Tab** of the Which Win application (`Anlysis.png`).

---

## 1. Route / Endpoint
- **URL**: `/api/v1/race/:id`
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
`GET /api/v1/race/race_cuid_2`

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceDetailsResponse`

### Response Field Descriptions (Analysis Metrics)
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `success` | `boolean` | Indicates if the request was successful |
| `data` | `object` | Detailed race details and predictions |
| `data.id` | `string` | Internal ID of the race |
| `data.name` | `string` | Race name/number |
| `data.trackType` | `string` | Surface type |
| `data.distance` | `string` | Distance of the race |
| `data.time` | `string` | Race time |
| `data.entries` | `array` | Declared runners list sorted by rank/win probability |
| `data.entries[].rank` | `number` | AI determined predicted rank (1-indexed) |
| `data.entries[].winProb` | `number` | Probability of winning (float between 0.0 and 1.0) |
| `data.entries[].normalizedScore` | `number` | Normalized score for the UI, equal to `winProb * 100` |
| `data.entries[].horse.name` | `string` | Horse name |
| `data.entries[].horse.age` | `number` | Horse age |
| `data.entries[].jockeyName` | `string` | Jockey name |
| `data.entries[].weight` | `number` | Jockey weight carried in kg/lbs |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Race fetched successfully",
  "data": {
    "id": "race_cuid_2",
    "externalId": "33914",
    "name": "Race 2",
    "date": "2026-05-22T00:00:00.000Z",
    "time": "14:20",
    "location": "Royal Ascot",
    "country": "United Kingdom",
    "trackType": "Sand",
    "distance": "1600m",
    "prize": "₺1,200,000",
    "status": "UPCOMING",
    "tahmin1X": "1X",
    "predictionMessage": "Who beat whom: AKSI SEDA 3-2 VENOMAKSI SEDA 3-1 GOLDEN ARROW",
    "entries": [
      {
        "id": "entry_cuid_1",
        "raceId": "race_cuid_2",
        "horseId": "horse_cuid_1",
        "jockeyId": "jockey_cuid_1",
        "jockeyName": "AHMET CAN",
        "weight": 50,
        "draw": 1,
        "horsePower": 95,
        "jockeyPower": 95,
        "normalizedScore": 82,
        "rank": 1,
        "category": "BIG",
        "winProb": 0.82,
        "winOddsFair": 1.22,
        "placeProb": 0.95,
        "goingSuitabilityScore": 0.9,
        "distanceSuitabilityScore": 0.95,
        "jockeyFormScore": 0.95,
        "trainerFormScore": 0.9,
        "aiSelectionRank": 1,
        "aiConfidence": "HIGH",
        "aiConfidenceScore": 0.94,
        "aiAnalysis": "Aksi Seda shows excellent form and track suitability.",
        "horse": {
          "id": "horse_cuid_1",
          "name": "AKSI SEDA",
          "age": 5,
          "color": "Chestnut",
          "sex": "m",
          "sireName": "AMERICAN PHAROAH",
          "damName": "THUNDER ROSE",
          "owner": "Star Stables",
          "trainer": "Mike Johnson",
          "country": "TR",
          "totalRaces": 12,
          "wins": 3,
          "seconds": 2,
          "thirds": 1,
          "totalEarnings": 500000
        }
      },
      {
        "id": "entry_cuid_2",
        "raceId": "race_cuid_2",
        "horseId": "horse_cuid_2",
        "jockeyId": "jockey_cuid_2",
        "jockeyName": "JACK ESTABO",
        "weight": 59,
        "draw": 2,
        "horsePower": 94,
        "jockeyPower": 90,
        "normalizedScore": 71,
        "rank": 2,
        "category": "BIG",
        "winProb": 0.71,
        "winOddsFair": 1.4,
        "placeProb": 0.88,
        "goingSuitabilityScore": 0.85,
        "distanceSuitabilityScore": 0.9,
        "jockeyFormScore": 0.9,
        "trainerFormScore": 0.85,
        "aiSelectionRank": 2,
        "aiConfidence": "HIGH",
        "aiConfidenceScore": 0.89,
        "aiAnalysis": "Venom is highly competitive on sand.",
        "horse": {
          "id": "horse_cuid_2",
          "name": "VENOM",
          "age": 4,
          "color": "Bay",
          "sex": "g",
          "sireName": "STORM CAT",
          "damName": "REGAL LADY",
          "owner": "Ali Yılmaz",
          "trainer": "Mehmet Demir",
          "country": "TR",
          "totalRaces": 10,
          "wins": 2,
          "seconds": 1,
          "thirds": 2,
          "totalEarnings": 285000
        }
      }
    ]
  }
}
```

---

## 5. UI Mapping Guide (Figma: `Anlysis.png`)
- **Sub-header badges**:
  - `Track Bias`: Render `"Track Bias: "` + `data.trackType` (or fallback value like `"Turf"`).
  - `Dist`: Render `"Dist: "` + `data.distance` (e.g. `"1200m"`).
  - `Field`: Render `"Field: "` + `data.entries.length` + `" runners"`.
- **Ranks and Horse entries list**:
  - Circle badge color mapping:
    - Rank 1: Red circle
    - Rank 2: Blue circle
    - Rank 3: Green circle
    - Rank 4: Purple circle
    - Rank 5: Orange circle
    - Rank 6: Teal circle
  - Progress bar width: Bind `width` to `normalizedScore` (e.g., `82%`).
  - Progress bar color:
    - `normalizedScore >= 70`: Green (`#10B981`)
    - `normalizedScore >= 50 && normalizedScore < 70`: Yellow/Gold (`#F59E0B`)
    - `normalizedScore < 50`: Red (`#EF4444`)
  - Probability label: Render `data.entries[].normalizedScore` + `"%"` on the right side.

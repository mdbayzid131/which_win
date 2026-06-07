# Completed Race Winner & AI Predictions API Documentation

This document describes the API integration for the **Completed Race Winner & AI Predictions Screen** of the Which Win application (`Reching details.png`). This screen displays finished race details using a soccer-adapted prediction layout.

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
| `id` | `string` | Internal database ID of the race | `"race_cuid_3"` |

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceDetailsResponse`

### Response Field Descriptions (Figma UI Mapping)
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `data.status` | `string` | Should be `"FINISHED"` for this screen |
| `data.results[]` | `array` | List of results containing the winner |
| `data.results[0].horse.name`| `string` | Name of the winner horse (e.g. `"Thunder Bolt"`) |
| `data.results[0].jockey.name`| `string` | Name of the winning jockey (e.g. `"J. Smith"`) |
| `data.results[0].time` | `string` | Winning time (e.g. `"2:04.32"`) |
| `data.tahmin1X` | `string` | Prediction code (e.g. `"1X"`) mapped to **Which Win Tahmini** |
| `data.riskRate` | `number` | Confidence risk percentage (e.g. `50`) mapped to **Riskli Maç / Güven Seviyesi** |
| `data.predictionMessage` | `string` | Advice text (e.g. `"Beraberlik İhmal edilmemeli"`) mapped to **Program Önerisi** |
| `data.entries[]` | `array` | Declared entries, used to extract the top selections for Card 1, Card X, Card 2 |

---

## 4. Response Example
```json
{
  "success": true,
  "message": "Race details fetched successfully",
  "data": {
    "id": "race_cuid_3",
    "externalId": "33915",
    "name": "De Vaureal Claiming Stakes",
    "date": "2026-05-06T00:00:00.000Z",
    "time": "15:30",
    "location": "Royal Ascot - Gold Cup",
    "country": "United Kingdom",
    "trackType": "Turf",
    "distance": "1200m",
    "prize": "₺850,000",
    "status": "FINISHED",
    "tahmin1X": "1X",
    "riskRate": 50,
    "predictionMessage": "Beraberlik İhmal edilmemeli",
    "results": [
      {
        "id": "result_winner_1",
        "position": 1,
        "time": "2:04.32",
        "earnings": 500000,
        "horse": {
          "id": "horse_winner_1",
          "name": "Thunder Bolt"
        },
        "jockey": {
          "id": "jockey_winner_1",
          "name": "J. Smith"
        }
      }
    ],
    "entries": [
      {
        "id": "entry_cuid_01",
        "winProb": 0.90,
        "placeProb": 0.75,
        "normalizedScore": 90,
        "horse": {
          "name": "Thunder Bolt",
          "wins": 4,
          "seconds": 1,
          "thirds": 0,
          "totalRaces": 5
        }
      },
      {
        "id": "entry_cuid_02",
        "winProb": 0.70,
        "placeProb": 0.60,
        "normalizedScore": 70,
        "horse": {
          "name": "Night Storm",
          "wins": 4,
          "seconds": 0,
          "thirds": 1,
          "totalRaces": 5
        }
      }
    ]
  }
}
```

---

## 5. UI Mapping Guide (Soccer Layout to Horse Racing)

Because the UI uses a soccer prediction layout (Home `1`, Draw `X`, Away `2`), we map horse racing AI predictions to these fields as follows:

### 1. The Three Prediction Cards (1, X, 2)
- **Card 1 (Home Win)**: Mapped to the **Win Probability of the Top Horse** (`entries[0].winProb * 100` -> `90%`). Render 3 gold stars.
- **Card X (Draw)**: Mapped to the **Place Probability of the Top Horse** (`entries[0].placeProb * 100` -> `75%`). Render 2 gold stars, 1 empty.
- **Card 2 (Away Win)**: Mapped to the **Win Probability of the 2nd Horse** (`entries[1].winProb * 100` -> `70%`). Render 1 gold star, 2 empty.
- **Label "Pearl"**: Static category label shown below the stars.

### 2. Status Panels
- **Which Win Tahmini**: Render `data.tahmin1X` (e.g. `"1X"`).
- **Riskli Maç**: Render `data.riskRate` formatted as `"%{riskRate} Güven Seviyesi"` (e.g., `"%50 Güven Seviyesi"`).
- **Program Önerisi**: Render `data.predictionMessage` (e.g., `"Beraberlik İhmal edilmemeli"`).

### 3. Yapay Zeka Tahmini Table (Bottom)
This table compares head-to-head metrics for the top two horses in this race:
- **Columns**: Left side represents Top Selection (Home), Right side represents 2nd Selection (Away).
- **Galip (Wins)**: Render `entries[0].horse.wins` (left) vs `entries[1].horse.wins` (right) (e.g. `4` vs `4`).
- **Berabere (Draws/Places)**: Render `entries[0].horse.seconds` (left) vs `entries[1].horse.seconds` (right) (e.g. `1` vs `0`).
- **Mağlup (Losses)**: Render `(totalRaces - wins - seconds)` (left) vs `(totalRaces - wins - seconds)` (right) (e.g. `0` vs `1`).

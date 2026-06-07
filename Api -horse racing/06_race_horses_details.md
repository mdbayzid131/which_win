# Horses Tab / Details list API Documentation

This document describes the API integration for the **Horses Tab / Details list** of the Which Win application (`Details.png`).

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

---

## 3. Response Type
- **Content-Type**: `application/json`
- **Response Class**: `RaceDetailsResponse`

### Response Field Descriptions (Horse Card Details)
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `data.entries[].normalizedScore` | `number` | Large score displayed in the card box (e.g., `95`) |
| `data.entries[].rank` | `number` | Predicted rank badge shown below the score (e.g., `1`) |
| `data.entries[].horse.name` | `string` | Name of the horse |
| `data.entries[].horse.age` | `number` | Age of the horse (e.g., `5`) |
| `data.entries[].horse.color` | `string` | Color of the horse (e.g., `"Chestnut"`, `"Bay"`, `"Grey"`) |
| `data.entries[].jockeyName` | `string` | Name of the rider / jockey |
| `data.entries[].weight` | `number` | Horse/Jockey weight in KG (e.g., `59`, `50`) |
| `data.entries[].horsePower` | `number` | AI determined Horse Power rating (HP Score) |
| `data.entries[].horse.totalEarnings` | `number` | Total prize money earned in career (e.g. `500000`) |
| `data.entries[].horse.sireName` | `string` | Father of the horse |
| `data.entries[].horse.damName` | `string` | Mother of the horse |
| `data.entries[].horse.owner` | `string` | Stable owner's name |
| `data.entries[].horse.trainer` | `string` | Coach / Trainer's name |
| `data.entries[].horse.bestTime` | `string` | Best recorded time at distance (e.g. `"1:13.55"`) |
| `data.entries[].horse.bestTimeLocation`| `string` | Track where best time was recorded (e.g. `"Kentucky"`) |
| `data.entries[].horse.results` | `array` | Past race results to build the form history string (e.g. `"323211"`) |

---

## 4. Response Example
See the response example in [05_race_analysis.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/05_race_analysis.md). The JSON response is identical, as both tabs consume the same `GET /api/v1/race/:id` payload.

---

## 5. UI Mapping Guide (Figma: `Details.png`)

### Collapsed Card State (e.g., `VENOM`)
- **Score Box**: Display `data.entries[].normalizedScore` in large green text inside a rounded box.
- **Rank Indicator**: Display `data.entries[].rank` in a colored circle immediately below the score box.
- **Horse Sub-details Line**: Format as: `{horse.age}yo • {horse.color} | Jockey: {jockeyName} | {weight}kg`.
- **Metrics Line (Small)**: Format as: `KG {weight}   HP {horsePower}   EARN. ₺{totalEarnings/1000}K` (e.g. `KG 59   HP 94   EARN. ₺500K`).
- **Earnings/Price (Right)**: Format `totalEarnings` as a localized currency string (e.g. `₺285,000`).
- **Form History Line (Right)**: Fetch the horse's last 6 results and concatenate the finishing positions into a string (e.g. `"164582"`).

### Expanded Card State (e.g., `AKSI SEDA`)
When the dropdown chevron is tapped, display these additional panels:
- **Pedigree**:
  - `Sire`: Display `horse.sireName` (bold).
  - `Dam`: Display `horse.damName` (bold).
- **Team**:
  - `Owner`: Display `horse.owner` (normal).
  - `Trainer`: Display `horse.trainer` (normal).
- **Performance**:
  - Format as: `Best: {horse.bestTime} {horse.bestTimeLocation}` (e.g. `"Best: 1:13.55 Kentucky"`).
- **View Races Button**:
  - When clicked, navigate to the Horse Profile popup using the horse's ID (`horse.id`).

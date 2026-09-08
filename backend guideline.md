# Backend Development Guidelines: Multi-Language (Localization) Support

## 📌 Overview
The application supports dual languages: **English (`en`)** and **Turkish (`tr`)**. The backend system must handle and serve localized dynamic data based on the user's selected language preference across all dynamic APIs and Push Notifications.

---

## 🌐 1. Language Handling Strategies

To ensure seamless localization across all endpoints, the backend should implement the following two mechanisms:

### A. HTTP Request Header (`Accept-Language` or `x-app-language`)
For all standard GET/POST/PATCH requests, the mobile app will pass the active language in the request header:
```http
Accept-Language: en
# or
Accept-Language: tr
```
- The backend should inspect this header and return localized responses accordingly.
- **Default Fallback:** If the header is missing or unsupported, fallback to `'en'`.

### B. Device Language Synchronization Endpoint
When the user switches languages from the App Settings / Language Picker, the app syncs this preference with the backend so push notifications are delivered in the correct language.

#### **Endpoint:** Update Device Language Preference
- **Method:** `POST` / `PATCH`
- **Path:** `/api/v1/device/language` (or `/api/v1/user/language`)
- **Headers:**
  ```http
  Content-Type: application/json
  ```
- **Request Body:**
  ```json
  {
    "device_id": "AP3A.240905.015.A2",
    "language": "tr" // "en" | "tr"
  }
  ```
- **Response (`200 OK`):**
  ```json
  {
    "success": true,
    "message": "Language preference updated successfully",
    "data": {
      "device_id": "AP3A.240905.015.A2",
      "language": "tr",
      "updated_at": "2026-09-08T09:30:00Z"
    }
  }
  ```

---

## 📄 2. Dynamic Content APIs Requiring Localization

### 2.1 Terms and Conditions API
- **Path:** `/api/v1/terms-conditions`
- **Method:** `GET`
- **Headers:** `Accept-Language: en` or `Accept-Language: tr`
- **Query Param (Optional):** `?lang=en` or `?lang=tr`
- **Response Structure:**
  ```json
  {
    "success": true,
    "language": "tr",
    "data": {
      "title": "Kullanım Koşulları ve Yasal Uyarı",
      "last_updated": "2026-09-03",
      "content": "..."
    }
  }
  ```

---

### 2.2 Privacy Policy API
- **Path:** `/api/v1/privacy-policy`
- **Method:** `GET`
- **Headers:** `Accept-Language: en` or `Accept-Language: tr`
- **Query Param (Optional):** `?lang=en` or `?lang=tr`
- **Response Structure:**
  ```json
  {
    "success": true,
    "language": "en",
    "data": {
      "title": "Privacy Policy and Legal Disclaimer",
      "last_updated": "2026-09-03",
      "content": "..."
    }
  }
  ```

---

### 2.3 Notifications API & Push Notifications
Notifications must be localized based on the user's stored language preference (`tr` or `en`).

#### A. In-App Notifications List Endpoint
- **Path:** `/api/v1/notifications`
- **Method:** `GET`
- **Headers:** `Accept-Language: en` or `Accept-Language: tr`
- **Response Structure:**
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "notif_001",
        "title": "Yeni Yarış Analizi Eklendi",
        "body": "Bugünkü Goodwood yarışları için yapay zeka analizleri hazır.",
        "type": "race_alert",
        "created_at": "2026-09-08T08:00:00Z",
        "is_read": false
      }
    ]
  }
  ```

#### B. Firebase Cloud Messaging (FCM) Push Notifications
When dispatching push notifications from the backend/cron jobs:
1. Lookup the device's saved `language` (`en` or `tr`).
2. Send the localized title and body payload in that language.
- **Example for English user:**
  ```json
  {
    "notification": {
      "title": "New Race Analysis Ready",
      "body": "AI predictions for upcoming races are now available."
    }
  }
  ```
- **Example for Turkish user:**
  ```json
  {
    "notification": {
      "title": "Yeni Yarış Analizi Hazır",
      "body": "Günün koşuları için yapay zeka tahminleri yayınlandı."
    }
  }
  ```

---

## 🗄️ 3. Database Schema Recommendations

### Option A: Dedicated Columns per Language (Simpler)
```sql
CREATE TABLE terms_and_conditions (
    id SERIAL PRIMARY KEY,
    title_en VARCHAR(255) NOT NULL,
    title_tr VARCHAR(255) NOT NULL,
    content_en TEXT NOT NULL,
    content_tr TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Option B: User / Device Preference Table
```sql
CREATE TABLE device_preferences (
    device_id VARCHAR(100) PRIMARY KEY,
    language VARCHAR(10) DEFAULT 'en', -- 'en' or 'tr'
    fcm_token TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📜 4. Official Terms and Conditions Content (Both Languages)

### 🇹🇷 4.1 Turkish Version (`tr`)

**Başlık:** KULLANIM KOŞULLARI VE YASAL UYARI  
**Son Güncelleme Tarihi:** 3 Eylül 2026  

İşbu Kullanım Koşulları ("Koşullar"), **Which Win Horse Race Analiz Programı** ("Program") tarafından sunulan dijital hizmetlerin kullanımına ilişkin usul ve esasları düzenlemektedir. Program’ı indirerek, yükleyerek veya herhangi bir şekilde kullanarak, işbu koşulları eksiksiz olarak kabul etmiş sayıldığınızı beyan edersiniz.

#### 1. Taraflar ve Kapsam
İşbu metin, Which Win Horse Race Analiz Programı (bundan sonra "Hizmet Sağlayıcı" olarak anılacaktır) ile Program’ı mobil cihazlarda veya dijital mecralarda kullanan son kullanıcı ("Kullanıcı") arasındaki yasal çerçeveyi belirler.

#### 2. Hizmetin Niteliği ve Sorumluluk Sınırlandırması
- Which Win Horse Race Analiz Programı, at yarışlarına yönelik istatistiksel verileri, geçmiş performansları, dereceleri ve analitik öngörüleri sunan münhasıran bir bilgi, analiz ve veri programıdır.
- **Program kesinlikle bir bahis, şans oyunu veya kumar sitesi veya organizatörü değildir; Which Win Horse Race hiçbir surette bahis oynatmaz, kupon kabul etmez veya aracılık hizmeti sunmaz.**
- Sunulan tüm veriler ve analizler yalnızca istatistiksel bilgi ve değerlendirme amaçlıdır. Kullanıcıların program verilerine dayanarak gerçekleştirecekleri her türlü işlem, tercih ve faaliyetten doğabilecek doğrudan veya dolaylı maddi ve manevi zararlardan Which Win Horse Race programı ve geliştiricileri hiçbir şekilde sorumlu tutulamaz.

#### 3. Fikri Mülkiyet Hakları
- Program’ın arayüzü, yazılım kodları, logoları, veritabanı yapıları, grafik tasarımları ve metin içerikleri **Which Win** markasına aittir ve 5846 sayılı Fikir ve Sanat Eserleri Kanunu ile ilgili uluslararası fikri mülkiyet mevzuatı kapsamında korunmaktadır.
- Kullanıcı, Program içeriğini yazılı izin olmaksızın kopyalayamaz, çoğaltamaz, ticari amaçla üçüncü kişilere aktaramaz veya tersine mühendislik işlemlerine tabi tutamaz.

#### 4. Kullanıcı Sorumlulukları
- Kullanıcı, Program’ı yürürlükteki ulusal ve uluslararası mevzuata, dürüstlük kuralına ve genel ahlaka uygun olarak kullanmakla yükümlüdür.
- 18 yaşından küçüklerin at yarışı ve ilgili analiz içeriklerine erişimi yasaktır. Kullanıcı, yasal yaş sınırını sağladığını beyan ve taahhüt eder.
- Program üzerinden elde edilen verilerin yanlış veya hukuka aykırı amaçlarla kullanımından doğabilecek her türlü hukuki ve cezai sorumluluk münhasıran Kullanıcı’ya aittir.

#### 5. Hizmet Kesintileri
Hizmet Sağlayıcı, sunucu kesintileri, telekomünikasyon altyapısından kaynaklanan aksaklıklar, veri güncellemelerindeki gecikmeler veya üçüncü taraf kaynaklı bilgi hatalarından sorumlu tutulamaz. Program "olduğu gibi" sunulmakta olup, kesintisiz veya hatasız çalışacağına dair herhangi bir garanti verilmemektedir.

#### 6. İletişim ve Resmi Bildirimler
İşbu Koşullar veya Program’ına ilişkin her türlü soru, talep ve bildirimleriniz için resmi iletişim kanallarımız üzerinden bizimle irtibata geçebilirsiniz:
- **Web Adresi:** www.whichwin-horserace.com
- **E-posta Adresi:** info@whichwin-horserace.com

---

### 🇬🇧 4.2 English Version (`en`)

**Title:** TERMS OF USE AND LEGAL DISCLAIMER  
**Last Updated:** September 3, 2026  

These Terms of Use ("Terms") govern the procedures and principles regarding the use of digital services provided by the **Which Win Horse Race Analysis Program** ("Program"). By downloading, installing, or in any way using the Program, you declare that you accept these terms in full.

#### 1. Parties and Scope
This document defines the legal framework between the Which Win Horse Race Analysis Program (hereinafter referred to as the "Service Provider") and the end user ("User") who uses the Program on mobile devices or digital platforms.

#### 2. Nature of the Service and Limitation of Liability
- Which Win Horse Race Analysis Program is exclusively an information, analysis, and data program that provides statistical data, historical performance records, ratings, and analytical predictions for horse races.
- **The Program is strictly NOT a betting, gambling, or games-of-chance platform or organizer; Which Win Horse Race under no circumstances conducts betting, accepts betting slips/coupons, or provides brokerage/intermediary services.**
- All data and analysis provided are solely for statistical information and evaluation purposes. The Which Win Horse Race program and its developers cannot be held liable under any circumstances for any direct or indirect material or moral damages arising from any transactions, preferences, or activities carried out by users based on program data.

#### 3. Intellectual Property Rights
- The Program's interface, software codes, logos, database structures, graphic designs, and textual content belong to the **Which Win** brand and are protected under relevant intellectual property laws and international conventions.
- The User may not copy, reproduce, commercially transfer to third parties, or reverse-engineer the Program's content without prior written permission.

#### 4. User Responsibilities
- The User is obliged to use the Program in compliance with applicable national and international legislation, good-faith principles, and general morality.
- Access to horse racing and related analysis content by individuals under the age of 18 is prohibited. The User declares and undertakes that they meet the legal age requirement.
- Any legal and criminal liability arising from the misuse or unlawful use of data obtained through the Program belongs exclusively to the User.

#### 5. Service Interruptions
The Service Provider cannot be held responsible for server downtime, telecommunications infrastructure disruptions, data update delays, or information errors originating from third parties. The Program is provided "as is", and no warranty is made that it will operate without interruption or error.

#### 6. Contact and Official Notices
For any questions, requests, or notifications regarding these Terms or the Program, you may contact us via our official communication channels:
- **Website:** www.whichwin-horserace.com
- **Email:** info@whichwin-horserace.com

---

## 🔒 5. Official Privacy Policy Content (Both Languages)

### 🇹🇷 5.1 Turkish Version (`tr`)

**Başlık:** GİZLİLİK POLİTİKASI VE YASAL UYARI  
**Son Güncelleme Tarihi:** 3 Eylül 2026  

#### Gizlilik Sözleşmesi
Which Win Horse Race Analiz Programı, bir bahis programı değildir ve sunulan tüm içerikler, tamamen yasal sınırlar içinde gerçekleştirilen istatistiksel tahmin ve analiz uygulamalarıdır. Tüm analizler, atların form durumu, derece geçmişleri ve pist koşulları gibi çevresel faktörler göz önünde bulundurularak yapılmaktadır. Hiçbir yasadışı paylaşım ve yasadışı bahis sitesi reklamı yapılmamaktadır. Kişisel verileriniz, ilgili kişinin rızası olmaksızın üçüncü taraflar ve tüzel kişilerle paylaşılamaz ve işlenemez.

#### Gizlilik Politikası
Which Win Horse Race Analiz Programı, bir bahis programı değildir ve sunulan tüm içerikler, tamamen yasal sınırlar içinde gerçekleştirilen tahmin ve analiz uygulamalarıdır. Tüm değerlendirmeler, atların performans durumları ve çevresel faktörler göz önünde bulundurularak yapılmaktadır. Hiçbir yasadışı paylaşım ve yasadışı bahis sitesi reklamı yapılmamaktadır. Kişisel verileriniz, ilgili kişinin rızası olmaksızın üçüncü taraflar ve tüzel kişilerle paylaşılamaz ve işlenemez.

#### İletişim Bilgileri
- **Web Adresi:** www.whichwin-horserace.com
- **E-posta Adresi:** info@whichwin-horserace.com

---

### 🇬🇧 5.2 English Version (`en`)

**Title:** PRIVACY POLICY AND LEGAL DISCLAIMER  
**Last Updated:** September 3, 2026  

#### Privacy Agreement
Which Win Horse Race Analysis Program is not a betting program, and all provided content consists entirely of statistical prediction and analysis applications conducted within legal boundaries. All analyses are performed taking into account environmental factors such as horses' form status, rating history, and track conditions. No illegal content sharing or advertising of illegal betting sites is conducted. Your personal data cannot be shared with or processed by third parties or legal entities without the explicit consent of the person concerned.

#### Privacy Policy
Which Win Horse Race Analysis Program is not a betting program, and all provided content consists entirely of prediction and analysis applications conducted within legal boundaries. All evaluations are performed taking into account horses' performance status and environmental factors. No illegal content sharing or advertising of illegal betting sites is conducted. Your personal data cannot be shared with or processed by third parties or legal entities without the explicit consent of the person concerned.

#### Contact Information
- **Website:** www.whichwin-horserace.com
- **Email:** info@whichwin-horserace.com

---

## ⚡ 6. API Performance & Payload Optimization Guidelines

### ⚠️ Problem Statement
Currently, backend endpoints (especially `GET /api/v1/race` and `GET /api/v1/race/:id`) are sending massive, un-optimized JSON responses (often exceeding **200 KB – 500 KB per request**).
- **Major Issues Identified in Response Logs:**
  1. **Dozens of `null` fields:** Sending 20+ empty/null keys per horse runner (`comment: null`, `spotlight: null`, `headgearRun: null`, `windSurgery: null`, `windSurgeryRun: null`, `trainerRtf: null`, `trainerLocation: null`, `speedRating: null`, `performanceRating: null`, `silkUrl: null`, `ts: null`, `courseId: null`, `goingDetailed: null`, `railMovements: null`, `stalls: null`, `weather: null`, `jumps: null`, `bigRace: null`, `isAbandoned: null`, `tip: null`, `verdict: null`, `winningTimeDetail: null`, `comments: null`, `nonRunners: null`, `aiConfidence: null`, `aiConfidenceScore: null`, `aiAnalysis: null`, `hasValueEdge: null`, `valueEdgePercent: null`, `bestTime: null`, `bestTimeLocation: null`).
  2. **Severe Data Duplication:** Returning the same data in top-level entry strings AND in nested objects (e.g., `entry.jockeyName` + `entry.jockey.name`, `entry.trainerName` + `entry.trainer.name`, `entry.age` + `entry.horse.age`, `entry.colour` + `entry.horse.colour`).
  3. **List API Over-fetching:** Returning full detailed relation graphs for dozens of races in list views instead of lightweight summary DTOs.
  4. **Impact on Mobile App:** High network latency, heavy memory pressure, parsing lag in Flutter, and overall sluggish app performance.

### 🎯 Optimization Goal
- **Reduce Payload Size by 70% – 85%** (Target: `< 25 KB` for race details, `< 15 KB` for race list).
- **Target Response Latency:** `< 200 ms` per API call.

### 🔑 Golden Rule: UI Contract Keys vs. Unused Bloat
> [!IMPORTANT]
> 1. **Used UI Keys (Mandatory Contract):** If a field/key is used in the app's UI design (e.g., in `RESULT`, `PREDICTION`, `ANALYSIS`, `STATISTICS`, or `ATLAR/JOKEYLER` tabs), the backend **MUST always include the key in the JSON**, even if its value in the database is currently `null` (e.g., `"weight": null`, `"time": null`, `"btn": null`, `"or": null`, `"form": null`). This ensures that Flutter model deserialization and UI data binding remain 100% stable without missing-key runtime errors.
> 2. **Completely Unused Fields (Must Omit):** Any database column or relation that is **NEVER used anywhere in the mobile app** (e.g., `spotlight`, `headgearRun`, `windSurgery`, `speedRating`, `silkUrl`, `weather`, `jumps`, `trainerRtf`, `aiConfidence`, etc.) MUST be completely excluded from the query/DTO.
> 3. **No UI Disruption:** Flutter models are built with strict null-safety. As long as the contract keys in Section 7 are preserved, the UI will not break or change visually.

---

## 📋 7. Exact Frontend Data Requirements (Endpoint-by-Endpoint)

The backend MUST ONLY send the fields specified below. Any other unneeded database columns or relations MUST be excluded via Prisma `select` or TypeORM projections.

### 7.1 `GET /api/v1/race` (Race List / Calendar / Meetings)
Used for the home race calendar and meeting list. **Do NOT send full entries or nested horse/jockey relations in this list endpoint.**

```json
{
  "success": true,
  "data": [
    {
      "id": "cmtruompe1tttqw0193lse7v5",
      "name": "Prix Jean Bart",
      "date": "2026-09-08T00:00:00.000Z",
      "time": "12:55",
      "location": "Auteuil",
      "country": "France",
      "region": "fr",
      "surface": "Turf",
      "distance": "18.0f",
      "prize": "€44,100",
      "raceType": "Hurdle",
      "ageBand": "5yo+",
      "fieldSize": 16,
      "status": "UPCOMING", // "UPCOMING" | "LIVE" | "FINISHED"
      "tahmin1X": "12",
      "riskRate": 45,
      "predictionMessage": "Kel Story & Titi De Paris are top picks",
      "hasPredictions": true,
      "isPremium": true
    }
  ]
}
```

---

### 7.2 `GET /api/v1/race/:id` (Race Details Screen - All 5 Tabs)
Used on the Race Details page (`Atlar/Jokeyler`, `İstatistik`, `Analiz`, `Tahmin`, `Sonuç`).

#### Clean & Lean Response Structure:
```json
{
  "success": true,
  "isPremium": true,
  "data": {
    "id": "cmtruompe1tttqw0193lse7v5",
    "name": "Prix Jean Bart",
    "date": "2026-09-08T00:00:00.000Z",
    "time": "12:55",
    "location": "Auteuil",
    "country": "France",
    "surface": "Turf",
    "distance": "18.0f",
    "prize": "€44,100",
    "raceType": "Hurdle",
    "ageBand": "5yo+",
    "fieldSize": 16,
    "status": "UPCOMING", // "UPCOMING" | "LIVE" | "FINISHED"
    "tahmin1X": "12",
    "riskRate": 45,
    "predictionMessage": "Kel Story & Titi De Paris are top picks.",
    "hasPredictions": true,

    "entries": [
      {
        "id": "cmtruon2e1twoqw01bta57kfr",
        "number": "14",
        "draw": 0,
        "weight": 143,
        "form": "P6P057",
        "headgear": "t",
        "lastRun": "22",
        "ofr": "120",
        "or": "120",
        "rpr": "125",
        
        "horsePower": 85.5,
        "pedigreePower": 72.0,
        "rawScore": 0.3296,
        "normalizedScore": 100,
        "rank": 1,
        "category": "MINIMUM",
        "winProb": 0.35,
        "winOddsFair": 2.85,

        "horse": {
          "id": "cmtruon271twkqw013wqjccgh",
          "name": "Kel Story",
          "age": 6,
          "colour": "b",
          "sex": "gelding",
          "sireName": "Jeu St Eloi",
          "damName": "Une Histoire",
          "damSireName": "Voix Du Nord",
          "owner": "J Finch",
          "trainer": "M Seror",
          "country": "FR",
          "totalEarnings": 12500,
          "totalRaces": 12,
          "wins": 3,
          "seconds": 2,
          "thirds": 1
        },

        "jockey": {
          "id": "cmtruon2c1twmqw016oa2e94c",
          "name": "Ludovic Philipperon",
          "totalRides": 150,
          "wins": 25,
          "ridesLast30d": 20,
          "winsLast30d": 4
        },

        "trainer": {
          "id": "cmtqezxeg0nlwqw011qiip2rd",
          "name": "M Seror",
          "totalRuns": 120,
          "wins": 18
        }
      }
    ],

    "results": [
      // EMPTY [] if status != "FINISHED"
      // Populated ONLY when race has finished:
      {
        "position": 1,
        "number": 14,
        "weight": 143,
        "time": "3:45.20",
        "btn": "KAZANDI", // or "2 BOY" / "1.5L"
        "sp": "3.50",
        "or": "120",
        "horse": {
          "id": "cmtruon271twkqw013wqjccgh",
          "name": "Kel Story"
        },
        "jockey": {
          "name": "Ludovic Philipperon"
        }
      }
    ]
  }
}
```

---

### 7.3 `GET /api/v1/race/:id/statistics` (Statistics Tab)
```json
{
  "success": true,
  "data": {
    "earnings": [
      { "horseName": "Kel Story", "amount": "€12,500", "percentage": 45 }
    ],
    "origin": [
      { "country": "FR", "percentage": 60 },
      { "country": "IRE", "percentage": 40 }
    ],
    "distance": [
      { "label": "18.0f", "detail": "3 Wins", "percentage": 75 }
    ],
    "track": [
      { "surface": "Turf", "detail": "Soft", "percentage": 80 }
    ]
  }
}
```

---

### 7.4 `GET /api/v1/horse/:id` (Horse Profile Screen)
```json
{
  "success": true,
  "data": {
    "id": "cmtruon271twkqw013wqjccgh",
    "name": "Kel Story",
    "age": 6,
    "colour": "b",
    "sex": "gelding",
    "sireName": "Jeu St Eloi",
    "damName": "Une Histoire",
    "damSireName": "Voix Du Nord",
    "owner": "J Finch",
    "trainer": "M Seror",
    "country": "FR",
    "totalEarnings": 12500,
    "totalRaces": 12,
    "wins": 3,
    "seconds": 2,
    "thirds": 1,
    "recentRaces": [
      {
        "date": "2026-08-15",
        "location": "Auteuil",
        "distance": "18.0f",
        "track": "Turf",
        "rank": 1,
        "time": "3:42.10",
        "jockeyName": "Ludovic Philipperon",
        "weight": 143,
        "hpScore": 85
      }
    ]
  }
}
```

---

## 🚫 8. Fields to Exclude / Omit from Backend Payloads

Do **NOT** send the following fields unless explicitly required by a specific endpoint:

| Category | Fields to Omit / Exclude |
| :--- | :--- |
| **Empty / Unused Entry Metadata** | `comment`, `spotlight`, `headgearRun`, `windSurgery`, `windSurgeryRun`, `trainerRtf`, `trainerLocation`, `speedRating`, `performanceRating`, `silkUrl`, `ts`, `aiSelectionRank`, `aiConfidence`, `aiConfidenceScore`, `aiAnalysis`, `hasValueEdge`, `valueEdgePercent` |
| **Empty / Unused Race Metadata** | `courseId`, `goingDetailed`, `railMovements`, `stalls`, `weather`, `jumps`, `bigRace`, `isAbandoned`, `tip`, `verdict`, `winningTimeDetail`, `comments`, `nonRunners`, `ratingBand`, `raceClass`, `sexRestriction`, `distanceRound` |
| **Duplicate Top-level Strings** | `jockeyName`, `trainerName`, `ownerName`, `weightStr`, `sexCode`, `colour`, `age` (These already exist inside `horse`, `jockey`, and `trainer` objects). |
| **Empty Stats in Horse/Jockey** | `bestTime: null`, `bestTimeLocation: null`, `fourths: 0` |

---

## 🛠️ 9. Recommended Backend Implementation (Prisma / NestJS)

### A. Prisma `select` Projection Example
Instead of doing `include: { entries: { include: { horse: true, jockey: true, trainer: true } } }` (which fetches and returns all 60+ database columns), use exact `select` projections:

```typescript
// race.service.ts
async getRaceDetails(raceId: string) {
  return this.prisma.race.findUnique({
    where: { id: raceId },
    select: {
      id: true,
      name: true,
      date: true,
      time: true,
      location: true,
      country: true,
      surface: true,
      distance: true,
      prize: true,
      raceType: true,
      ageBand: true,
      fieldSize: true,
      status: true,
      tahmin1X: true,
      riskRate: true,
      predictionMessage: true,
      hasPredictions: true,
      entries: {
        select: {
          id: true,
          number: true,
          draw: true,
          weight: true,
          form: true,
          headgear: true,
          lastRun: true,
          or: true,
          rpr: true,
          horsePower: true,
          pedigreePower: true,
          rawScore: true,
          normalizedScore: true,
          rank: true,
          category: true,
          winProb: true,
          winOddsFair: true,
          horse: {
            select: {
              id: true,
              name: true,
              age: true,
              colour: true,
              sex: true,
              sireName: true,
              damName: true,
              damSireName: true,
              owner: true,
              trainer: true,
              country: true,
              totalEarnings: true,
              totalRaces: true,
              wins: true,
              seconds: true,
              thirds: true,
            },
          },
          jockey: {
            select: {
              id: true,
              name: true,
              totalRides: true,
              wins: true,
              ridesLast30d: true,
              winsLast30d: true,
            },
          },
          trainer: {
            select: {
              id: true,
              name: true,
              totalRuns: true,
              wins: true,
            },
          },
        },
      },
      results: {
        select: {
          position: true,
          number: true,
          weight: true,
          time: true,
          btn: true,
          sp: true,
          or: true,
          horse: { select: { id: true, name: true } },
          jockey: { select: { name: true } },
        },
      },
    },
  });
}
```

### B. Enable HTTP Compression Middleware (Gzip / Brotli)
In `main.ts` (NestJS / Express), enable response compression:

```typescript
import * as compression from 'compression';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(compression()); // Compresses JSON payloads by 80%+ over the wire
  // ...
  await app.listen(process.env.PORT || 5001);
}
bootstrap();
```

---

## 🎯 Summary Checklist for Backend Developer

### 🌐 Localization Support
- [ ] Implement `Accept-Language` header recognition across all APIs (`en`/`tr`).
- [ ] Create/Update endpoint to save device language preference (`/api/v1/device/language`).
- [ ] Return localized content for **Terms & Conditions** (`/api/v1/terms-conditions`) matching Section 4.
- [ ] Return localized content for **Privacy Policy** (`/api/v1/privacy-policy`) matching Section 5.
- [ ] Return localized in-app **Notifications** list (`/api/v1/notifications`).
- [ ] Dispatch **Push Notifications (FCM)** in the user's selected language (`en`/`tr`).

### ⚡ Performance & Payload Optimization
- [ ] Apply strict Prisma `select` projections on `GET /api/v1/race` to return only summary fields (no nested entries).
- [ ] Apply strict Prisma `select` projections on `GET /api/v1/race/:id` matching Section 7.2.
- [ ] Strip out all 20+ `null` and unused fields listed in Section 8.
- [ ] Return empty array `results: []` when race is not yet `FINISHED`.
- [ ] Enable `compression()` middleware in NestJS/Express `main.ts`.
- [ ] Ensure API response payload size is `< 30 KB` and latency is `< 200 ms`.


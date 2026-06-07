# Which Win Mobile App API Integration Documentation

This folder contains the complete API integration documentation mapped to each page/Figma screenshot of the Which Win Mobile App.

---

## 📂 API Reference Index

| Page Name / Screen | Figma Screenshot | Documentation File | Primary Endpoint / Action |
| :--- | :--- | :--- | :--- |
| **00. Auth Module** | N/A | [auth_api.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/auth_api.md) | Device/Admin Auth & User management |
| **01. Splash Screen** | `Splash.png` | [01_splash_screen.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/01_splash_screen.md) | `POST /api/v1/auth/device-login` |
| **02. Menu Navigation** | `Menu.png` | [02_menu_navigation.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/02_menu_navigation.md) | Internal app state, session token evaluation |
| **03. Bulletin Home** | `home.png` | [03_bulletin_home.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/03_bulletin_home.md) | `GET /api/v1/race` (grouped list) |
| **04. Race Bulletin Fixtures** | `Fixturer.png` | [04_race_bulletin_fixtures.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/04_race_bulletin_fixtures.md) | `GET /api/v1/race?date=&location=` |
| **05. Race Analysis Tab** | `Anlysis.png` | [05_race_analysis.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/05_race_analysis.md) | `GET /api/v1/race/:id` (probabilities) |
| **06. Race Horses Details** | `Details.png` | [06_race_horses_details.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/06_race_horses_details.md) | `GET /api/v1/race/:id` (runner details) |
| **07. Race Statistics Tab** | `statistics.png` | [07_race_statistics.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/07_race_statistics.md) | `GET /api/v1/race/:id/statistics` (aggregated charts) |
| **08. Horse Details Popup** | `View Details pop up.png` | [08_horse_details_popup.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/08_horse_details_popup.md) | `GET /api/v1/horse/:id` (career & last 6 runs) |
| **09. Completed Predictions**| `Reching details.png` | [09_completed_race_predictions.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/09_completed_race_predictions.md) | `GET /api/v1/race/:id` (soccer layout mapping) |
| **10. Notifications** | `Notification.png` | [10_notifications.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/10_notifications.md) | `GET /api/v1/notification` |
| **11. Contact** | `Contact.png` | [11_contact.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/11_contact.md) | `POST /api/v1/contact` (channels & form submit) |
| **12. Subscription** | `Subcription (1).png` | [12_subscription.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/12_subscription.md) | `POST /api/v1/auth/purchase-subscription` |
| **13. Rate Us** | `RAte.png` | [13_rate_us.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/13_rate_us.md) | `POST /api/v1/rating` (feedback submit) |
| **14. Pop Up Calendar** | `Pop Up Calender.png` | [14_calendar_popup.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/14_calendar_popup.md) | `GET /api/v1/race/dates` (race indicator dots) |
| **15. Terms and Conditions** | `Trems.png` | [15_terms_and_conditions.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/15_terms_and_conditions.md) | `GET /api/v1/legal/TERMS_AND_CONDITIONS` |
| **16. Privacy Policy** | `privecy.png` | [16_privacy_policy.md](file:///d:/Anar/WEB-STA/goldenTak/api-documentation/16_privacy_policy.md) | `GET /api/v1/legal/PRIVACY_POLICY` |

---

## 🛠️ Summary of Schema Adjustments Made

To achieve complete alignment with the Figma screen specifications, the backend schema and codebase was updated to add:
1. **`WEEKLY`** option in the `SubscriptionDuration` enum (defined in `enum.prisma`) to support the `"1 Week"` plan displayed in `Subcription (1).png`.
2. **`country`** field to the `Horse` model (defined in `horse_racing.prisma`) to display the horse's country of origin (e.g. `"TR"` in the horse details popup) and compile correct `"ORIGIN"` statistics in the Statistics Tab.
3. **`bestTime`** and **`bestTimeLocation`** fields to the `Horse` model (defined in `horse_racing.prisma`) to display record speeds for runners across the panels.
4. **`country` syncing logic** in `calculation.service.ts` to automatically extract the horse country of origin from the Rapid API response payloads.

# Menu / Navigation API & State Documentation

This document describes the state and API dependencies for the **Menu/Navigation Drawer** of the Which Win application (`Menu.png`).

---

## 1. Description
The Menu Drawer acts as a primary navigation pane for the app. It displays the app branding, main pages, and critical footer information including the application version and the registered Device ID.

---

## 2. API / State Dependencies
The menu content itself is static, but dynamic logic is driven by the local store populated by the **Splash Screen** or **Device Login** endpoint:
- **Device ID Footer**: Placed at the bottom of the drawer (`FFDHDJHUUJYDGGBHIUUHD#@`), retrieved from the hardware or the device auth response.
- **Role/Subscription restrictions**: Certain menu options (e.g. premium racing matches) check the subscription token status (`user.subscription.isActive`).

---

## 3. Endpoints Utilized
The Menu page itself does not call specific endpoints, but it relies on:
1. `POST /api/v1/auth/device-login` (to check subscription status)
2. `GET /api/v1/auth/users/:id` (if fetching live profile stats)

---

## 4. Local App State Example
```json
{
  "appVersion": "2.1.8",
  "deviceId": "FFDHDJHUUJYDGGBHIUUHD#@",
  "userRole": "USER",
  "isPremiumActive": true,
  "menuItems": [
    {
      "label": "Matches",
      "icon": "horse-riding",
      "route": "/matches",
      "requiresPremium": true
    },
    {
      "label": "Notifications",
      "icon": "bell",
      "route": "/notifications",
      "requiresPremium": false
    },
    {
      "label": "Subscription info",
      "icon": "credit-card",
      "route": "/subscription",
      "requiresPremium": false
    },
    {
      "label": "Contact",
      "icon": "phone",
      "route": "/contact",
      "requiresPremium": false
    },
    {
      "label": "Terms and Conditions",
      "icon": "document",
      "route": "/terms",
      "requiresPremium": false
    },
    {
      "label": "Privacy Policy",
      "icon": "lock",
      "route": "/privacy",
      "requiresPremium": false
    },
    {
      "label": "Rate us",
      "icon": "star",
      "route": "/rate",
      "requiresPremium": false
    }
  ]
}
```

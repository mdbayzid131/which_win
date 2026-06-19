# Subscription Configuration - Product IDs

This file records the final Product IDs and configurations set up in App Store Connect and Google Play Console for subscription plans.

## iOS (Apple App Store Connect)

iOS uses independent Product IDs for each subscription tier:

- **Weekly Plan**: `com.whichwin.horseracing.weekly`
- **Monthly Plan**: `com.whichwin.horseracing.monthly`
- **Yearly Plan**: `com.whichwin.horseracing.yearly`

---

## Android (Google Play Console)

Android uses Google Play's new subscription model, utilizing a single main Subscription Product ID with multiple nested Base Plans:

- **Subscription Product ID**: `com.whichwin.horseracing.premium`
- **Base Plans**:
  - **Weekly Plan**: `weekly-plan`
  - **Monthly Plan**: `monthly-plan`
  - **Yearly Plan**: `yearly-plan`

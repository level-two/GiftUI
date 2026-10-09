# Repair accounting

1. After trial 05, enable `LifetimeDependence` for B. The pinned compiler's
   diagnostic explicitly requires it for the selected `@lifetime` declarations.
   This is an experimental candidate build flag, not a production build change
   or evidence that the maintained compiler configuration supports the API.

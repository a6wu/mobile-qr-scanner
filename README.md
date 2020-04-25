# TestScan Flutter App

The goal of this is to have a mobile app that a user can scan a barcode.

Features for phase one:

1. Scan barcode
2. Barcode information along with app identifier gets sent to backend via API
3. Backend saves the data and associate with the app identifier, Firebase token
4. App can receive push notification and/or in-app messaging
5. Geolocation tagging at time of barcode scan

Features for phase two:

1. Allow users to sign-in via SSO
2. Associate the barcode data with the user id, app id
3. Allow users to answer survey questions
4. Encryption on local device and in datastore (public/private key setup)

Possible Libraries

1. https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_ml_vision

## Installation Instructions

- [Install Flutter](https://flutter.dev/docs/get-started/install)
  
  - If you are on macOS Catalina, you will have to use [this workaround](https://github.com/flutter/flutter/issues/36714#issuecomment-559937187) when running commands such as `flutter doctor`

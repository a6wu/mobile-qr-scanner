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

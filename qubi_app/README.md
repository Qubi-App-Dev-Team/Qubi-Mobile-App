# qubi_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

You can find general documentation for Flutter at: https://docs.flutter.dev/
Detailed API documentation is available at: https://api.flutter.dev/
If you prefer video documentation, consider: https://www.youtube.com/c/flutterdev

In order to run your application, type:

  $ cd qubi_app
  $ flutter run

# Setup
## Android

1. Download Android Studios: https://developer.android.com/studio (download the latest release)
2. Open the app and follow the default setup instructions
3. More actions -> Virtual Device Manager -> Hit the plus button -> Choose Pixel 9 Pro -> Next -> Finish
4. Wait for it to download -> Finish -> x out of the window with the list of phones and return to the home page
5. More actions -> SDK Manager -> SDK Tools -> Select Android SDK Command Line Tools -> Hit Ok and wait for download
6. Run flutter doctor (you should see that android studio is installed but you do not have all of the necessary installations)
7. Run flutter doctor --android-licences
8. On VSCode, install the flutter and pubspec assist extensions.
9. In android studio find the Pixel 9 Pro and hit the three dots and select Wipe Data
10. In the VSCode search bar, type >Flutter: Select Device.
11. Click the corresponding button and then select the phone you want to run.

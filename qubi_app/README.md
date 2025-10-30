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

   `cd qubi_app`  
   `flutter run`  

# Setup
## Android Emulator
1. Download Android Studios: https://developer.android.com/studio (download the latest release)
2. Open the app and follow the default setup instructions
3. More actions -> Virtual Device Manager -> Hit the plus button -> Choose Pixel 9 Pro -> Next -> Finish
4. Wait for it to download -> Finish -> x out of the window with the list of phones and return to the home page
5. More actions -> SDK Manager -> SDK Tools -> Select Android SDK Command Line Tools -> Hit Ok and wait for download
6. Run `flutter doctor` (you should see that android studio is installed but you do not have all of the necessary installations)
7. Run `flutter doctor --android-licences`
8. On VSCode, install the flutter and pubspec assist extensions.
9. In android studio find the Pixel 9 Pro and hit the three dots and select Wipe Data
10. In the VSCode search bar, type >Flutter: Select Device.
11. Click the corresponding button and then select the phone you want to run.


## Ios Simulator (on MacOS only!!)
### Prerequisites
1. Ensure you have homebrew installed. https://brew.sh/
2. Install cocoapods with homebrew: `brew install cocoapods``
3. Set up xCode, agree to the license, set up command line tools:
- `open -a Xcode`
- `sudo xcodebuild -license`
- `xcode-select --install`

### Simulator
4. Open the ios simulator
`open -a Simulator`
- may need to install an ios simulator in the Simulator app:
  - open Xcode → Settings → Platforms → iOS 
  - select simulators tab
  - create a new simulator, name it whatever you want & select an ios version & phone model. 

### Running the flutter app
5. Set up flutter environment
`flutter pub get`
6. Ensure everything is properly installed:
`flutter doctor`
- if there are any [X]'s, may need to fix those
7. `flutter run`
- flutter will automatically select a booted simulator.
- to select a certain named simulator, e.g. iPhone-15,
`flutter run -d iPhone-15`

### Troubleshooting
- **If cocoapods gives errors, try:**  
`cd ios`   
`pod install`  
If you’re on Apple Silicon (M1/M2/M3), use: `arch -x86_64 pod install`


- **DO NOT INCLUDE THE LINE**: CODE_SIGNING_ALLOWED = NO  
in qubi_app/ios/Flutter/Release.xcconfig or  
qubi_app/ios/Flutter/Debug.xcconfig  
anymore. it will break login. 
# Crisp Chat

A flutter plugin package for using crisp chat natively on Android & iOS.

![Crisp Chat](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/image-1.png?raw=true)

<p align="center">
  <a href="https://pub.dev/packages/crisp_chat"><img alt="pub version" src="https://img.shields.io/pub/v/crisp_chat?color=%2300b0ff&label=crisp_chat&style=flat-square"></a>
  <a href="https://github.com/alamin-karno/flutter-crisp-chat/commits/main/"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/alamin-karno/flutter-crisp-chat?color=%23ffa000&style=flat-square"/></a>
  <a href="https://github.com/alamin-karno/flutter-crisp-chat?tab=MIT-1-ov-file"><img alt="License" src="https://img.shields.io/github/license/alamin-karno/flutter-crisp-chat?style=flat-square"/></a>
  <a href="https://github.com/alamin-karno/flutter-crisp-chat/graphs/contributors"><img alt="GitHub Contributors" src="https://img.shields.io/github/contributors/alamin-karno/flutter-crisp-chat"></a>
  <a href="https://pub.dev/packages/crisp_chat"><img alt="Stars" src="https://img.shields.io/github/stars/alamin-karno/flutter-crisp-chat?style=social"/></a>
  <a href="https://github.com/alamin-karno/flutter-crisp-chat/issues?q=is%3Aissue+is%3Aclosed"><img alt="GitHub Closed Issues" src="https://img.shields.io/github/issues-closed-raw/alamin-karno/flutter-crisp-chat"></a>
  <a href="patreon.com/alamin_karno"><img alt="Sponsors" src="https://img.shields.io/github/sponsors/alamin-karno"></a>
  <span class="badge-buymeacoffee">
     <a href="https://buymeacoffee.com/alaminkarno" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee Donate Button" /></a>
  </span>
</p>

Chat with website visitors, integrate your favorite tools, and deliver a great customer experience. - Crisp. The `Crisp Chat` is a package that provides a simple way to open chat window using native channel. Connect with Crisp Chat, register a user to chat (or not) and render a chat widget. Tested on Android and iOS. 

`Note: If anyone want to contribute on this project is most welcome. If you have any idea or suggestion, please feel free to contact me.`



## Features

- [x] Null-safety enable
- [x] Easy to use
- [x] Customizable
- [x] User configuration with company and geoLocation
- [x] Supports for iOS & Android

## Installation

First, add `crisp_chat` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

To use the Flutter Crisp Chat, simply import the `crisp_chat` package:

Run this on your project terminal:

```yaml
flutter pub add crisp_chat
```

or manually configure pubspec.yml file

```yaml
dependencies:
  flutter:
    sdk: flutter
  crisp_chat: ^2.0.2
```

### iOS

Add two rows to the `ios/Runner/Info.plist`:

* key `Privacy - Camera Usage Description` and a usage description.
* key `Privacy - Photo Library Additions Usage Description` and a usage description.
* key `Privacy - Microphone Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

### Android

Add Internet permission on `AndroidManifest.xml` in your `android/app/src/main/AndroidManifest.xml` file.

```groovy
<uses-permission android:name="android.permission.INTERNET"/>
```


Change the minimum Compile SDK version to 34 (or higher) in your `android/app/build.gradle` file.

```groovy
compileSdkVersion 34
```

Change the minimum Android SDK version to 21 (or higher) in your `android/app/build.gradle` file.


```groovy
minSdkVersion 21
```


## Usage
To open ChatView for crisp, use the `openCrispChat` method of the `FlutterCrispChat` class:

##### First Imported Package:

```dart
import 'package:crisp_chat/crisp_chat.dart';
```

##### Then:

```dart
 final String websiteID = 'YOUR_WEBSITE_KEY';
 late CrispConfig config;

   @override
  void initState() {
    super.initState();
    config = CrispConfig(
      websiteID: websiteID,
    );
  }
```


 ```dart 
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crisp Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await FlutterCrispChat.openCrispChat(config: config);
                },
                child: const Text('Open Crisp Chat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FlutterCrispChat.resetCrispChatSession();
                },
                child: const Text('Reset Chat Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  ```

To use this code, you will need to provide your own Crisp website ID. You can do this by replacing `YOUR_WEBSITE_KEY` with your own website ID. Once you have done this, you can run the app and press the `"Open Crisp Chat"` button to launch the chat window. You can add more information using `CrispConfig`.

### Get your Website ID:
Go to your [Crisp Dashboard](https://app.crisp.chat/), and copy your Website ID:

![Crisp Dashboard](https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/image.png?raw=true)

## Screenshot (GIF)

|             Android  (GIF)            |              iOS    (GIF)          |
|:---------------------------------------------------:|:---------------------------------------------------:|
| <img src="https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/crisp_android.gif?raw=true" width = "250"> | <img src="https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/crisp_ios.gif?raw=true" width = "250"> |
|             Android  (Image)            |              iOS    (Image)          |
| <img src="https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/crisp_android.png?raw=true" width = "250"> | <img src="https://github.com/alamin-karno/flutter-crisp-chat/blob/main/example/screenshots/crisp_ios.png?raw=true" width = "250"> |

## Additional information

- [Flutter Crisp Chat (pub.dev)](https://pub.dev/packages/crisp_chat)
- [Flutter Crisp Chat (GitHub)](https://github.com/alamin-karno/flutter-crisp-chat)

<h3 align=center> Project Maintainer ❤️ </h3>
<p align="center">
<table align="center">
  <tbody><tr>
     <td align="center">
     <a href="https://github.com/alamin-karno">
     <img alt="Md. Al-Amin" src="https://avatars.githubusercontent.com/alamin-karno" width="125px;"> <br>
     <sub><b> Md. Al-Amin </b></sub>
     </a><br></td></tr>
     </tbody> </table> </p>


<h3 align="center"> ✨VALUABLE CONTRIBUTORS✨ </h3>
<p align="center">
<a href="https://github.com/alamin-karno/flutter-crisp-chat/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=alamin-karno/flutter-crisp-chat" />
</a>
</p>
<h3 align="center"> Happy Coding 👨‍💻 </h3>

## Credits
* Crisp Android and iOS SDK is owned and maintained by [Crisp IM SAS](https://crisp.chat/en/).

 You can chat with them on [crisp](https://crisp.chat/) or follow them on Twitter at [Crisp_im](https://twitter.com/crisp_im).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

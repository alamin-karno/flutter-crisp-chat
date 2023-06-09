# Crisp Chat

A flutter plugin package for using crisp chat natively on Android & iOS.

The `Crisp Chat` is a package that provides a simple way to open chat window using native channel.

Note: This plugin is still under development, anyone want to contribute on this project is most welcome. If you have any idea or suggestion, please feel free to contact me.

<p align="center">
  <a href="https://pub.dev/packages/crisp_chat"><img alt="pub version" src="https://img.shields.io/pub/v/crisp_chat?color=%2300b0ff&label=crisp_chat&style=flat-square"></a>
  <img alt="last commit" src="https://img.shields.io/github/last-commit/alamin-karno/flutter-crisp-chat?color=%23ffa000&style=flat-square"/>
  <img alt="license" src="https://img.shields.io/github/license/alamin-karno/flutter-crisp-chat?style=flat-square"/>
  <img alt="stars" src="https://img.shields.io/github/stars/alamin-karno/flutter-crisp-chat?style=social"/>
</p>

## Features

- [x] Null-safety enable
- [x] Easy to use
- [x] Customizable
- [x] Supports for iOS & Android

## Installation

First, add `crisp_chat` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

To use the Flutter Crisp Chat, simply import the `crisp_chat` package:

Run this on your project terminal:

```yaml
flutter pub add crisp_chat
```

or manually configure pubspec.yml fi

```yaml
dependencies:
  flutter:
    sdk: flutter
  crisp_chat: ^0.0.3
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


Change the minimum Compile SDK version to 33 (or higher) in your `android/app/build.gradle` file.

```groovy
compileSdkVersion 33
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
          child: ElevatedButton(
            onPressed: () async {
              await FlutterCrispChat.openCrispChat(
                websiteID: websiteID,
              );
            },
            child: const Text('Open Crisp Chat'),
          ),
        ),
      ),
    );
  } 
  ```

This is a simple Flutter app that demonstrates how to use the `FlutterCrispChat` plugin to open a chat window using the Crisp chat service. The app has a single button that, when pressed, will launch the chat window.

The main function runs the app, which consists of a single MyApp widget. This widget is stateful and creates an instance of the `FlutterCrispChat` plugin.

The build function creates a MaterialApp with a Scaffold that contains an AppBar and an `ElevatedButton`. The button's onPressed method calls the `openCrispChat` method of the `FlutterCrispChat` plugin with the website ID passed as a parameter.

To use this code, you will need to provide your own Crisp website ID. You can do this by replacing `YOUR_WEBSITE_KEY` with your own website ID. Once you have done this, you can run the app and press the `"Open Crisp Chat"` button to launch the chat window.

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# Contributing to Crisp Chat Flutter Package

Thanks for your interest in contributing to the **Crisp Chat** Flutter Package! Your contributions help improve the experience for everyone using this package. Please take a moment to review this guide before getting started.

---

## 🚀 Getting Started

To run and work on this project locally, follow these steps:

### 1. Fork the Repository

- Click the **Fork** button in the top-right corner of the [repository](https://github.com/alamin-karno/flutter-crisp-chat) page.
- Clone your forked repository to your local machine:

```bash
git clone https://github.com/alamin-karno/flutter-crisp-chat
cd flutter_crisp_chat
```

### 2. Set Up the Example App
The `example` folder contains a Flutter project to test the Crisp Chat plugin.

You’ll need to add some secrets and configurations to run it properly:

### 3. Add Firebase Support

To run this project, you need to add your Firebase configuration files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

These files are not included in this repo for security reasons.

- Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).

- Add an iOS app and an Android app (optional) and get the Firebase auto setup. `If not then follow below steps`.

- Download the `GoogleService-Info.plist` file for iOS and place it in:
```bash
example/ios/Runner/GoogleService-Info.plist
```
- Download the `google-services.json` file for Android and place it in:
```bash
example/android/app/google-services.json
```

_You may also need to enable Firebase Cloud Messaging if you want to test push notifications._

### 4. Add Crisp Website ID

- First, you need to create a Crisp account and set up a website.

- You can get your Website ID from your [Crisp Dashboard](https://app.crisp.chat/).

- Then, create a `config.json` file in the `example/lib/` directory to store your Crisp Website ID.

- In the `example/lib/config.json` provide your Crisp **Website ID**:

   ```json
   {
       "WEBSITE_ID": "PUT_YOUR_WEBSITE_ID_HERE"
   }
   ```

- Then, run your project: 

   ```bash
   flutter run --dart-define-from-file=config.json
   ```
or, you can  add `--dart-define-from-file=config.json` on Android Studio or VSCode run configurations.

---

## 🔧 Contributing Code

### Step-by-step process:

1. Open an Issue

    - Describe what you want to fix or add.
    - Explain your motivation or expected outcome.

2. Create a Feature Branch

    - Always base your changes on a specific issue.
    - Use a clear naming convention:
    ```bash
    git checkout -b fix/issue-23-fix-push-notification
    ```
   
3. Make Your Changes

    - Follow the coding style already present in the plugin.
    - Keep commits atomic and descriptive.
    - If you’re changing native code, test it in the `example` app.

4. Push & Open a Pull Request (PR)

    - Push your branch:
    ```bash
    git push origin fix/issue-23-fix-push-notification
    ```
    - Open a pull request on GitHub, referencing the issue number in the description.

---

## ✅ Code Style & Best Practices

- Use meaningful commit messages. Example:
```scss
fix(iOS): handle missing deviceToken crash on launch
```
- Always test your code using the example project.
- If your change includes a fix or feature, update the README.md if needed.

---

## 💬 Need Help?

If you’re unsure about something, feel free to:
- Create a GitHub Discussion or Issue
- Message the maintainer for clarification
We’re happy to help you get started!

---

Thank you for contributing! 🙌

---

Let me know if you want this tailored further — like adding GitHub Actions setup, lint rules, or commit 


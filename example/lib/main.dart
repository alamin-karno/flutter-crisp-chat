import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter_crisp_chat_example/utils/app_const.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String websiteID = YOUR_WEBSITE_KEY;

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
}

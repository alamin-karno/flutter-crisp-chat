import 'package:flutter/material.dart';
import 'package:flutter_crisp_chat/crisp_chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String websiteID = 'b3f3d31f-f27c-4f54-a9b2-b9db89a86316';

  final _flutterCrispChatPlugin = FlutterCrispChat();

  @override
  void initState() {
    super.initState();
  }

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
              await _flutterCrispChatPlugin.openCrispChat(
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

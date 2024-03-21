import 'package:flutter/material.dart';
import 'package:crisp_chat/crisp_chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String websiteID = "b3f3d31f-f27c-4f54-a9b2-b9db89a86316";
  late CrispConfig config;

  @override
  void initState() {
    super.initState();
    config = CrispConfig(
      websiteID: websiteID,
      tokenId: "Token Id",
      sessionSegment: 'subscriber',
      user: User(
        avatar:
            "https://storage.googleapis.com/cms-storage-bucket/6a07d8a62f4308d2b854.svg",
        email: "user@user.com",
        nickName: "Nick Name",
        phone: "5555555555",
        company: Company(
          companyDescription: "Company Description",
          name: "Company Name",
          url: "https://flutter.dev12",
          employment: Employment(
            role: "Role",
            title: "Tile",
          ),
          geolocation: Geolocation(
            city: "City",
            country: "Country",
          ),
        ),
      ),
    );
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
              await FlutterCrispChat.openCrispChat(config: config);
            },
            child: const Text('Open Crisp Chat'),
          ),
        ),
      ),
    );
  }
}

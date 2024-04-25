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
  final String websiteID = "YOUR_WEBSITE_ID";
  late CrispConfig config;

  @override
  void initState() {
    super.initState();
    config = CrispConfig(
      websiteID: websiteID,
      tokenId: "Token Id",
      sessionSegment: 'test_segment',
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
          geoLocation: GeoLocation(
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
}

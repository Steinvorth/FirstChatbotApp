import 'package:flutter/material.dart';
import 'package:first_chat_app/Theme/index.dart';
import 'package:first_chat_app/Pages/index.dart';

void main() {
  runApp(const FirstChatApp());
}

class FirstChatApp extends StatelessWidget {
  const FirstChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ChatPage(),
    );
  }
}

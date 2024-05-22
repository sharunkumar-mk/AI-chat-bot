import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AI chat bot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController userMessage = TextEditingController();

  static const apiKey = "AIzaSyAxSbALRtjB5TDoBPOVJiErK9GUTE-3OWM";

  final model = GenerativeModel(apiKey: apiKey, model: 'gemini-1.5-pro-latest');

  final List<Message> messages = [];

  bool isGenerating = false;

  Future<void> sendMessage() async {
    final message = userMessage.text.trim();
    userMessage.clear();
    setState(() {
      messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
    });
    isGenerating = true;
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    isGenerating = false;
    setState(() {
      messages.add(Message(
          isUser: false, message: response.text ?? '', date: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isGenerating
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Messages(
                      isUser: message.isUser,
                      message: message.message,
                      date: DateFormat('HH:mm').format(message.date));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: userMessage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(Icons.send))
                ],
              ),
            )
          ],
        ));
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10)
          .copyWith(left: isUser ? 100 : 10, right: isUser ? 10 : 100),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isUser ? Colors.blue.shade300 : Colors.blue.shade100),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(message), Text(date)],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}

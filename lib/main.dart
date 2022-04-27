import 'package:flutter/material.dart';
import 'dart:isolate';

void main() {
  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SampleAppPage(),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  const SampleAppPage({Key? key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  String textLabel = "Initial";

  @override
  void initState() {
    super.initState();
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sample App"),
        ),
        body: Center(child: Text(textLabel)));
  }

  loadData() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(dataLoader, receivePort.sendPort);


    SendPort sendPort = await receivePort.first;

    ReceivePort response = ReceivePort();
    sendPort.send(["Mike, I'm taking an Espresso coffee",
      "Espresso", response.sendPort]);

    String msg = await response.first;

    setState(() {
      textLabel = msg;
    });
  }

// the entry point for the isolate
  static dataLoader(SendPort sendPort) async {
    // Open the ReceivePort for incoming messages.
    ReceivePort port = ReceivePort();

    // Notify any other isolates what port this isolate listens to.
    sendPort.send(port.sendPort);

    await for (var msg in port) {
      if (msg is List) {
        final myMessage = msg[0];
        final coffeeType = msg[1];

        SendPort replyTo = msg[2];
        replyTo.send("$myMessage: You're taking $coffeeType, and I'm taking Latte");

      }
    }
  }
}
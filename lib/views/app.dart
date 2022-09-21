import 'package:flutter/material.dart';
import 'package:flutter_nn/views/imageView.dart';
import 'root.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Flutter Neural Network",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(41, 41, 51, 1),
        // body: ImageView(),
        body: MnistGuess(),
      ),
    );
  }
}

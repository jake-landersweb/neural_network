import 'package:flutter/material.dart';
import 'root.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

const themeColor = Color.fromRGBO(65, 65, 160, 1);

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Neural Network",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(47, 47, 57, 1),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Color.fromRGBO(230, 230, 255, 1),
            fontSize: 18,
          ),
          bodyText2: TextStyle(
            color: Color.fromRGBO(230, 230, 255, 0.5),
            fontSize: 18,
          ),
          headline1: TextStyle(
            color: Color.fromRGBO(230, 230, 255, 1),
            fontSize: 22,
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: themeColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding:
                MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(16)),
            side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(color: Color.fromRGBO(230, 230, 255, 0.2)),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 18)),
            overlayColor:
                MaterialStateProperty.all<Color>(themeColor.withOpacity(0.2)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(230, 230, 255, 1),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      color: Colors.green,
      home: const Scaffold(
        // body: Index(),
        body: MnistGuess(),
      ),
    );
  }
}

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const Scaffold(
          //           body: NavWrapper(child: MnistView()),
          //         ),
          //       ),
          //     );
          //   },
          //   child: const Text("Mnist View"),
          // ),
          // const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Scaffold(
                    body: NavWrapper(child: MnistGuess()),
                  ),
                ),
              );
            },
            child: const Text("Mnist Guess"),
          ),
          // const SizedBox(height: 16),
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => const Scaffold(
          //           body: NavWrapper(child: CreateDataset()),
          //         ),
          //       ),
          //     );
          //   },
          //   child: const Text("Generate Dataset"),
          // ),
        ],
      ),
    );
  }
}

class NavWrapper extends StatelessWidget {
  const NavWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
      ],
    );
  }
}

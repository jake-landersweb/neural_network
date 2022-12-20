import 'package:flutter/material.dart';
import 'package:flutter_neural_network/views/mnist_view.dart';
import 'package:flutter_neural_network/views/network_visual/root.dart';
import 'root.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

const themeColor = Color.fromRGBO(137, 107, 255, 1);
const backgroundAcc = Color.fromRGBO(20, 25, 32, 1);

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter NN",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(14, 18, 25, 1),
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
      color: themeColor,
      home: const Scaffold(
        // body: Index(),
        // body: MnistGuess(),
        // body: MnistView(),
        body: NetworkVisual(),
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

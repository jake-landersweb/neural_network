import 'package:flutter/material.dart';
import 'package:flutter_neural_network/old/layers/root.dart';
import 'package:flutter_neural_network/views/network_visual/nv_model.dart';
import 'package:flutter_neural_network/views/network_visual/root.dart';
import 'package:flutter_neural_network/views/root.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

class NetworkVisual extends StatelessWidget {
  const NetworkVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NetworkVisualModel(),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final model = Provider.of<NetworkVisualModel>(context);
    if (model.network == null) {
      return const CircularProgressIndicator(color: themeColor);
    } else {
      return Row(
        children: [
          for (int i = 0; i < model.network!.layers.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: LayerView(layer: i),
            ),
        ],
      );
    }
  }
}

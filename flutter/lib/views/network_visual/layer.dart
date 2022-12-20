import 'package:flutter/material.dart';
import 'package:flutter_neural_network/views/network_visual/root.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class LayerView extends StatelessWidget {
  const LayerView({
    super.key,
    required this.layer,
  });
  final int layer;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NetworkVisualModel>(context);
    return Column(
      children: [
        for (int i = 0;
            i < math.min(10, model.network!.layers[layer].shape()[0]);
            i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Neuron(layer: layer, index: i),
          ),
      ],
    );
  }
}

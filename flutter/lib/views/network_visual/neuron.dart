import 'package:flutter/material.dart';
import 'package:flutter_neural_network/views/network_visual/nv_model.dart';
import 'package:flutter_neural_network/views/root.dart';
import 'package:sprung/sprung.dart';
import 'package:provider/provider.dart';

class Neuron extends StatelessWidget {
  const Neuron({
    super.key,
    required this.layer,
    required this.index,
  });
  final int layer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<NetworkVisualModel>(context);
    return Container(
      height: networkHeight,
      width: networkHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: themeColor, width: 4),
      ),
      child: Center(
        child: Text(
          model.getNeuronValue(layer, index).toStringAsPrecision(2),
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

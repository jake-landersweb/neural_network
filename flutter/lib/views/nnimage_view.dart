import 'package:flutter/material.dart';
import 'package:flutter_neural_network/old/datasets/nnimage.dart';

/// takes an NNImage and renders it in a
/// [size]x[size] grid. Optionally, you can specify
/// [pixelSize] for the size of the container.
class NNImageView extends StatelessWidget {
  final NNImage image;
  final double pixelSize;
  final Color backgroundColor;

  const NNImageView({
    super.key,
    required this.image,
    this.pixelSize = 10,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < image.size; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int j = 0; j < image.size; j++)
                    Container(
                      height: pixelSize,
                      width: pixelSize,
                      color: Colors.white
                          .withOpacity(image.image[(i * image.size) + j]),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

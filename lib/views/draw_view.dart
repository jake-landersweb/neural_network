import 'package:flutter/material.dart';

/// Creates a drawable grid that will return the
/// pixel values in the format of a [gridSize]x[gridSize]
/// list of doubles corresponding to the opacity value
/// of `Colors.white`. You can specify [millisecondUpdateDelay]
/// to determine how often [onDraw] will be called. It is
/// recommended to keep this value >100, otherwise there will
/// be some considerable lag.
class DrawView extends StatefulWidget {
  final int gridSize;
  final int pixelSize;
  final Color backgroundColor;
  final int millisecondUpdateDelay;
  final void Function(List<List<double>>) onDraw;

  const DrawView({
    super.key,
    this.gridSize = 28,
    this.pixelSize = 10,
    this.backgroundColor = Colors.black,
    this.millisecondUpdateDelay = 100,
    required this.onDraw,
  });

  @override
  State<DrawView> createState() => _DrawViewState();
}

class _DrawViewState extends State<DrawView> {
  final GlobalKey _widgetKey = GlobalKey();

  List<List<double>>? _drawValues;
  // canvas size and position on the screen
  Size? _canvasSize;
  Offset? _canvasOffset;

  // for keeping track of last updated value
  int _cachedEpoch = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    // load all pixels to black
    _drawValues = List.generate(widget.gridSize,
        (_) => List.generate(widget.gridSize, (_) => 0, growable: false),
        growable: false);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_getWidgetInfo);
  }

  void _getWidgetInfo(_) {
    final RenderBox renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;

    final Size size = renderBox.size;
    _canvasSize = size;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    _canvasOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              // recalculate the widget offset every draw point in case screen has moved
              _getWidgetInfo("");
              if (_drawValues != null) {
                _calculateIntersection(details.globalPosition);
              }
            },
            onTapDown: (details) {
              // recalculate the widget offset every draw point in case screen has moved
              _getWidgetInfo("");
              if (_drawValues != null) {
                _calculateIntersection(details.globalPosition);
              }
            },
            child: Center(
              child: Container(
                color: widget.backgroundColor,
                child: _drawValues == null
                    ? SizedBox(
                        height: (widget.gridSize * widget.pixelSize).toDouble(),
                        width: (widget.gridSize * widget.pixelSize).toDouble(),
                      )
                    : Column(
                        key: _widgetKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.gridSize; i++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var j = 0; j < widget.gridSize; j++)
                                  DrawCell(
                                    opacity: _drawValues![i][j],
                                    pixelSize: widget.pixelSize,
                                  ),
                              ],
                            ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _resetCanvas();
              });
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  int currentPixelX = -1;
  int currentPixelY = -1;
  void _calculateIntersection(Offset drawPosition) {
    if (_canvasSize != null && _canvasOffset != null) {
      // get the local position inside the draw grid
      var localX = drawPosition.dx - _canvasOffset!.dx;
      var localY = drawPosition.dy - _canvasOffset!.dy;
      // calculate what pixel this is based on pixel size
      // flip the pixels to get the correct mapping for the mnist dataset
      int pixelY = localX ~/ widget.pixelSize;
      int pixelX = localY ~/ widget.pixelSize;

      // only update values when pan is within bounds
      if ((currentPixelX != pixelX || currentPixelY != pixelY) &&
          pixelX > -1 &&
          pixelX < widget.gridSize &&
          pixelY > -1 &&
          pixelY < widget.gridSize) {
        // set pixel to white
        setState(() {
          _drawValues![pixelX][pixelY] = 1;
        });
        // add some opacity to surrounding pixels
        if (pixelX > 0 &&
            pixelX < (widget.gridSize - 1) &&
            pixelY > 0 &&
            pixelY < (widget.gridSize - 1)) {
          if (_drawValues![pixelX - 1][pixelY] == 0) {
            _drawValues![pixelX - 1][pixelY] = 0.3;
          } else if (_drawValues![pixelX - 1][pixelY] == 0.3) {
            _drawValues![pixelX - 1][pixelY] = 1;
          }
          if (_drawValues![pixelX][pixelY - 1] == 0) {
            _drawValues![pixelX][pixelY - 1] = 0.3;
          } else if (_drawValues![pixelX][pixelY - 1] == 0.3) {
            _drawValues![pixelX][pixelY - 1] = 1;
          }
          // update the state
          setState(() {});
        }
        // set cache values
        currentPixelX = pixelX;
        currentPixelY = pixelY;
        // do not send updates too frequently
        if (DateTime.now().millisecondsSinceEpoch - _cachedEpoch >
            widget.millisecondUpdateDelay) {
          // send update to encapsulating view
          widget.onDraw(_drawValues!);
          _cachedEpoch = DateTime.now().millisecondsSinceEpoch;
        }
      }
    }
  }

  void _resetCanvas() {
    _drawValues = List.generate(
        widget.gridSize, (_) => List.generate(widget.gridSize, (_) => 0));
    widget.onDraw(_drawValues!);
  }
}

class DrawCell extends StatefulWidget {
  final int pixelSize;
  final double opacity;
  const DrawCell({
    super.key,
    required this.opacity,
    required this.pixelSize,
  });

  @override
  State<DrawCell> createState() => _DrawCellState();
}

class _DrawCellState extends State<DrawCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.pixelSize.toDouble(),
      height: widget.pixelSize.toDouble(),
      decoration:
          BoxDecoration(color: Colors.white.withOpacity(widget.opacity)),
    );
  }
}

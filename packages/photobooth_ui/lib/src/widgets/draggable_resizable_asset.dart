import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photobooth_ui/photobooth_ui.dart';

const _cornerDiameter = 15.0;

/// {@template draggable_resizable_asset}
/// A widget which allows a user to drag and resize the provided [asset].
/// {@endtemplate}
class DraggableResizableAsset extends StatefulWidget {
  /// {@macro draggable_resizable_asset}
  DraggableResizableAsset({Key? key, required this.asset}) : super(key: key);

  /// The asset which will be rendered and will be draggable and resizable.
  final Asset asset;

  @override
  _DraggableResizableAssetState createState() =>
      _DraggableResizableAssetState();
}

class _DraggableResizableAssetState extends State<DraggableResizableAsset> {
  late double height;
  late double width;
  late double minHeight;
  late double maxHeight;
  late double minWidth;
  late double maxWidth;

  double top = 0;
  double left = 0;

  @override
  void initState() {
    super.initState();
    maxHeight = widget.asset.image.height.toDouble();
    minHeight = maxHeight * 0.5;
    height = maxHeight * 0.75;

    maxWidth = widget.asset.image.width.toDouble();
    minWidth = maxWidth * 0.5;
    width = maxWidth * 0.75;
  }

  double _getNewHeight(double value) {
    if (value >= maxHeight) return maxHeight;
    if (value <= minHeight) return minHeight;
    return value;
  }

  double _getNewWidth(double value) {
    if (value >= maxWidth) return maxWidth;
    if (value <= minWidth) return minWidth;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //Image
        Positioned(
          top: top,
          left: left,
          child: _DraggablePoint(
            key: const Key('draggableResizableAsset_image_draggablePoint'),
            onDrag: (dx, dy) {
              setState(() {
                top = top + dy;
                left = left + dx;
              });
            },
            child: Container(
              height: height,
              width: width,
              child: Image.memory(
                Uint8List.fromList(widget.asset.bytes),
                height: height,
                width: width,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
        // Top Left Corner
        Positioned(
          top: top - _cornerDiameter / 2,
          left: left - _cornerDiameter / 2,
          child: _ResizePoint(
            key: const Key('draggableResizableAsset_topLeft_resizePoint'),
            onDrag: (dx, dy) {
              final mid = (dx + dy) / 2;
              final tempNewHeight = height - 2 * mid;
              final tempNewWidth = width - 2 * mid;
              if (tempNewHeight >= maxHeight || tempNewHeight <= minHeight) {
                return;
              }

              setState(() {
                height = _getNewHeight(tempNewHeight);
                width = _getNewWidth(tempNewWidth);
                top = top + mid;
                left = left + mid;
              });
            },
          ),
        ),

        // Top Right corner
        Positioned(
          top: top - _cornerDiameter / 2,
          left: left + width - _cornerDiameter / 2,
          child: _ResizePoint(
            key: const Key('draggableResizableAsset_topRight_resizePoint'),
            onDrag: (dx, dy) {
              final mid = (dx + (dy * -1)) / 2;
              final tempNewHeight = height + 2 * mid;
              final tempNewWidth = width + 2 * mid;

              if (tempNewHeight >= maxHeight || tempNewHeight <= minHeight) {
                return;
              }

              setState(() {
                height = _getNewHeight(tempNewHeight);
                width = _getNewWidth(tempNewWidth);
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),

        // Bottom right corner
        Positioned(
          top: top + height - _cornerDiameter / 2,
          left: left + width - _cornerDiameter / 2,
          child: _ResizePoint(
            key: const Key('draggableResizableAsset_bottomRight_resizePoint'),
            onDrag: (dx, dy) {
              final mid = (dx + dy) / 2;
              final tempNewHeight = height + 2 * mid;
              final tempNewWidth = width + 2 * mid;

              if (tempNewHeight >= maxHeight || tempNewHeight <= minHeight) {
                return;
              }

              setState(() {
                height = _getNewHeight(tempNewHeight);
                width = _getNewWidth(tempNewWidth);
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),

        // Bottom left corner
        Positioned(
          top: top + height - _cornerDiameter / 2,
          left: left - _cornerDiameter / 2,
          child: _ResizePoint(
            key: const Key('draggableResizableAsset_bottomLeft_resizePoint'),
            onDrag: (dx, dy) {
              final mid = ((dx * -1) + dy) / 2;
              final tempNewHeight = height + 2 * mid;
              final tempNewWidth = width + 2 * mid;

              if (tempNewHeight >= maxHeight || tempNewHeight <= minHeight) {
                return;
              }

              setState(() {
                height = _getNewHeight(tempNewHeight);
                width = _getNewWidth(tempNewWidth);
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _ResizePoint extends StatelessWidget {
  const _ResizePoint({Key? key, required this.onDrag}) : super(key: key);

  final void Function(double, double) onDrag;

  @override
  Widget build(BuildContext context) {
    return _DraggablePoint(
      child: Container(
        width: _cornerDiameter,
        height: _cornerDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
      onDrag: onDrag,
    );
  }
}

class _DraggablePoint extends StatefulWidget {
  const _DraggablePoint({Key? key, required this.child, required this.onDrag})
      : super(key: key);

  final Widget child;
  final void Function(double, double) onDrag;

  @override
  _DraggablePointState createState() => _DraggablePointState();
}

class _DraggablePointState extends State<_DraggablePoint> {
  late double initX;
  late double initY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        initX = details.globalPosition.dx;
        initY = details.globalPosition.dy;
      },
      onPanUpdate: (details) {
        final dx = details.globalPosition.dx - initX;
        final dy = details.globalPosition.dy - initY;
        initX = details.globalPosition.dx;
        initY = details.globalPosition.dy;
        widget.onDrag(dx, dy);
      },
      child: widget.child,
    );
  }
}

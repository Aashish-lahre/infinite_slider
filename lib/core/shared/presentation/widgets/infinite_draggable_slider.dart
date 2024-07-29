import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vice_app/core/shared/presentation/widgets/draggable_widget.dart';

import '../../domain/entities/magazine.dart';
import 'magazine_cover_image.dart';


class InfiniteDraggableSlider extends StatefulWidget {
  const InfiniteDraggableSlider({
    super.key, required this.itemBuilder, required this.itemCount, this.index = 0,
  });

  // final Function(BuildContext context, int index) itemBuilder;
  // Above code is commented by me because "Function(BuildContext context, int index)" does not define
  // what type of Function it is, that is why it has a dynamic type.

  // But IndexedWidgetBuilder explicitly defines itemBuilder has a widget type

  // final IndexedWidgetBuilder itemBuilder;

  // or I can use even more understandable code by adding Widget type
  final Widget Function(BuildContext context, int index) itemBuilder;

  final int itemCount;

  final int index;

  @override
  State<InfiniteDraggableSlider> createState() => _InfiniteDraggableSliderState();
}

class _InfiniteDraggableSliderState extends State<InfiniteDraggableSlider> with SingleTickerProviderStateMixin {
  double defaultAngle18Degree = pi * .1;
  late AnimationController _animationController;
  late int _index;

  slidDirection slideDirection = slidDirection.left;
  Offset getOffset(int stackIndex) {
    return {
      0: Offset(lerpDouble(0, -70, _animationController.value)!, 30),
      1: Offset(lerpDouble(-70, 70, _animationController.value)!, 30),
      2: Offset(70, 30) * (1 - _animationController.value),

    }[stackIndex] ?? Offset(MediaQuery.of(context).size.width * _animationController.value * (slideDirection == slidDirection.left ? 1 : -1), 0);
  }

  double getAngle(int stackIndex) => {
    0: lerpDouble(0, -defaultAngle18Degree, _animationController.value),
    1: lerpDouble(-defaultAngle18Degree, defaultAngle18Degree, _animationController.value),
    2: lerpDouble(defaultAngle18Degree, 0, _animationController.value),

  }[stackIndex] ?? 0.0;
  
  double getScale(int stackIndex) => {
    0:lerpDouble(0.5, .6, _animationController.value),
    1: lerpDouble(.6, .65, _animationController.value),
    2: lerpDouble(.65, .7, _animationController.value),
  }[stackIndex] ?? 0.7;

  void onSlideOut(slidDirection direction) {
    slideDirection = direction;
    _animationController.forward();
  }

  void animationListener() {
    if(_animationController.isCompleted) {

      setState(() {
        if(widget.itemCount == ++_index) {
          print("entered");
          _index = 0;
        }

      });
      _animationController.reset();
    }
  }

@override
  void initState() {
    _index = widget.index;
    _animationController = AnimationController(vsync: this, duration: kThemeAnimationDuration)..addListener(animationListener); // 200 millisecond

    super.initState();
  }

  @override
  void dispose() {
    _animationController..removeListener(animationListener)..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Stack(
        
            children: List.generate(4, (stackIndex) {
              final modIndex = (_index + 3 - stackIndex) % widget.itemCount;
        
              return Transform.translate(
                  offset: getOffset(stackIndex),
                  child: Transform.scale(
                      scale: getScale(stackIndex),
                      child: Transform.rotate(
                          angle: getAngle(stackIndex),
                          child: DraggableWidget(child: widget.itemBuilder(context, modIndex),
        
                              onSlideOut: onSlideOut,
                              isEnableDrag: stackIndex == 3))));
            }));
      }
    );
  }
}
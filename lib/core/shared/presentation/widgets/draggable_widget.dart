import 'dart:math';
import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  const DraggableWidget({super.key, required this.child, this.onSlideOut,  this.onPressed, required this.isEnableDrag});

  final Widget child;
  final ValueChanged<slidDirection>? onSlideOut;
  final VoidCallback? onPressed;
  final bool isEnableDrag;



  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

enum slidDirection {
  left, right
}

class _DraggableWidgetState extends State<DraggableWidget> with SingleTickerProviderStateMixin {

  late AnimationController restoreController;
  late Size screenSize;
  final _widgetKey = GlobalKey();
  Offset startOffset = Offset.zero;
  Offset panOffset = Offset.zero;
  bool warningVibration = false;
  bool reliefVibration = true;
  Size size = Size.zero;
  late Offset initialMagazineCardPosition;
  double angle = 0;

  bool isMadeSlide = false;

  double get outSizeLimitLeft => size.width * 0.05;
  double get outSizeLimitRight => size.width * 0.95;


  void getChildSize() {
    size = (_widgetKey.currentContext?.findRenderObject() as RenderBox?)?.size  ?? Size.zero;
  }

  void getInitialMagazineCardPosition() {
    initialMagazineCardPosition = (_widgetKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Offset get getCurrentPosition {
    final renderBox = (_widgetKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero);
    return renderBox ?? Offset.zero;

  }

  double get getCurrentAngle {


    return getCurrentPosition.dx < initialMagazineCardPosition.dx ?  ((pi * 0.2) * (getCurrentPosition.dx + size.width - screenSize.width)/size.width)
        : getCurrentPosition.dx + size.width > screenSize.width ? (pi * 0.2) * (getCurrentPosition.dx + size.width - screenSize.width)/size.width
        : 0;
  }

  @override
  void initState() {
    restoreController = AnimationController(vsync: this, duration: kThemeAnimationDuration)..addListener(restoreAnimationListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getChildSize();
      getInitialMagazineCardPosition();
      screenSize = MediaQuery.of(context).size;
    });
    super.initState();
  }

  @override
  void dispose() {
    restoreController..removeListener(restoreAnimationListener)..dispose();
    super.dispose();
  }

  void onPanStart(DragStartDetails details) {

    if(!restoreController.isAnimating) {
      setState(() {
        startOffset = details.localPosition;
      });
    }
  }

  void warningVibrationFun() async {


    if(warningVibration == false) {
      warningVibration = true;
      reliefVibration = false;
      // made vibration
      if (await Vibration.hasVibrator() != null) {
        Vibration.vibrate(amplitude: 128);
      }
      setState(() {});

    }
  }

  void reliefVibrationFun() async {
    if (reliefVibration == false) {
      print('entered');
      reliefVibration = true;
      warningVibration = false;
      // made vibration
      if (await Vibration.hasVibrator() != null) {
        Vibration.vibrate(amplitude: 128 );
      }
      setState(() {});

    }
  }

  void onPanUpdate(DragUpdateDetails details) async {
    if(!restoreController.isAnimating) {
      print("warning: $warningVibration");
      print("relief : $reliefVibration");

      final positionX = getCurrentPosition.dx;

      // print("entered in pan update");

      if (positionX < outSizeLimitLeft || positionX > outSizeLimitRight) {

        warningVibrationFun();
        isMadeSlide = widget.onSlideOut != null;


      }

      if (positionX > outSizeLimitLeft && positionX < outSizeLimitRight) {

        reliefVibrationFun();
      }




      setState(() {
        panOffset = details.localPosition - startOffset;
        angle = getCurrentAngle;

      });

    }
  }

  void onPanEnd(DragEndDetails details) {
    if(restoreController.isAnimating) return;
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final velocityY = details.velocity.pixelsPerSecond.dy;
    final positionX = getCurrentPosition.dx;
    final positionY = getCurrentPosition.dy;




    if (velocityX < -1000 || positionX < outSizeLimitLeft) {
      isMadeSlide = widget.onSlideOut != null;
      // print("isMadeSlide --> $isMadeSlide");
      widget.onSlideOut?.call(slidDirection.left);
      // print('slide left');
    }
    if (velocityX > 1000 || positionX > outSizeLimitRight) {
      isMadeSlide = widget.onSlideOut != null;
      // print("isMadeSlide --> $isMadeSlide");
      widget.onSlideOut?.call(slidDirection.right);
      // print('slide right');
    }
    //  if (velocityY > 1000 || positionY > outSizeLimit) {
    //   // widget.onSlideOut?.call(slidDirection.down);
    //   print('slide down');
    // }
    //  if (velocityY < -1000 || positionY < outSizeLimit) {
    //   // widget.onSlideOut?.call(slidDirection.up);
    //   print('slide up');
    // }
    restoreController.forward();
  }

  void restoreAnimationListener() {
    if(restoreController.isCompleted) {
      restoreController.reset();
      panOffset = Offset.zero;
      isMadeSlide = false;
      angle = 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(key: _widgetKey, child: widget.child);
    if(!widget.isEnableDrag) return child;

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: AnimatedBuilder(
        animation: restoreController,
        builder: (context, _) {

          final value = 1 - restoreController.value;
          return Transform.translate(
              offset: panOffset * value,
              child: Transform.rotate(
                  angle: angle,
                  child: child));
        }
      ),
    );
  }
}

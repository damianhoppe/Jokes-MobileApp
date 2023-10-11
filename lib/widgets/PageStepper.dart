import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PageStepper extends StatefulWidget {
  final steps;
  final StepperController controller;
  Function()? onFinish;
  var animationDuration = Duration(milliseconds: 300);
  var animationCurve = Curves.easeInOut;


  PageStepper({required this.steps, super.key, required this.controller, this.onFinish});

  @override
  State<StatefulWidget> createState() => PageStepperState();
}

class PageStepperState extends State<PageStepper> {
  var currentStep = 0;
  final _pageController = PageController(
    initialPage: 0,
    viewportFraction: 1.0
  );

  @override
  void initState() {
    widget.controller.registerListeners(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: PageView.builder(
                controller: _pageController,
                itemCount: widget.steps.length,
                onPageChanged: (int index) => setState(() {
                  currentStep = index;
                }),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  return Center(
                    child: SingleChildScrollView(
                      child: widget.steps[i].widget,
                    ),
                  );
                }
            ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildStepProgressIndicator(),
          ),
        )
      ],
    );
  }

  _buildStepProgressIndicator() {
    var views = <Widget>[];
    if(widget.steps.length > 1) {
      for(var i = 0; i < widget.steps.length; i++) {
        if(i > 0) {
          views.add(Container(
            width: 30.0,
          ));
        }
        views.add(Container(
          width: 13.0,
          height: 13.0,
          decoration: BoxDecoration(
            color: i == currentStep? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onInverseSurface,
            shape: BoxShape.circle,
          ),
        ));
      }
    }
    return views;
  }

  nextStep() {
    if(currentStep+1 >= widget.steps.length) {
      widget.onFinish?.call();
      return;
    }
    widget.steps[currentStep].onNext?.call();
    setState(() {
      currentStep++;
    });
    _pageController.animateToPage(currentStep, duration: widget.animationDuration, curve: widget.animationCurve);
  }

  previousStep() {
    if(currentStep == 0) {
      return;
    }
    setState(() {
      currentStep--;
    });
    _pageController.animateToPage(currentStep, duration: widget.animationDuration, curve: widget.animationCurve);
  }

  getCurrentStep() {
    return widget.steps[currentStep];
  }
}

class StepPage {
  final Widget widget;
  Function()? onNext;

  StepPage({required this.widget, this.onNext});
}

class StepperController {
  Function()? onNextListener;
  Function()? onPreviousListener;

  registerListeners(listener) {
    registerOnNextListener(listener.nextStep);
    registerOnPreviousListener(listener.previousStep);
  }

  registerOnNextListener(onNextListener) {
    this.onNextListener = onNextListener;
  }

  registerOnPreviousListener(onPreviousListener) {
    this.onPreviousListener = onPreviousListener;
  }

  nextStep() {
    onNextListener?.call();
  }

  previousStep() {
    onPreviousListener?.call();
  }
}
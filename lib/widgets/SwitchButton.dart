import 'package:flutter/material.dart';

import '../utils/ValueHolder.dart';

class SwitchButton extends StatefulWidget {
  ValueHolder<bool> valueHolder;
  Function(bool value)? onChanged;

  SwitchButton({super.key, required this.valueHolder, this.onChanged});

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.valueHolder.value,
      activeColor: Theme.of(context).colorScheme.inversePrimary,
      onChanged: (bool currentValue) {
        setState(() {
          widget.valueHolder.value = currentValue;
        });
        widget.onChanged?.call(currentValue);
      },
    );
  }
}

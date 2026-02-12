import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CodeInputField extends StatelessWidget {
  final Function(String) onCompleted;
  final Function(String) onChanged;

  const CodeInputField({super.key, required this.onCompleted,required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      keyboardType: TextInputType.number,
      autoFocus: true,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 45,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
        activeColor: Colors.blue,
        selectedColor: Colors.blue,
        inactiveColor: Colors.grey,
      ),
      enableActiveFill: true,
      onCompleted: onCompleted,
      onChanged: onChanged,
    );
  }
}


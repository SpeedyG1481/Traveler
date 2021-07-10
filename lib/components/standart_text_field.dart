import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandartTextField extends StatelessWidget {
  final TextEditingController editingController;
  final String hintText;
  final Color color;
  final bool passwordText;
  final bool borderBool;
  final Widget suffix;
  final Widget prefix;
  final int maxLines;
  final int minLines;
  final int maxLength;
  final bool counter;
  final TextStyle textStyle;

  StandartTextField({
    this.editingController,
    this.color,
    this.hintText,
    this.passwordText = false,
    this.borderBool = true,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength = 32,
    this.counter = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: style(),
      controller: this.editingController,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[\'"/\\\\]')),
        LengthLimitingTextInputFormatter(
          this.maxLength,
        ),
      ],
      minLines: this.minLines,
      maxLines: this.maxLines,
      obscureText: this.passwordText,
      maxLength: this.counter ? this.maxLength : null,
      decoration: InputDecoration(
        border: border(),
        focusedErrorBorder: border(),
        focusedBorder: border(),
        errorBorder: border(),
        enabledBorder: border(),
        disabledBorder: border(),
        hintText: this.hintText,
        hintStyle: style(),
        labelStyle: style(),
        suffixIcon: this.suffix,
        prefix: this.prefix,
      ),
    );
  }

  style() {
    return this.textStyle != null
        ? this.textStyle
        : const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          );
  }

  border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        this.borderBool ? 10 : 0,
      ),
      borderSide: this.borderBool
          ? BorderSide(
              color: this.color,
              width: 1.25,
              style: BorderStyle.solid,
            )
          : BorderSide.none,
    );
  }
}

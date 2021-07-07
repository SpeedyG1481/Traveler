import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandartTextField extends StatefulWidget {
  final TextEditingController editingController;
  final String hintText;
  final Color color;
  final bool passwordText;
  final bool border;
  final Widget suffix;
  final Widget prefix;

  StandartTextField({
    this.editingController,
    this.color,
    this.hintText,
    this.passwordText = false,
    this.border = true,
    this.prefix,
    this.suffix,
  });

  @override
  _StandartTextFieldState createState() => _StandartTextFieldState();
}

class _StandartTextFieldState extends State<StandartTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: style(),
      controller: widget.editingController,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[\'"/\\\\]')),
        LengthLimitingTextInputFormatter(
          32,
        ),
      ],
      obscureText: widget.passwordText,
      decoration: InputDecoration(
        border: border(),
        focusedErrorBorder: border(),
        focusedBorder: border(),
        errorBorder: border(),
        enabledBorder: border(),
        disabledBorder: border(),
        hintText: this.widget.hintText,
        hintStyle: style(),
        labelStyle: style(),
        suffixIcon: widget.suffix,
        prefix: widget.prefix,
      ),
    );
  }

  border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        widget.border ? 10 : 0,
      ),
      borderSide: widget.border
          ? BorderSide(
              color: this.widget.color,
              width: 1.25,
              style: BorderStyle.solid,
            )
          : BorderSide.none,
    );
  }

  style() {
    return TextStyle(
      color: this.widget.color,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traveler/language/language.dart';

class SaveScoreTextField extends StatefulWidget {
  final TextEditingController editingController;

  SaveScoreTextField({this.editingController});

  @override
  _SaveScoreTextFieldState createState() => _SaveScoreTextFieldState();
}

class _SaveScoreTextFieldState extends State<SaveScoreTextField> {
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
      decoration: InputDecoration(
        border: border(),
        focusedErrorBorder: border(),
        focusedBorder: border(),
        errorBorder: border(),
        enabledBorder: border(),
        disabledBorder: border(),
        hintText: Language.typeName,
        hintStyle: style(),
        labelStyle: style(),
      ),
    );
  }

  border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        10,
      ),
      borderSide: BorderSide(
        color: Color(
          0xff00276B,
        ),
        width: 1.25,
        style: BorderStyle.solid,
      ),
    );
  }

  style() {
    return TextStyle(
      color: Color(
        0xff00276B,
      ),
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }
}

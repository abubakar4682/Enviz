import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Theme/theme.dart';
import '../Utils/colors.dart';

class FormTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextInputType? textInputType;
//  final String? Function(String)? validator; // Add the validator here
  final TextEditingController? controller;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const FormTextField({
    Key? key, // Fix the super.key here
    this.labelText,
    this.hintText,
    this.textInputType,
    this.validator,
    this.controller,
    this.maxLines,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key); // Initialize super(key: key) correctly

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}


class _FormTextFieldState extends State<FormTextField> {

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    print('Controller value: ${widget.controller?.text}');
    _focusNode = FocusNode();

    if (widget.readOnly) {
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      cursorColor: redColor,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      focusNode: _focusNode,
      keyboardType: widget.textInputType,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      style: inoTheme.labelStyle,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: greyColor)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: redColor)),
        // floatingLabelStyle: TextStyle(color: redColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: widget.labelText,
        labelStyle: inoTheme.labelStyle,
        hintText: widget.hintText,
        hintStyle: inoTheme.hintStyle,
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,

      ),
    );
  }
}
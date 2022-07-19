library otp_widget;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpWidget extends StatefulWidget {
  final int lenght;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool obscureText;
  final ValueChanged<String>? onChange;

  const OtpWidget({
    Key? key,
    required this.lenght,
    this.keyboardType,
    this.decoration,
    this.style,
    this.obscureText = false,
    this.onChange,
  }) : super(key: key);

  @override
  State<OtpWidget> createState() => OtpWidgetState();

  static TextStyle otpTextStyle = const TextStyle(fontWeight: FontWeight.bold);
  static InputDecoration otpInputDecoration = const InputDecoration(
    counterText: "",
    border: UnderlineInputBorder(
      borderSide: BorderSide(width: 10),
    ),
  );
}

class OtpWidgetState extends State<OtpWidget> {
  String get text => _controllers.map((e) => e.text).join();
  bool get isValid => text.length == widget.lenght;

  late final List<TextEditingController> _controllers =
      List.generate(widget.lenght, (i) => i)
          .map((e) => TextEditingController())
          .toList();

  late final List<FocusNode> _focusNodes =
      List.generate(widget.lenght, (i) => i)
          .mapIndexed(
            (i, e) => FocusNode(
              onKey: (node, event) => _onKey(i, node, event),
            ),
          )
          .toList();

  KeyEventResult _onKey(int i, FocusNode n, RawKeyEvent e) {
    if (e.isKeyPressed(LogicalKeyboardKey.backspace) &&
        _controllers[i].text.isEmpty) {
      _focusNodes[i - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  _onChange() {
    if (widget.onChange == null) return;
    widget.onChange?.call(text);
  }

  @override
  void initState() {
    if (widget.onChange == null) return;
    for (var element in _controllers) {
      element.addListener(_onChange);
    }
    super.initState();
  }

  @override
  void dispose() {
    _focusNodes.map((e) => e.dispose());
    for (var element in _controllers) {
      element.removeListener(_onChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _focusNodes
          .mapIndexed(
            (i, e) => buildDigits(context, e, i),
          )
          .toList(),
    );
  }

  Widget buildDigits(BuildContext context, FocusNode e, int i) {
    return Container(
      width: (MediaQuery.of(context).size.width / widget.lenght) - 16,
      margin: const EdgeInsets.only(right: 8),
      child: TextField(
        obscureText: widget.obscureText,
        focusNode: e,
        maxLength: 1,
        maxLines: 1,
        style: widget.style ?? OtpWidget.otpTextStyle,
        controller: _controllers[i],
        keyboardType: widget.keyboardType,
        onTap: () {
          _controllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[i].text.length,
            affinity: TextAffinity.upstream,
          );
        },
        onChanged: (v) {
          if (i + 1 == _focusNodes.length || v.isEmpty) return;
          _focusNodes[i + 1].requestFocus();
          _controllers[i + 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[i + 1].text.length,
            affinity: TextAffinity.upstream,
          );
        },
        textAlign: TextAlign.center,
        decoration: widget.decoration?.copyWith(counterText: "") ??
            OtpWidget.otpInputDecoration,
      ),
    );
  }
}

library numberselector;

import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberSelector extends StatefulWidget {
  /// Maximum selectable value
  final int? max;

  /// Minimum selectable value
  final int? min;

  /// Startindex of selector
  /// If not set, the selector will start at 0
  final int start;

  /// The amount every increment/decrement will be
  /// Default is 1
  final int step;

  /// Callback on number change
  final Function(int number)? onNumberChange;

  /// Selector height
  /// Default is 50.0 px
  final double height;

  /// Selector width
  /// Default to 324.0 px. Provide null to expand to parent width
  final double? width;

  /// Selector border radius
  /// Default is 2.0 px
  final double borderRadius;

  /// Selector border color
  /// Default is Colors.grey
  final Color borderColor;

  /// Selector background color
  /// Default is Colors.white
  final Color backgroundColor;

  /// Selector border width
  /// Default is 1.0 px
  final double borderWidth;

  /// Selector increment/decrement icon colors
  /// Default is Colors.black54
  final Color iconColor;

  /// The String displayed before the max number in the textField
  /// Default is 'of'
  final String perfixNaming;

  /// The spacing between the number and the buttons
  final double contentPadding;

  const NumberSelector({
    super.key,
    this.max,
    this.min,
    this.step = 1,
    this.onNumberChange,
    this.start = 0,
    this.height = 50.0,
    this.width = 324.0,
    this.contentPadding = 20.0,
    this.borderRadius = 2.0,
    this.borderColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.borderWidth = 1.0,
    this.iconColor = Colors.black54,
    this.perfixNaming = 'of',
  });

  @override
  State<NumberSelector> createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  final _focusNode = FocusNode();
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.start.toString());

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_controller.text != '') {
          _update(_controller.text);
        } else {
          _controller.text = '${widget.start}';
          _update(_controller.text);
        }
      }
    });

    _focusNode.onKeyEvent = (_, event) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _focusNode.unfocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.backgroundColor,
      ),
      child: Row(
        children: [
          if (widget.min != null) ...[
            _NaviagtionButton(
              height: widget.height,
              width: widget.height,
              enabled: _isDecementEnabled,
              icon: const Icon(Icons.first_page),
              iconColor: widget.iconColor,
              onPressed: () => _toMin(),
            ),
            _devider(),
          ],
          _NaviagtionButton(
            height: widget.height,
            width: widget.height,
            key: const Key('Decrement'),
            enabled: _isDecementEnabled,
            icon: const Icon(Icons.chevron_left),
            iconColor: widget.iconColor,
            onPressed: () => _decrement(),
          ),
          _devider(),
          Expanded(
            child: _numberField(),
          ),
          _devider(),
          _NaviagtionButton(
            height: widget.height,
            width: widget.height,
            key: const Key('Increment'),
            enabled: _isIncrementEnabled,
            icon: const Icon(Icons.chevron_right),
            iconColor: widget.iconColor,
            onPressed: () => _increment(),
          ),
          if (widget.max != null) ...[
            _devider(),
            _NaviagtionButton(
              height: widget.height,
              width: widget.height,
              enabled: _isIncrementEnabled,
              icon: const Icon(Icons.last_page),
              iconColor: widget.iconColor,
              onPressed: () => _toMax(),
            ),
          ],
        ],
      ),
    );
  }

  TextField _numberField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: '${widget.start}',
        suffixText:
            widget.max != null ? '${widget.perfixNaming} ${widget.max}' : null,
        contentPadding: EdgeInsets.all(widget.contentPadding),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
      ],
    );
  }

  VerticalDivider _devider() {
    return VerticalDivider(
      width: widget.borderWidth,
      thickness: widget.borderWidth,
      color: widget.borderColor,
    );
  }

  void _toMin() {
    setState(() {
      _controller.text = widget.min.toString();
      widget.onNumberChange?.call(int.parse(_controller.text));
    });
  }

  void _toMax() {
    setState(() {
      _controller.text = widget.max.toString();
      widget.onNumberChange?.call(int.parse(_controller.text));
    });
  }

  void _update(String value) {
    setState(() {
      final newValue = _toMinMaxValue(int.parse(value));
      _controller.text = '$newValue';
      widget.onNumberChange?.call(newValue);
    });
  }

  void _increment() {
    setState(() {
      final newValue =
          _toMinMaxValue(int.parse(_controller.text) + widget.step);
      _controller.text = '$newValue';
      widget.onNumberChange?.call(newValue);
    });
  }

  void _decrement() {
    setState(() {
      final newValue =
          _toMinMaxValue(int.parse(_controller.text) - widget.step);
      _controller.text = '$newValue';
      widget.onNumberChange?.call(newValue);
    });
  }

  bool get _isDecementEnabled =>
      (widget.min != null && _parcedText > widget.min!) || widget.min == null;

  bool get _isIncrementEnabled =>
      (widget.max != null && _parcedText < widget.max!) || widget.max == null;

  int get _parcedText =>
      _controller.text.isNotEmpty ? int.parse(_controller.text) : widget.start;

  int _toMinMaxValue(int number) {
    widget.min != null ? number = max(number, widget.min!) : number;
    widget.max != null ? number = min(number, widget.max!) : number;
    return number;
  }
}

class _NaviagtionButton extends StatelessWidget {
  final double height;
  final double width;
  final Icon icon;
  final void Function()? onPressed;
  final bool enabled;
  final Color iconColor;

  const _NaviagtionButton({
    super.key,
    required this.height,
    required this.width,
    required this.icon,
    required this.onPressed,
    required this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: icon,
          onPressed: enabled ? onPressed : null,
          color: iconColor,
          disabledColor: Colors.black26,
        ),
      ),
    );
  }
}

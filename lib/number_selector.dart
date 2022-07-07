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
  final int current;

  /// The amount every increment/decrement will be
  /// Default is 1
  final int step;

  /// Provide false to disable the entire selector
  final bool enabled;

  /// Callback on number change
  final Function(int number)? onUpdate;

  /// Selector height
  /// Default is 36.0 px
  final double height;

  /// Selector width
  /// Default to 324.0 px. Provide null to expand to parent width
  final double? width;

  /// Selector border radius
  /// Default is 2.0 px
  final double borderRadius;

  /// Selector border color
  /// Default is Colors.black26
  final Color borderColor;

  /// Devider color
  /// Default is Colors.black12
  final Color deviderColor;

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

  /// The spacing between vertical deviders and the main container
  /// Default is 5.0 px
  final double verticalDeviderPadding;

  const NumberSelector({
    super.key,
    this.max,
    this.min,
    this.step = 1,
    this.enabled = true,
    this.onUpdate,
    this.current = 0,
    this.height = 50.0,
    this.width = 350.0,
    this.contentPadding = 20.0,
    this.verticalDeviderPadding = 5.0,
    this.borderRadius = 2.0,
    this.borderColor = Colors.black26,
    this.deviderColor = Colors.black12,
    this.backgroundColor = Colors.white,
    this.borderWidth = 1.0,
    this.iconColor = Colors.black54,
    this.perfixNaming = 'of',
  });

  @override
  State<NumberSelector> createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  late int _current;
  bool _isCanceled = false;

  @override
  void initState() {
    _current = widget.current;
    _focusNode = FocusNode(canRequestFocus: widget.enabled);
    _controller = TextEditingController(text: widget.current.toString());

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.enabled) _update();
    });

    _focusNode.onKeyEvent = (_, event) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _isCanceled = true;
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
              onPressed: () => _minMax(true),
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
            onPressed: () => _icrementDecrement(false),
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
            onPressed: () => _icrementDecrement(true),
          ),
          if (widget.max != null) ...[
            _devider(),
            _NaviagtionButton(
              height: widget.height,
              width: widget.height,
              enabled: _isIncrementEnabled,
              icon: const Icon(Icons.last_page),
              iconColor: widget.iconColor,
              onPressed: () => _minMax(false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: '$_current',
        suffixText:
            widget.max != null ? '${widget.perfixNaming} ${widget.max}' : null,
        contentPadding: EdgeInsets.symmetric(horizontal: widget.contentPadding),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
      ],
      enabled: widget.enabled,
    );
  }

  Widget _devider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.verticalDeviderPadding),
      child: VerticalDivider(
        width: widget.borderWidth,
        thickness: widget.borderWidth,
        color: widget.deviderColor,
      ),
    );
  }

  void _minMax(bool isMin) {
    setState(() {
      _current = (isMin ? widget.min : widget.max) ?? widget.current;
      _controller.text = '$_current';
      widget.onUpdate?.call(_parcedText);
    });
  }

  void _update() {
    if (_isCanceled) {
      _isCanceled = false;
      _controller.text = '$_current';
      return;
    }
    if (_clamp(_parcedText) == _current) {
      _controller.text = '$_current';
      return;
    }
    setState(() {
      if (_controller.text.isEmpty) {
        _controller.text = '$_parcedText';
      } else {
        _current = _clamp(_parcedText);
        _controller.text = '$_current';
        widget.onUpdate?.call(_current);
      }
    });
  }

  void _icrementDecrement(bool isIncrement) {
    setState(() {
      _current =
          _clamp(_parcedText + (isIncrement ? widget.step : -widget.step));
      _controller.text = '$_current';
      widget.onUpdate?.call(_current);
    });
  }

  bool get _isDecementEnabled =>
      widget.enabled && (widget.min != null && _parcedText > widget.min!) ||
      widget.min == null;

  bool get _isIncrementEnabled =>
      widget.enabled && (widget.max != null && _parcedText < widget.max!) ||
      widget.max == null;

  int get _parcedText => int.tryParse(_controller.text) ?? _current;

  int _clamp(int number) {
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

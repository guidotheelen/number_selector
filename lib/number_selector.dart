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

  /// Default is 36.0 px
  final double height;

  /// Default to 324.0 px. Provide null to expand to parent width
  final double? width;

  /// Default is 2.0 px
  final double borderRadius;

  /// Default is Colors.black26
  final Color borderColor;

  /// Default is Colors.black12
  final Color dividerColor;

  /// Default is Colors.white
  final Color backgroundColor;

  /// Default is 1.0 px
  final double borderWidth;

  /// Shows or hides the outline of the selector
  final bool hasBorder;

  /// Default is Colors.black54
  final Color iconColor;

  /// Increment icon
  final IconData incrementIcon;

  /// Decrement icon
  final IconData decrementIcon;

  /// Maximal number icon
  final IconData maxIcon;

  /// Minimal number icon
  final IconData minIcon;

  /// Show min and max buttons if min and max are set
  /// Default is true
  final bool showMinMax;

  /// Show suffix if max is set
  /// Default is true
  final bool showSuffix;

  /// Center text in the textfield
  /// Default is false
  final bool hasCenteredText;

  /// Show or hide the lines between the buttons
  /// Default is true
  final bool hasDividers;

  /// The String displayed before the max number in the textField
  /// Default is 'of'
  final String prefixNaming;

  /// The spacing between the number and the buttons
  final double contentPadding;

  /// The spacing between vertical deviders and the main container
  /// Default is 5.0 px
  final double verticalDividerPadding;

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
    this.verticalDividerPadding = 5.0,
    this.borderRadius = 2.0,
    this.borderColor = Colors.black26,
    this.dividerColor = Colors.black12,
    this.backgroundColor = Colors.white,
    this.borderWidth = 1.0,
    this.iconColor = Colors.black54,
    this.incrementIcon = Icons.chevron_right,
    this.decrementIcon = Icons.chevron_left,
    this.maxIcon = Icons.last_page,
    this.minIcon = Icons.first_page,
    this.showMinMax = true,
    this.showSuffix = true,
    this.hasCenteredText = false,
    this.hasDividers = true,
    this.hasBorder = true,
    this.prefixNaming = 'of',
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
    _focusNode = FocusNode();
    _controller = TextEditingController(text: '${widget.current}');

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
        border: widget.hasBorder
            ? Border.all(
                color: widget.borderColor,
                width: widget.borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.backgroundColor,
      ),
      child: Row(
        children: [
          if (widget.min != null && widget.showMinMax) ...[
            _NaviagtionButton(
              key: const Key('Min'),
              height: widget.height,
              width: widget.height,
              enabled: _isDecementEnabled,
              icon: Icon(widget.minIcon),
              iconColor: widget.iconColor,
              onPressed: () => _minMax(true),
            ),
            _divider(),
          ],
          _NaviagtionButton(
            key: const Key('Decrement'),
            height: widget.height,
            width: widget.height,
            enabled: _isDecementEnabled,
            icon: Icon(widget.decrementIcon),
            iconColor: widget.iconColor,
            onPressed: () => _incrementDecrement(false),
          ),
          _divider(),
          Expanded(
            child: _numberField(),
          ),
          _divider(),
          _NaviagtionButton(
            key: const Key('Increment'),
            height: widget.height,
            width: widget.height,
            enabled: _isIncrementEnabled,
            icon: Icon(widget.incrementIcon),
            iconColor: widget.iconColor,
            onPressed: () => _incrementDecrement(true),
          ),
          if (widget.max != null && widget.showMinMax) ...[
            _divider(),
            _NaviagtionButton(
              key: const Key('Max'),
              height: widget.height,
              width: widget.height,
              enabled: _isIncrementEnabled,
              icon: Icon(widget.maxIcon),
              iconColor: widget.iconColor,
              onPressed: () => _minMax(false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberField() {
    var showSuffix = widget.max != null && widget.showSuffix;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: '$_current',
        suffixText: showSuffix ? '${widget.prefixNaming} ${widget.max}' : null,
        contentPadding: EdgeInsets.symmetric(horizontal: widget.contentPadding),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
      ),
      textAlign: widget.hasCenteredText ? TextAlign.center : TextAlign.start,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
      ],
      enabled: widget.enabled,
    );
  }

  Widget _divider() => widget.hasDividers
      ? Padding(
          padding:
              EdgeInsets.symmetric(vertical: widget.verticalDividerPadding),
          child: VerticalDivider(
            width: widget.borderWidth,
            thickness: widget.borderWidth,
            color: widget.dividerColor,
          ),
        )
      : const SizedBox();

  void _minMax(bool isMin) {
    setState(() {
      _current = (isMin ? widget.min : widget.max) ?? widget.current;
      _controller.text = '$_current';
      widget.onUpdate?.call(_parcedText);
    });
  }

  void _incrementDecrement(bool isIncrement) {
    setState(() {
      _current =
          _clamp(_parcedText + (isIncrement ? widget.step : -widget.step));
      _controller.text = '$_current';
      widget.onUpdate?.call(_current);
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
    if (_controller.text.isEmpty) {
      _controller.text = '$_parcedText';
    } else {
      _current = _clamp(_parcedText);
      _controller.text = '$_current';
      widget.onUpdate?.call(_current);
    }
  }

  bool get _isDecementEnabled =>
      widget.enabled && (widget.min != null && _parcedText > widget.min!) ||
      widget.min == null;

  bool get _isIncrementEnabled =>
      widget.enabled && (widget.max != null && _parcedText < widget.max!) ||
      widget.max == null;

  int get _parcedText => int.tryParse(_controller.text) ?? _current;

  int _clamp(int number) {
    if (widget.min != null) number = max(number, widget.min!);
    if (widget.max != null) number = min(number, widget.max!);
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

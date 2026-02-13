import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FractionInputWidget extends StatefulWidget {
  const FractionInputWidget({
    super.key,
    required this.onChanged,
    this.initialValue,
    this.hintText = 'Enter fraction (e.g., 5/5)',
    this.enabled = true,
  });

  final void Function(String) onChanged;
  final String? initialValue;
  final String hintText;
  final bool enabled;

  @override
  State<FractionInputWidget> createState() => _FractionInputWidgetState();
}

class _FractionInputWidgetState extends State<FractionInputWidget> {
  late TextEditingController _controller;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    _validateFraction(text);
    widget.onChanged(text);
  }

  void _validateFraction(String text) {
    setState(() {
      if (text.isEmpty) {
        _errorText = '';
        return;
      }

      // Check if it's a valid fraction format
      if (text.contains('/')) {
        final parts = text.split('/');
        if (parts.length != 2) {
          _errorText = 'Invalid fraction format';
          return;
        }

        final numeratorStr = parts[0].trim();
        final denominatorStr = parts[1].trim();

        if (numeratorStr.isEmpty || denominatorStr.isEmpty) {
          _errorText = 'Both numerator and denominator required';
          return;
        }

        final numerator = int.tryParse(numeratorStr);
        final denominator = int.tryParse(denominatorStr);

        if (numerator == null || denominator == null) {
          _errorText = 'Both parts must be numbers';
          return;
        }

        if (denominator == 0) {
          _errorText = 'Denominator cannot be zero';
          return;
        }
      } else {
        // Check if it's a valid whole number
        final number = int.tryParse(text);
        if (number == null) {
          _errorText = 'Enter a valid number or fraction';
          return;
        }
      }

      _errorText = '';
    });
  }

  String _formatFraction(String input) {
    if (!input.contains('/')) return input;

    final parts = input.split('/');
    if (parts.length != 2) return input;

    final numerator = int.tryParse(parts[0].trim());
    final denominator = int.tryParse(parts[1].trim());

    if (numerator == null || denominator == null) return input;

    // Simplify fraction
    final gcd = _greatestCommonDivisor(numerator.abs(), denominator.abs());
    final simplifiedNum = numerator ~/ gcd;
    final simplifiedDen = denominator ~/ gcd;

    if (simplifiedDen == 1) {
      return simplifiedNum.toString();
    }

    return '$simplifiedNum/$simplifiedDen';
  }

  int _greatestCommonDivisor(int a, int b) {
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _errorText.isNotEmpty
                  ? Colors.red
                  : Theme.of(context).primaryColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/\-]')),
                  ],
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Fraction helper buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final currentText = _controller.text;
                        if (!currentText.contains('/')) {
                          final cursorPos = _controller.selection.start;
                          final newText =
                              currentText.substring(0, cursorPos) +
                              '/' +
                              currentText.substring(cursorPos);
                          _controller.text = newText;
                          _controller.selection = TextSelection.collapsed(
                            offset: cursorPos + 1,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '/',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        // Show simplified fraction
        if (_controller.text.isNotEmpty &&
            _errorText.isEmpty &&
            _controller.text.contains('/'))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Simplified: ${_formatFraction(_controller.text)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

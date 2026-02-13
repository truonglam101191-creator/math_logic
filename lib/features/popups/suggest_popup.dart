import 'package:flutter/material.dart';
import 'package:logic_mathematics/cores/configs/configs.dart';

class SuggestPopup extends StatefulWidget {
  const SuggestPopup({
    super.key,
    required this.paddingBottom,
    required this.result,
  });

  final double paddingBottom;

  final String result;

  @override
  State<SuggestPopup> createState() => _SuggestPopupState();
}

class _SuggestPopupState extends State<SuggestPopup> {
  double _sizeContentText = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sizeContentText = getSizeContentText();
      });
    });
  }

  double getSizeContentText() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.result,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 20);
    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: widget.paddingBottom, right: 20),
          child: SizedBox(
            width: _sizeContentText + 20,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(
                  Configs.instance.commonRadius,
                ),
              ),
              child: Text(
                widget.result,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

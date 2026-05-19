import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ClickableTextWidget extends StatelessWidget {
  final String text, clickableText;
  final VoidCallback? onTap;
  final TextAlign? textAlign;
  final TextStyle? textStyle, clickableTextStyle;
  final int? maxLines;
  final TextOverflow? textOverflow;

  const ClickableTextWidget({
    super.key,
    required this.text,
    required this.clickableText,
    this.onTap,
    this.textAlign,
    this.textStyle,
    this.clickableTextStyle,
    this.maxLines,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: RichText(
        maxLines: maxLines,
        overflow: textOverflow ?? TextOverflow.visible,
        textAlign: textAlign ?? TextAlign.center,
        text: TextSpan(
          style: textStyle ?? Theme.of(context).textTheme.labelSmall,
          children: [
            TextSpan(text: text),
            TextSpan(
              text: clickableText,
              style:
                  (clickableTextStyle ??
                          Theme.of(context).textTheme.labelSmall)!
                      .copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        decorationThickness: 1.5,
                      ),
              recognizer: (onTap == null)
                  ? null
                  : (TapGestureRecognizer()..onTap = onTap),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;

  const LoadingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SpinKitThreeBounce(
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              )
            : Text(text),
      ),
    );
  }
} 
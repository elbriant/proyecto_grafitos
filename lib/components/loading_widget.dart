import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: const Color.fromARGB(48, 0, 0, 0)),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

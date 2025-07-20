import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String? companyName;
  final String? plantName;
  final String? valueStreamName;
  final Widget body;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.companyName,
    this.plantName,
    this.valueStreamName,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.yellow[100],
      body: Column(
        children: [
          // Removed HomeHeader
          Expanded(child: body),
        ],
      ),
    );
  }
}

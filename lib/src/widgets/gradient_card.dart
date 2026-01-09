import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.onTap,
  });

  final Widget child;
  final Gradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ),
    );
  }
}


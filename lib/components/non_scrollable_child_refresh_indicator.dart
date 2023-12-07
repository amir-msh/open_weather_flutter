import 'package:flutter/material.dart';

class NonScrollableChildRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future Function() onRefresh;
  final Key? refreshIndicatorKey;
  const NonScrollableChildRefreshIndicator({
    super.key,
    this.refreshIndicatorKey,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          key: refreshIndicatorKey,
          edgeOffset: 0,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox.fromSize(
              size: constraints.biggest,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_scaffold.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Material(
        child: GlassScaffold(topEdgeFade: false, body: ListView()),
      ),
    );
  }
}

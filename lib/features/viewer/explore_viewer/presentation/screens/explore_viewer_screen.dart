import 'package:flutter/material.dart';

import '../widget/explore_body_widget.dart';

class ExploreViewerScreen extends StatelessWidget {
  const ExploreViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExploreBodyWidget(),
    );
  }
}
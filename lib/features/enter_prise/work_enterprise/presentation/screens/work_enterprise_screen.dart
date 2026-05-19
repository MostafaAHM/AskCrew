import 'package:flutter/material.dart';

import '../widgets/work_enterprise_body_widget.dart';

class WorkEnterpriseScreen extends StatelessWidget {
  final int initialTabIndex;
  const WorkEnterpriseScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorkEnterpriseBodyWidget(initialTabIndex: initialTabIndex),
    );
  }
}

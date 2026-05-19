import 'package:flutter/material.dart';

import '../widget/profile_viewer_body_widget.dart';

class ProfileViewerScreen extends StatelessWidget {
  const ProfileViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileViewerBodyWidget(),
    );
  }
}
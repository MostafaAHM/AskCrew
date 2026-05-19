import 'package:flutter/material.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../widgets/profile_student_body_widget.dart';

class ProfileStudentScreen extends StatelessWidget {
  const ProfileStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
      ),
      body: ProfileStudentBodyWidget(),
    );
  }
}

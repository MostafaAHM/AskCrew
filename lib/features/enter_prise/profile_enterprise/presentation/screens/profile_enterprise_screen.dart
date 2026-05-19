import 'package:flutter/material.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../widgets/profile_enterprise_body_widget.dart';

class ProfileEnterpriseScreen extends StatelessWidget {
  const ProfileEnterpriseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
      ),
      body: const ProfileEnterpriseBodyWidget(),
    );
  }
}

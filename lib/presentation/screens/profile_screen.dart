import 'package:appointment_app/infrastructure/shared_preferences.dart';
import 'package:appointment_app/presentation/widgets/profile/profile_supplier.dart';
import 'package:appointment_app/presentation/widgets/profile/profile_view.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool getLogin() {
    return  Preferences.prefsLogin.getString('login') == 'Google' || Preferences.prefsLogin.getString('login') == 'Github';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: getLogin() ? ProfileSupplier() : ProfileView(),
    );
  }
}
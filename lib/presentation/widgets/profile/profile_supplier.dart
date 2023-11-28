import 'package:appointment_app/presentation/widgets/custom/style_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSupplier extends StatelessWidget {
  ProfileSupplier({super.key});
  final User? user = FirebaseAuth.instance.currentUser;

  String formatPhoneNumber(int phoneNumber) {
    String phoneNumberString = phoneNumber.toString();
    String formattedPhoneNumber =
        "${phoneNumberString.substring(0, 3)}-${phoneNumberString.substring(3, 6)}-${phoneNumberString.substring(6)}";
    return formattedPhoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ContainerImage(
            imageUrl: user!.photoURL!
          ),
          const SizedBox( height: 24 ),
          Text(
            user!.displayName!,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox( height: 12 ),
          RowProfile(
            text: user!.email!,
            icon: FontAwesomeIcons.envelope
          ),
        ],              
      )
    );
  }
}

class RowProfile extends StatelessWidget {
  const RowProfile({
    super.key,
    required this.text,
    required this.icon
  });
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox( width: 15),
        Text(
          text,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
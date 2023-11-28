import 'package:appointment_app/config/helpers/shared/services_firebase.dart';
import 'package:appointment_app/config/helpers/login/auth_google.dart';
import 'package:appointment_app/infrastructure/shared_preferences.dart';
import 'package:appointment_app/presentation/providers/provider_theme.dart';
import 'package:appointment_app/presentation/widgets/business/business_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CreateDrawer extends StatefulWidget {
  const CreateDrawer({super.key});

  @override
  State<CreateDrawer> createState() => _CreateDrawerState();
}

class _CreateDrawerState extends State<CreateDrawer> {
  ServicesFirebase servicesFirebase = ServicesFirebase( collection: 'profile' );
  ServicesFirebase checkBusiness = ServicesFirebase( collection: 'business' );
  AuServiceG auServiceG = AuServiceG();
  final User? user = FirebaseAuth.instance.currentUser;
  bool getLogin() {
    return  Preferences.prefsLogin.getString('login') == 'Google' || Preferences.prefsLogin.getString('login') == 'Github';
  }

  @override
  Widget build(BuildContext context) {
    final changeTheme = context.watch<ProviderTheme>();
    final changeFont = context.watch<ProviderFont>();
    return Drawer(
      child: ListView(
        children: [
          FutureBuilder(
            future: servicesFirebase.getOneRecordProfile( ServicesFirebase.uid ),
            builder: (context, snapshot) {
              if (snapshot.hasData || getLogin()) {
                return UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      getLogin() ? user!.photoURL! : snapshot.data!.image!,
                      errorListener: (error) => const Icon(Icons.error),
                    )
                  ),
                  accountName: Text( getLogin() ? user!.displayName! : snapshot.data!.name!),
                  accountEmail: Text( getLogin() ? user!.email! : snapshot.data!.surnames!)
                );  
              }
              return const Text('Loading Data...');
            }
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.addressCard),
            trailing: const Icon(Icons.chevron_right),
            title: getLogin() ? const Text('View Profile') : const Text('Edit Profile'),
            subtitle: const Text('User Data'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),          
          ListTile(
            leading: const Icon(FontAwesomeIcons.businessTime),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('Edit Business'),
            subtitle: const Text('Merchants Data'),
            onTap: () async {
              if ( await checkBusiness.getOneRecordBusiness(ServicesFirebase.uid) == null ) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessForm()));
              } else {
                Navigator.pushNamed(context, '/business');
              }
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.rectangleList),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('See Services'),
            subtitle: const Text('Add new'),
            onTap: () {
              Navigator.pushNamed(context, '/services');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.newspaper),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('Interesting topics'),
            subtitle: const Text('Subscribe'),
            onTap: () {
              Navigator.pushNamed(context, '/subs');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.palette),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('App Theme'),
            subtitle: const Text('Change Color'),
            onTap: () {
              Navigator.pushNamed(context, '/theme');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.handshake),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('On Boarding'),
            subtitle: const Text('Know more about us'),
            onTap: () {
              Navigator.pushNamed(context, '/ob');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.rightFromBracket),
            trailing: const Icon(Icons.chevron_right),
            title: const Text('Logout'),
            subtitle: const Text('Sign off'),
            onTap: () async {
              Preferences.prefsSession.setBool('session', false);
              Preferences.prefsLogin.setString('login', '');
              changeTheme.colorValue = 2;
              changeFont.fontValue = 'Lato';
              Preferences.prefsThemeColor.clear();
              Preferences.prefsThemeFont.clear();
              servicesFirebase.userSignOut();
              auServiceG.signOutWithGoogle();
              Navigator.pushNamedAndRemoveUntil( // ! Remover en caso de error.
                context, '/login', (Route<dynamic> route) => false,
              );
              // Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
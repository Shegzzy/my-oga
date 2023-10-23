import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/views/User_Dashboard/user_dashboard.dart';
import '../../services/views/splash_screen/splash_screen.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          /// is the user logged in
          if(snapshot.hasData){
            return const UserDashboard();
          }
          /// is the user not logged in
          else{
            return SplashScreen();
          }
        },
      ),
    );
  }
}

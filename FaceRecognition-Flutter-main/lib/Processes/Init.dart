import 'dart:io';
import 'package:facerecognition_flutter/UI/Dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Init {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final facesdkPlugin = FacesdkPlugin();

  Future<void> initShowDialog(context, state) async {
    if (await connectivityResult()) {
      init(context, state);
    } else {
      Dialogs().showDialogFun(context, state, 'connect to internet');
    }
  }

  Future<void> init(context, state) async {
    //currentPersonList = await loadAllPersons();
    int facepluginState = -1;
    try {
      if (Platform.isAndroid) {
        await facesdkPlugin
            .setActivation(
                "CFO+UUpNLaDMlmdjoDlhBMbgCwT27CzQJ4xHpqe9rDOErwoEUeCGPRTfQkZEAFAFdO0+rTNRIwnQwpqqGxBbfnLkfyFeViVS5bpWZFk15QXP3ZtTEuU1rK5zsFwcZrqRUxsG9dXImc+Vw5Ddc9zBp9GEUuDycHLqC9KgQGVb0TS2u9Kz67HQOSDw9hskjBpjRbqiG+F/h5DBLPzjgFh1Y6vzgg6I59FzTOcdrdEbX7kI15Nwgf1hvHGtSgON/a0Fmw+XNdnxH2pVY96mcTemHYZAtxh8lA/t1DtTyZXpHjW8N6nq4UN2YDlKLXSrDzLpLHJmBsdpH71AXb7dfAq94Q==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await facesdkPlugin
            .setActivation(
                "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
                "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
                "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
                "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
                "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
            .then((value) => facepluginState = value ?? -1);
      }
      if (facepluginState == 0) {
        await facesdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final prefs = await SharedPreferences.getInstance();
    int? livenessLevel = prefs.getInt("liveness_level");

    try {
      await facesdkPlugin
          .setParam({'check_liveness_level': livenessLevel ?? 0});
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!state.mounted) return;
  }

  // Future signOutWithGoogle(context) async {
  //   try {
  //     // Sign out from Firebase Authentication
  //     await _auth.signOut();
  //
  //     // Additionally sign out from Google account
  //     await _googleSignIn.signOut();
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('personId', '');
  //     await prefs.setString('personStatus', '');
  //     GoRouter.of(context).go('/');
  //
  //     // Optional: Clear locally cached user data
  //     // ...
  //     // Navigate to the login screen or display success message
  //     print('Successfully signed out');
  //   } catch (error) {
  //     print("Error signing out: $error");
  //     // Handle signout errors appropriately
  //   }
  // }

  // Future signInWithGoogle(context, state) async {
  //   Progress().progress(context);
    // );
    // _auth.userChanges().listen((User? user) async {
    //   if (user == null) {
    //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    //
    //     // Obtain the auth details from the request
    //     final GoogleSignInAuthentication? googleAuth =
    //         await googleUser?.authentication;
    //
    //     // Create a new credential
    //     final credential = GoogleAuthProvider.credential(
    //       accessToken: googleAuth?.accessToken,
    //       idToken: googleAuth?.idToken,
    //     );
    //
    //     // Once signed in, return the UserCredential
    //     await _auth.signInWithCredential(credential);
    //     state.setState(() {
    //       signInWithGoogle(context, state);
    //     });
    //   } else {
    //     //signOutWithGoogle();
    //     user = _auth.currentUser;
    //     if (await Process().haveCV(context, user?.email)) {
    //       //print(_auth.currentUser?.displayName);
    //       await Process().enrollPerson(context, state, user?.displayName,
    //           user?.email, user?.phoneNumber, _facesdkPlugin);
    //       await Process().haveCV(context, user?.email);
    //       GoRouter.of(context).go('/ThePage');
    //     }
    //     GoRouter.of(context).go('/ThePage');
    //   }
    // });
  // }

  Future<bool> connectivityResult() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}

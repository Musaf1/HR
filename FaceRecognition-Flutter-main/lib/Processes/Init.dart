import 'dart:io';
import 'package:facerecognition_flutter/UI/Dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'Process.dart';

class Init {
  final facesdkPlugin = FacesdkPlugin();

  Future initShowDialog(context, state) async {
    if (await connectivityResult()) {
      if (await isServerOnline(context)) {
        try {
          if (await Process().buildingPosition()) {
            init(context, state);
            return true;
          } else {
            Dialogs().showDialogFun(context, state, 'Out of department range');
          }
        } catch (e) {}
      } else {
        Dialogs().showDialogFun(context, state, 'Connect to server');
      }
    } else {
      Dialogs().showDialogFun(context, state, 'Connect to internet');
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

  Future<bool> isServerOnline(context) async {
    try {
      final response = await http.get(Uri.parse(Process().baseUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
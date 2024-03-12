
import 'package:facerecognition_flutter/UI/Dialogs.dart';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../UI/facedetectionview.dart';
import 'process.dart';

class Init {
  final facesdkPlugin = FacesdkPlugin();

  Future initShowDialog(context, state) async {
    if (await connectivityResult()) {
      if (await isServerOnline(context)) {
        init(context, state);
        return true;
      } else {
        Dialogs().showDialogFun(context, state, 'Connect to server');
      }
    } else {
      Dialogs().showDialogFun(context, state, 'Connect to internet');
    }
  }

  Future buildShowDialog(context, state) async {
    if (await Process().buildingPosition()) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FaceRecognitionView(
                  employedPageState: state,
                )),
      );
    } else {
      Dialogs().showDialogFun(context, state, 'Out of Building range');
    }
  }

  Future<void> init(context, state) async {
    //currentPersonList = await loadAllPersons();
    int facepluginState = -1;
    try {
      await facesdkPlugin
          .setActivation(
              "CFO+UUpNLaDMlmdjoDlhBMbgCwT27CzQJ4xHpqe9rDOErwoEUeCGPRTfQkZEAFAFdO0+rTNRIwnQwpqqGxBbfnLkfyFeViVS5bpWZFk15QXP3ZtTEuU1rK5zsFwcZrqRUxsG9dXImc+Vw5Ddc9zBp9GEUuDycHLqC9KgQGVb0TS2u9Kz67HQOSDw9hskjBpjRbqiG+F/h5DBLPzjgFh1Y6vzgg6I59FzTOcdrdEbX7kI15Nwgf1hvHGtSgON/a0Fmw+XNdnxH2pVY96mcTemHYZAtxh8lA/t1DtTyZXpHjW8N6nq4UN2YDlKLXSrDzLpLHJmBsdpH71AXb7dfAq94Q==")
          .then((value) => facepluginState = value ?? -1);
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

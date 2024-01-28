import 'package:flutter/material.dart';

import '../Processes/Init.dart';
import '../Processes/Process.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  @override
  void initState() {
    super.initState();
    Init().initShowDialog(context, this);
  }

  @override
  Widget build(BuildContext context) {
    //initShowDialog();
    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Visibility(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                      label: const Text(
                        'Edit phone number',
                        // style: textStyle
                      ),
                      icon: const Icon(
                        //  color: textColor,
                        Icons.local_phone_outlined,
                        // color: Colors.white70,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          // foregroundColor: Colors.white70,
                          //  backgroundColor: color,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () {
                        Init().initShowDialog(context, this);
                        Process().changePhoneNumber(context);
                      }),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                      label: const Text(
                        'Sign out',
                        // style: textStyle
                      ),
                      icon: const Icon(
                        //  color: textColor,
                        Icons.logout_outlined,
                        // color: Colors.white70,
                      ),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          // foregroundColor: Colors.white70,
                          //  backgroundColor: color,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          )),
                      onPressed: () async {
                        Init().initShowDialog(context, this);
                        await Process().signOutUser(context);
                      }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

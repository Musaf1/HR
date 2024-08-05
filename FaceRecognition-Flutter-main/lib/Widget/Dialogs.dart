// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Control/init.dart';
import '../Control/process.dart';

class Dialogs {
  final _formKey = GlobalKey<FormState>();
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  //confirm departure dialog
  Future<void> confirmDeparture(context, state) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: PopScope(
              canPop: false,
              child: SingleChildScrollView(
                child: AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: const Text('Confirm Departure'),
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              )),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await Process().timeRecord();
                                state.setState(() {});
                              },
                              label: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                  )),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              label: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              )),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                String d =
                                    await showDialogTaskField(context, state);
                                await Process().addTaskLeave(d);
                                state.setState(() {});
                              },
                              label: const Text('Task Leave'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  //change mac address dialog
  Future changeMac(theContext, text, {bool b = true, linId}) async {
    await showDialog(
        context: theContext,
        builder: (context) {
          return Center(
            child: PopScope(
              canPop: false,
              child: SingleChildScrollView(
                child: AlertDialog(
                  //  backgroundColor: color,
                  elevation: 24,
                  title: const Text('Confirm Change Device'),
                  content: Column(
                    children: [
                      Text(text, style: const TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: b,
                            child: Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                )),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await Process().updateMac(linId, theContext);
                                },
                                label: const Text('Confirm'),
                              ),
                            ),
                          ),
                          Visibility(
                              visible: b,
                              child: const SizedBox(
                                width: 10,
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                  )),
                              onPressed: () async {
                                await Process().signOutUser(context);
                                Navigator.of(context).pop();
                              },
                              label: const Text('Cancel'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  //show dialog text
  void showDialogFun(context, state, text) {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        child: AlertDialog(
          elevation: 24,
          title: Text(
            text,
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                )),
                onPressed: () async {
                  Navigator.pop(context, 'OK');
                  if (await Init().initShowDialog(context, state)) {
                    await Init().buildShowDialog(context, state);
                  }
                },
                label: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // task field dialog
  Future<String> showDialogTaskField(context, state) async {
    String description = '';
    await showDialog(
        context: context,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: SingleChildScrollView(
              child: AlertDialog(
                elevation: 24,
                title: const Text(
                  'Task Leave',
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Reason';
                          }
                          return null;
                        },
                        maxLines: 5,
                        minLines: 1,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        controller: TextEditingController(text: description),
                        onChanged: (value) {
                          description = value;
                        },
                        decoration: const InputDecoration(
                            labelText: "Reason",
                            focusedBorder: UnderlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              )),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.of(context).pop();
                                  await Process().timeRecord(task: true);
                                  state.setState(() {});
                                }
                              },
                              label: const Text('OK'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                  )),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              label: const Text('Cancel'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    return description;
  }
}

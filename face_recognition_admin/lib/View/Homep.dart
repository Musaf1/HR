
import 'package:face_recognition_admin/Prosses/Prosses.dart';
import 'package:flutter/material.dart';
import '../person.dart';
import 'Dialogs/Dialogs.dart';

class EmployeesView extends StatefulWidget {
  const EmployeesView({super.key});

  @override
  State<EmployeesView> createState() => EmployeesViewState();
}

class EmployeesViewState extends State<EmployeesView> {
  List<Person> currentPersonList = <Person>[];
  static const color3 = Color.fromRGBO(0, 150, 150, 1);

  @override
  void initState() {
    super.initState();
    initShowDialog('select * from person');
  }

  Future<void> initShowDialog(text) async {
    if (await Prosses().connectivityResult()) {
      if (await Prosses().sqlConnection()) {
        init(text);
      } else {
        Dialogs().showDialogFun('server offline', 0, context);
      }
    } else {
      Dialogs().showDialogFun('connect to internet', 1, context);
    }
  }

  Future<void> init(text) async {
    currentPersonList = await Prosses().loadAllPersons(text);
    setState(() {
      currentPersonList = currentPersonList;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
          itemCount: currentPersonList.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                height: 75,
                child: Card(
                    child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28.0),
                      child: Image.memory(
                        currentPersonList[index].faceJpg,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Text("id: ${currentPersonList[index].id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: color3,
                          //       color: Color.fromRGBO(197, 225, 165, 1),
                        )),
                    const Spacer(),
                    IconButton(
                      color: Colors.cyanAccent[100],
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => Prosses().infoPerson(index, currentPersonList, context),
                    ),
                    // IconButton(
                    //   color: Colors.teal[700],
                    //   icon: const Icon(Icons.edit_outlined),
                    //   onPressed: () => Prosses().editPerson(index, currentPersonList, context, this),
                    // ),
                    IconButton(
                      color: Colors.red[300],
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => Prosses().deletePerson(
                          index, 'delete from person  where id=?', currentPersonList, context, this,
                          text2: 'delete from attendance  where id=?'),
                    ),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                )));
          }),
    );
  }
}

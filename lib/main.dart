import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_puzzles/first.dart';
import 'package:photo_puzzles/home.dart';
import 'package:photo_puzzles/splite_image.dart';

void main() {
  runApp(MaterialApp(
    home: first(),
    debugShowCheckedModeBanner: false,
  ));
}

class demo extends StatefulWidget {
  const demo({super.key});

  @override
  State<demo> createState() => _demoState();
}

class _demoState extends State<demo> {
  List list = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  List list1 = [];
  List temp = List.filled(9, true);

  // String a = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list1.addAll(list);
    list.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Photo Puzzles")),
      body: GridView.builder(
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemBuilder: (context, index) {
          return (temp[index])
              ? Draggable(
                  onDraggableCanceled: (velocity, offset) {
                    print("test");
                    temp = List.filled(9, true);
                    setState(() {});
                  },
                  data: index,
                  onDragStarted: () {
                    temp = List.filled(9, false);
                    temp[index] = true;
                    setState(() {});
                  },
                  child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Text(
                        "${list[index]}",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                  feedback: Container(
                      height: 100,
                      width: 100,
                      color: Colors.red.shade300,
                      alignment: Alignment.center,
                      child: Text(
                        "${list[index]}",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                )
              : DragTarget(
                  onAccept: (data) {
                    print(data);
                    temp = List.filled(9, true);
                    var c = list[data as int];
                    list[data as int] = list[index];
                    list[index] = c;
                    if (listEquals(list, list1)) {
                      print("you are win!");
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Center(
                            child: AlertDialog(
                              title: Text("you are winnn"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("OK"))
                              ],
                            ),
                          );
                        },
                      );
                    }
                    setState(() {});
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.lightBlue,
                      child: Text("${list[index]}",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    );
                  },
                );
        },
      ),
    );
  }
}

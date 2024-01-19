import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List<img.Image> mylist = [];
  List<img.Image> mylist1 = [];
  List temp = List.filled(9, true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImageFileFromAssets("asset/hmzadafiya.jpg").then(
      (value) {
        final image = img.decodeJpg(value.readAsBytesSync());
        mylist = splitImage(image!, 3, 3);
        mylist1.addAll(mylist);
        mylist.shuffle();
      },
    );
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  List<img.Image> splitImage(
      img.Image inputImage, int horizontalPieceCount, int verticalPieceCount) {
    img.Image image = inputImage;

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<img.Image>.empty(growable: true);

    var x = 0, y = 0;
    for (int i = 0; i < horizontalPieceCount; i++) {
      for (int j = 0; j < verticalPieceCount; j++) {
        pieceList.add(img.copyCrop(image,
            x: x, y: y, width: pieceWidth, height: pieceHeight));
        x += pieceWidth;
      }
      x = 0;
      y += pieceHeight;
    }

    return pieceList;
  }

  @override
  Widget build(BuildContext context) {
    double tot_width = MediaQuery.of(context).size.width;
    double con_wid = (tot_width - 20) / 3;
    print(tot_width);
    print(con_wid);
    return Scaffold(
      appBar: AppBar(title: Text("Photo puzzle")),
      body: GridView.builder(
        itemCount: mylist.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          Uint8List testing = img.encodeJpg(mylist[index]);
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
                    height: con_wid,
                    width: con_wid,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: MemoryImage(testing), fit: BoxFit.fill),
                    ),
                  ),
                  feedback: Container(
                    height: con_wid,
                    width: con_wid,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: MemoryImage(testing), fit: BoxFit.fill),
                    ),
                  ),
                )
              : DragTarget(
                  onAccept: (data) {
                    print(data);
                    temp = List.filled(9, true);
                    var c = mylist[data as int];
                    mylist[data as int] = mylist[index];
                    mylist[index] = c;
                    if (listEquals(mylist, mylist1)) {
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
                      height: con_wid,
                      width: con_wid,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(testing), fit: BoxFit.fill),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

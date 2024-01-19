import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgpic;
import 'package:permission_handler/permission_handler.dart';

class splite extends StatefulWidget {
  const splite({super.key});

  @override
  State<splite> createState() => _spliteState();
}

class _spliteState extends State<splite> {
  List img = [];
  List img1 = [];
  List img2 = [];

  List temp = List.filled(9, true);

  bool temp1 = false;

  @override
  void initState() {
    get();
  }

  get() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();
    }
    getImageFileFromAssets("asset/hmzadafiya.jpg").then(
      (value) {
        imgpic.Image? myimage = imgpic.decodeJpg(value.readAsBytesSync());
        img = splitImage(myimage!, 3, 3);

        for (int i = 0; i < img.length; i++) {
          img1.add(Image.memory(imgpic.encodeJpg(img[i])));

          temp[i] = true;
        }
        temp1 = true;
        img2.addAll(img1);
        img1.shuffle();
        setState(() {});
      },
    );
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    var dir_path = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS) +
        "/pic";
    print(path);
    Directory dir = Directory(dir_path);

    if (!await dir.exists()) {
      dir.create();
    }

    final file = File('${dir.path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  List<imgpic.Image> splitImage(imgpic.Image inputImage,
      int horizontalPieceCount, int verticalPieceCount) {
    imgpic.Image image = inputImage;

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<imgpic.Image>.empty(growable: true);
    var x = 0, y = 0;
    for (int i = 0; i < horizontalPieceCount; i++) {
      for (int j = 0; j < verticalPieceCount; j++) {
        pieceList.add(imgpic.copyCrop(image,
            x: x, y: y, width: pieceWidth, height: pieceHeight));
        x = x + pieceWidth;
      }
      x = 0;
      y = y + pieceHeight;
    }

    return pieceList;
  }

  @override
  Widget build(BuildContext context) {
    double tot_width = MediaQuery.of(context).size.width;
    double con_wid = (tot_width - 20) / 3;

    return Scaffold(
      appBar: AppBar(title: Text("Photo puzzle")),
      body: (temp1)
          ? GridView.builder(
              itemCount: img.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return (temp[index])
                    ? Draggable(
                        onDraggableCanceled: (velocity, offset) {
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
                            child: img1[index], height: 100, width: 100),
                        feedback: Container(
                          child: img1[index],
                          height: 100,
                          width: 100,
                        ),
                      )
                    : DragTarget(
                        onAccept: (data) {
                          temp = List.filled(9, true);
                          var d_acc = img1[data as int];
                          img1[data as int] = img1[index];
                          img1[index] = d_acc;
                          print("img2=$img2");
                          print("img1=$img1");
                          if (listEquals(img1, img2)) {
                            print("you are win!");
                            showDialog(barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: AlertDialog(scrollable: true,
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
                              child: img1[index], height: 100, width: 100);
                        },
                      );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),

    );
  }
}

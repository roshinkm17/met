import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:met/utilities/document_card.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';
import 'package:status_alert/status_alert.dart';

import 'qr_display_screen.dart';

class TestingScreen extends StatefulWidget {
  static String id = "upload_screen_id";
  @override
  _TestingScreenState createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  String _uploadedFileURL;
  FirebaseUser currentUser;
  String currentUserEmail;
  void getCurrentUser() async {
    currentUser = await _auth.currentUser();
    setState(() {
      currentUserEmail = currentUser.email;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  File file;
  bool _isSaving = false;
  int selectedIndex = 0;
  bool fileSelected = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'upload_screen',
      child: Center(
        child: Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: _isSaving,
            progressIndicator: CircularProgressIndicator(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 20,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.black87,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                "John Doe",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, QrDisplay.id);
                            },
                            child: Icon(FontAwesomeIcons.qrcode))
                      ],
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Hi, John \nComplete you profile..",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 20),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      HomeScreenIconCard(
//                          FontAwesomeIcons.fileAlt, "Upload Docs"),
//                      HomeScreenIconCard(
//                          FontAwesomeIcons.addressBook,
//                          "Allow "
//                          "contacts"),
//                      HomeScreenIconCard(
//                          FontAwesomeIcons.qrcode,
//                          "Setup QR "
//                          "Code"),
//                    ],
//                  ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.filePdf,
                            color: Colors.white,
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Upload your Doc",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Visibility(
                                  visible: !fileSelected,
                                  child: Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: fileSelected == false
                                            ? Colors.white
                                            : Colors.green,
                                      ),
                                      child: RawMaterialButton(
                                        splashColor: Colors.transparent,
                                        onPressed: () async {
                                          file = await FilePicker.getFile();
                                          setState(() {
                                            fileSelected = true;
                                          });
                                        },
                                        child: Icon(
                                          fileSelected == false
                                              ? Icons.add
                                              : Icons.check,
                                          size: 16,
                                          color: fileSelected == false
                                              ? Colors.orangeAccent.shade700
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: fileSelected,
                                  child: Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: RawMaterialButton(
                                          splashColor: Colors.transparent,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(0),
                                          onPressed: () async {
                                            setState(() {
                                              _isSaving = true;
                                            });
                                            try {
                                              StorageReference
                                                  storageReference =
                                                  FirebaseStorage().ref().child(
                                                      "$currentUserEmail/${basename(file.path)}");
                                              StorageUploadTask uploadTask =
                                                  storageReference
                                                      .putFile(file);
                                              await uploadTask.onComplete;
                                              StatusAlert.show(
                                                context,
                                                duration: Duration(seconds: 2),
                                                title:
                                                    "File Uploaded Successfully",
                                                configuration:
                                                    IconConfiguration(
                                                  icon: Icons.check,
                                                ),
                                              );
                                              storageReference
                                                  .getDownloadURL()
                                                  .then((fileURL) {
                                                setState(() {
                                                  _uploadedFileURL = fileURL;
                                                  print(_uploadedFileURL);
                                                  _isSaving = false;
                                                  fileSelected = false;
                                                });
                                              });
                                            } catch (e) {
                                              print(e);
                                              setState(() {
                                                _isSaving = false;
                                              });
                                            }
                                          },
                                          child: Icon(
                                            FontAwesomeIcons.arrowUp,
                                            size: 14,
                                            color: Colors.orangeAccent.shade700,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/user_info.dart' as user_info;
import '../components/side_menu.dart';
import '../theme/style.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 
  PlatformFile? uploadFile;
  TextEditingController nameController = TextEditingController();

  // 
  String name = '';

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // The following functions are used to generate the widget components for the edit profile page
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    // Alert dialog
    Future<dynamic> _generateAlertDialog(
        BuildContext context, String title, String content) {
      return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                backgroundColor: appThemeSecondary,
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                content: Text(content),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }

    // Sized boxes (White spaces)
    Widget _generateSizedBox() {
      return const SizedBox(
        height: 15,
      );
    }

    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // End of widget generation functions
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    return Scaffold(
        drawer: const SideMenu(),
        body: SafeArea(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(
            flex: 1,
            child: SideMenu(),
          ),
          Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(children: [
                  Stack(children: <Widget>[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => selectImage(),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: appThemeTertiary),
                          child: uploadFile == null
                              ? const Icon(
                                  Icons.photo,
                                  color: Colors.white,
                                )
                              : Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                      SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: Image.memory(
                                              Uint8List.fromList(
                                                  uploadFile!.bytes!.toList())),
                                        ),
                                      ),
                                      const Center(
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      )
                                    ]),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                      width: 250,
                      child: Form(
                        child: Column(
                          children: [
                            _generateSizedBox(),
                            TextFormField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(hintText: 'Name'),
                                onChanged: ((value) {
                                  name = value;
                                })),
                            _generateSizedBox(),
                            _generateSizedBox(),
                            ElevatedButton(
                                onPressed: () async {
                                  final updateSuccess =
                                      await user_info.UserInfo()
                                          .updateProfile(uploadFile, name);

                                  if (updateSuccess == false) {
                                    _generateAlertDialog(context, 'Not updated',
                                        'The name that was provided has already been taken!');
                                  } else {
                                    _generateAlertDialog(context, 'Updated',
                                        'Your profile has been successfully updated!');
                                    setState(() {
                                      uploadFile = null;
                                      nameController.clear();
                                    });
                                  }
                                },
                                child: const Text('Update profile'))
                          ],
                        ),
                      )),
                ]),
              ))
        ])));
  }

  selectImage() async {
    FilePickerResult? selectInput = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (selectInput != null) {
      setState(() {
        uploadFile = selectInput.files.first;
      });
    }
  }
}

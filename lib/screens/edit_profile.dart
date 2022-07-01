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
  // Initialize the controller and variables for the name/username and
  // the profile image
  PlatformFile? uploadFile;
  TextEditingController nameController = TextEditingController();
  String name = '';

  // Empty fields validation
  bool validateFields(String name, PlatformFile? uploadFile) {
    if (name.isEmpty && uploadFile == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
        drawer: const SideMenu(),
        body: SafeArea(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The side menu section (Drawer)
          const Expanded(
            flex: 1,
            child: SideMenu(),
          ),
          // The profile image input field
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
                  // The name/username input field
                  SizedBox(
                      width: 250,
                      child: Form(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(hintText: 'Name'),
                                onChanged: ((value) {
                                  name = value;
                                })),
                            const SizedBox(
                              height: 15,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // Edit/Update profile button
                            ElevatedButton(
                                onPressed: () async {
                                  if (validateFields(name, uploadFile) ==
                                      true) {
                                    final updateSuccess =
                                        await user_info.UserInfo()
                                            .updateProfile(uploadFile, name);

                                    if (updateSuccess == false) {
                                      _generateAlertDialog(
                                          context,
                                          'Update failed',
                                          'The name that was provided has already been taken!');
                                    } else {
                                      _generateAlertDialog(context, 'Updated',
                                          'Your profile has been successfully updated!');
                                      setState(() {
                                        uploadFile = null;
                                        name = '';
                                        nameController.clear();
                                      });
                                    }
                                  } else {
                                    _generateAlertDialog(
                                        context,
                                        'Empty fields',
                                        'Please ensure that at least one information is changed.');
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

  // Allow user to select/pick images (Limited to jpg, jpeg, and png)
  // from their system
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

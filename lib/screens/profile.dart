import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/theme/style.dart';
import '../components/email_field.dart';
import '../components/side_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PlatformFile? uploadFile;
  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.only(top: 16),
                child: Column(children: [
                  Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: <Widget>[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => uploadImage(),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: appThemeTertiary),
                              child: uploadFile == null
                                  ? const Icon(
                                      Icons.photo,
                                      color: Colors.white54,
                                    )
                                  : Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: <Widget>[
                                          Image.memory(Uint8List.fromList(
                                              uploadFile!.bytes!.toList())),
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
                          child: TextFormField(
                              decoration:
                                  const InputDecoration(hintText: 'Name'),
                              onChanged: ((value) {})))),
                  ElevatedButton(
                      onPressed: () {
                        updateProfile();
                      },
                      child: const Text('Upload image')),
                  Image.network(
                      'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif')
                ]),
              ))
        ])));
  }

  uploadImage() async {
    FilePickerResult? uploadInput = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (uploadInput != null) {
      setState(() {
        uploadFile = uploadInput.files.first;
      });
    }
  }

  updateProfile() async {
    if (uploadFile != null) {
      var fileBytes = uploadFile!.bytes;
      var fileExtension = uploadFile!.extension;
      final storageRef = FirebaseStorage.instance.ref(
          'uploads/${FirebaseAuth.instance.currentUser!.uid}/profile/profile_picture');
      TaskSnapshot uploadTaskSnapshot = await storageRef.putData(
          fileBytes!, SettableMetadata(contentType: 'image/$fileExtension'));

      final imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      debugPrint(imageUri);
    }
  }
}

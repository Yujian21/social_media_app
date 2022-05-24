import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Utilities {
  Future<String> uploadFile(PlatformFile? file, String path) async {
    var fileBytes = file!.bytes;
    var fileExtension = file.extension!.toLowerCase();
    final storageReference = FirebaseStorage.instance.ref(path);
    UploadTask uploadTask = storageReference.putData(
        fileBytes!, SettableMetadata(contentType: 'image/$fileExtension'));
        
    await uploadTask.whenComplete(() => null);
    String returnURL = '';
    await storageReference
        .getDownloadURL()
        .then((fileURL) => returnURL = fileURL);
    return returnURL;
  }

  Future<bool> doesNameAlreadyExist(String name) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }
}

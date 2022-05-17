import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Utilities {
  Future<String> uploadFile(PlatformFile? file, String path) async {
    var fileBytes = file!.bytes;
    var fileExtension = file.extension!.toLowerCase();
    final storageReference = FirebaseStorage.instance.ref(path);
    UploadTask uploadTask = storageReference.putData(
        fileBytes!, SettableMetadata(contentType: 'image/$fileExtension'));

    // TaskSnapshot uploadTaskSnapshot = await storageRef.putData(
    //     fileBytes!, SettableMetadata(contentType: 'image/$fileExtension'));

    // final imageUri = await uploadTaskSnapshot.ref.getDownloadURL();

    await uploadTask.whenComplete(() => null);
    String returnURL = '';
    await storageReference
        .getDownloadURL()
        .then((fileURL) => returnURL = fileURL);
    return returnURL;
  }
}

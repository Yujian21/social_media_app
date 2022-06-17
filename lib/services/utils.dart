import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Utilities {
  // Upload the profile image to Firebase Storage and get the download URL for 
  // that file 
  Future<String> uploadFile(PlatformFile? file, String path) async {

    // Grab the byte values representing the profile image file
    var fileBytes = file!.bytes;

    // Grab the extension type of the file and convert to lower case
    var fileExtension = file.extension!.toLowerCase();

    // Create the profile image upload task, with the path being specified 
    // in the parameter, together with the metadata for the extension type 
    final storageReference = FirebaseStorage.instance.ref(path);
    UploadTask uploadTask = storageReference.putData(
        fileBytes!, SettableMetadata(contentType: 'image/$fileExtension'));

    // Wait for the upload task to complete, obtain the download URL for the 
    // profile image and return that value
    await uploadTask.whenComplete(() => null);
    String returnURL = '';
    await storageReference
        .getDownloadURL()
        .then((fileURL) => returnURL = fileURL);
    return returnURL;
  }


  // Check if the name/username already exists
  Future<bool> doesNameAlreadyExist(String name) async {
    // Limit the search result for the name/username to just 1
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    
    // Return the boolean condition for the following statement:
    // The number of search results is equal to 1
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }
}

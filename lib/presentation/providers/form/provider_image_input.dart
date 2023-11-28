import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProviderImageInput extends ChangeNotifier {
  FileImage? _image;
  String? _imageUrl;
  File? _imageFile;
  final picker = ImagePicker();
  final imageCropper = ImageCropper();

  FileImage? get image => _image;
  String? get imageUrl => _imageUrl;
  File? get imageFile => _imageFile;

  set imageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  void resetImage() {
    _image = null;
    _imageFile = null;
    notifyListeners();
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      await _cropImage(File(pickedFile.path));
      await uploadImageToFirebase(_imageFile!.path);
      notifyListeners();
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 700,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
      ]
    );

    if (croppedFile != null) {
      _imageFile = File(croppedFile.path);
      _image = FileImage(_imageFile!);
    }
  }

  Future<void> uploadImageToFirebase(String file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(File(file));
    await uploadTask.whenComplete(() async {
      _imageUrl = await firebaseStorageRef.getDownloadURL();
    });
  }

  Future<void> showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select image...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take Photo'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Open Gallery'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class ProviderImageInput extends ChangeNotifier {
//   FileImage? _image;
//   String? _imageUrl;
//   String? _folder;
//   File? _imageFile;
//   final picker = ImagePicker();

//   FileImage? get image => _image;
//   String? get imageUrl => _imageUrl;
//   String? get folder => _folder;
//   File? get imageFile => _imageFile;

//   set folder(String? folder) {
//     _folder = folder;
//     notifyListeners();
//   }

//   set imageUrl(String? imageUrl) {
//     _imageUrl = imageUrl;
//     notifyListeners();
//   }

//   void resetImage() {
//     _image = null;
//     _imageFile = null;
//     notifyListeners();
//   }

//   Future<void> getImage(ImageSource source) async {
//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       _imageFile = File(pickedFile.path);
//       _image = FileImage(_imageFile!);
//       await uploadImageToFirebase(pickedFile.path);
//       notifyListeners();
//     }
//   }

//   Future<void> uploadImageToFirebase(String file) async {
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('$folder/$fileName.jpg');
//     UploadTask uploadTask = firebaseStorageRef.putFile(File(file));
//     await uploadTask.whenComplete(() async {
//       _imageUrl = await firebaseStorageRef.getDownloadURL();
//       notifyListeners();
//     });
//   }

//   Future<void> showImageSourceDialog(BuildContext context) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select image...'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera),
//                 title: const Text('Take Photo'),
//                 onTap: () {
//                   getImage(ImageSource.camera);
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Open Gallery'),
//                 onTap: () {
//                   getImage(ImageSource.gallery);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
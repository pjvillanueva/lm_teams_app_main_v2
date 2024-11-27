import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';

final picker = ImagePicker();

Future<File?> showUploadPhotoDialog(BuildContext context) async {
  File? imageFile;
  await showDialog<File?>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        titlePadding:
            EdgeInsets.fromLTRB(15.0.spMin, 25.0.spMin, 15.0.spMin, 10.0.spMin),
        contentPadding: EdgeInsets.all(10.0.spMin),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const DialogTitle(title: 'Select Image'),
        children: [
          Column(
            children: [
              ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: Icon(Icons.camera_outlined, size: 24.0.spMin),
                  minLeadingWidth: 56.0.spMin,
                  title: Text('Take a photo',
                      style: TextStyle(fontSize: 16.0.spMin)),
                  onTap: () async {
                    imageFile = await takePhoto();
                    Navigator.pop(context);
                  }),
              SizedBox(height: 10.0.spMin),
              ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: Icon(Icons.collections_outlined, size: 24.0.spMin),
                  minLeadingWidth: 56.0.spMin,
                  title: Text('From gallery',
                      style: TextStyle(fontSize: 16.0.spMin)),
                  onTap: () async {
                    imageFile = await selectPhoto();
                    Navigator.pop(context);
                  }),
            ],
          )
        ],
      );
    },
  );
  return imageFile;
}

Future<File?> takePhoto() async {
  final pickedXFIle = await picker.pickImage(source: ImageSource.camera);
  if (pickedXFIle != null) {
    return File(pickedXFIle.path);
  } else {
    print("No photo was selected or taken");
    return null;
  }
}

Future<File?> selectPhoto() async {
  final pickedXFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedXFile != null) {
    return File(pickedXFile.path);
  } else {
    print("No photo was selected or taken");
    return null;
  }
}

Future<File?> cropImage(File? imageFile, BuildContext context) async {
  if (imageFile != null) {
    CroppedFile? _croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            backgroundColor: Theme.of(context).colorScheme.background,
            toolbarColor: Theme.of(context).colorScheme.surface,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Image',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (_croppedFile != null) {
      return File(_croppedFile.path);
    } else {
      print("Cropped file is null");
      return null;
    }
  } else {
    print("Image file is null");
    return null;
  }
}

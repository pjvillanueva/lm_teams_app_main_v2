import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

class Avatar extends StatelessWidget {
  const Avatar(
      {Key? key,
      required this.placeholder,
      required this.size,
      this.borderWidth,
      this.image,
      this.imageFile,
      this.onTapButton,
      this.onTapPicture,
      this.isCircle = false,
      this.backgroundColor})
      : super(key: key);

  final Widget placeholder;
  final ImageObject? image;
  final File? imageFile;
  final Size size;
  final bool isCircle;
  final Color? backgroundColor;
  final double? borderWidth;
  final void Function()? onTapButton;
  final void Function()? onTapPicture;
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, clipBehavior: Clip.none, children: [
      GestureDetector(
          child: Container(
              width: size.width.spMin,
              height: size.height.spMin,
              decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  border: Border.all(
                      color: Colors.grey.shade400,
                      width: borderWidth ?? 1.0.spMin,
                      style: BorderStyle.solid),
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle),
              child: imageFile == null
                  ? ClipRRect(
                      borderRadius: isCircle
                          ? BorderRadius.all(Radius.circular(size.width.spMin))
                          : BorderRadius.zero,
                      child: Container(
                          color: backgroundColor ?? Colors.grey.shade400,
                          height: size.height.spMin,
                          width: size.width.spMin,
                          child: image != null
                              ? CachedNetworkImage(
                                  imageUrl: image?.url ?? '',
                                  width: size.width.spMin,
                                  height: size.height.spMin,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(strokeWidth: 2.0.spMin)),
                                  errorWidget: (context, url, error) =>
                                      const Center(child: Icon(Icons.error, color: Colors.red)))
                              : Center(child: placeholder)))
                  : ClipRRect(
                      borderRadius: isCircle
                          ? BorderRadius.all(Radius.circular(size.width.spMin))
                          : BorderRadius.zero,
                      child: Container(
                          color: Colors.grey.shade400,
                          height: size.height.spMin,
                          width: size.width.spMin,
                          child: Center(
                              child: Image.file(File(imageFile!.path),
                                  width: size.width, height: size.height, fit: BoxFit.fill))))),
          onTap: onTapPicture),
      Visibility(
          visible: onTapButton != null,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            RawMaterialButton(
                onPressed: onTapButton,
                elevation: 2.0.spMin,
                fillColor: Colors.grey.shade500,
                child: Icon(Icons.camera_alt_rounded, color: Colors.black, size: 24.0.spMin),
                padding: EdgeInsets.all(12.0.spMin),
                shape: CircleBorder(side: BorderSide(width: 3.0.spMin, color: Colors.white))),
            SizedBox(height: 20.0.spMin)
          ]))
    ]);
  }
}

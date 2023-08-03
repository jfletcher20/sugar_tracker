import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'dart:io';

class ImagePickerWidget extends StatefulWidget {
  final double? imgSize;
  final String path;
  const ImagePickerWidget({super.key, this.imgSize, required this.path});

  @override
  State<ImagePickerWidget> createState() => ImagePickerWidgetState();
}

class ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? image;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  void loadImage() {
    if (File(widget.path).existsSync()) {
      setState(() => image = File(widget.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.imgSize,
      width: widget.imgSize,
      child: _buildImageInput(),
    );
  }

  Widget imageNotFound(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      "assets/images/food/unknown.png",
      color: Colors.redAccent,
      height: widget.imgSize,
      width: widget.imgSize,
    );
  }

  _border() {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: _border(),
      showDragHandle: true,
      builder: _modalOptions(),
    );
  }

  Widget Function(BuildContext context) _modalOptions() {
    return (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _title(),
          _useCamera(),
          _fromGallery(),
          _clearPhoto(),
        ],
      );
    };
  }

  Text _title() {
    return Text(
      "Add a picture of your product",
      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
    );
  }

  ListTile _useCamera() {
    return ListTile(
      leading: const Icon(Icons.camera, color: Colors.white),
      title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
      onTap: () {
        _getFromCamera();
        Navigator.pop(context);
      },
    );
  }

  ListTile _fromGallery() {
    return ListTile(
      leading: const Icon(Icons.photo_library, color: Colors.white),
      title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
      onTap: () {
        _getFromGallery();
        Navigator.pop(context);
      },
    );
  }

  ListTile _clearPhoto() {
    return ListTile(
      leading: const Icon(Icons.cancel, color: Colors.white),
      title: const Text('Clear photo', style: TextStyle(color: Colors.white)),
      enabled: (image) != null,
      tileColor: (image) == null ? Colors.black.withOpacity(0.4) : null,
      onTap: () {
        setState(() => image = null);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: widget.imgSize,
      maxWidth: widget.imgSize,
    );
    if (pickedFile != null) setState(() => image = File(pickedFile.path));
  }

  Future<void> _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: widget.imgSize,
      maxWidth: widget.imgSize,
    );
    if (pickedFile != null) setState(() => image = File(pickedFile.path));
  }

  Widget _buildImageInput() {
    return Container(
      decoration: outline,
      width: widget.imgSize,
      height: widget.imgSize,
      child: InkWell(onTap: () => _showImagePicker(), child: _img()),
    );
  }

  Image _img() {
    if (image == null) {
      return Image.asset(
        "assets/images/food/unknown.png",
        color: Colors.redAccent,
        height: widget.imgSize,
        width: widget.imgSize,
        errorBuilder: imageNotFound,
      );
    } else {
      return Image.file(
        image!,
        height: widget.imgSize,
        width: widget.imgSize,
        errorBuilder: imageNotFound,
      );
    }
  }

  BoxDecoration get outline {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.red, width: 3),
      color: Colors.white,
    );
  }
}

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:sugar_tracker/presentation/widgets/w_imagepicker_tiles.dart';

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
        children: [_title, _useCamera, _fromGallery, _clearPhoto],
      );
    };
  }

  Text get _title {
    return Text(
      "Add a picture of your product",
      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
    );
  }

  ListTile get _useCamera {
    return ImagePickerTile(
      icon: Icons.camera,
      title: 'Take a photo',
      onTap: () {
        _getFromCamera();
        if (mounted) Navigator.pop(context);
      },
    );
  }

  ListTile get _fromGallery {
    return ImagePickerTile(
      icon: Icons.photo_library,
      title: 'Choose from gallery',
      onTap: () {
        _getFromGallery();
        if (mounted) Navigator.pop(context);
      },
    );
  }

  ListTile get _clearPhoto {
    return ImagePickerTile(
      icon: Icons.cancel,
      title: 'Clear photo',
      enabled: image != null,
      tileColorChange: image == null,
      onTap: () {
        setState(() => image = null);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  Future<void> _pickImage({required ImageSource source}) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      maxHeight: widget.imgSize,
      maxWidth: widget.imgSize,
    );
    if (pickedFile != null) setState(() => image = File(pickedFile.path));
  }

  Future<void> _getFromCamera() => _pickImage(source: ImageSource.camera);
  Future<void> _getFromGallery() => _pickImage(source: ImageSource.gallery);

  Widget _buildImageInput() {
    return Container(
      decoration: outline,
      width: widget.imgSize,
      height: widget.imgSize,
      child: InkWell(onTap: _showImagePicker, child: _img),
    );
  }

  Image get _img {
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

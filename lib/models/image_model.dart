import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'image_model.g.dart';

@HiveType(typeId: 0)
class ImageModel extends HiveObject {
  
  @HiveField(0)
  String? position;

  @HiveField(1)
  Uint8List image;

  ImageModel(this.image, {@required this.position});

}

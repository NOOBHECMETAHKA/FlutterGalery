import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:galary/models/image_model.dart';
import 'package:galary/provider/theme_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MainListWidget extends StatefulWidget {
  const MainListWidget({super.key});

  @override
  State<MainListWidget> createState() => _MainListWidgetState();
}

class _MainListWidgetState extends State<MainListWidget> {
  //Box images
  late Box<ImageModel> _imageBox;
  //Position
  String currentPosition = '';

  @override
  void initState() {
    super.initState();
    _imageBox = Hive.box<ImageModel>('images');
    getCurrentLocation();
  }

  Future<List<ImageModel>> getImagesFromHive(String boxLink) async {
    List<ImageModel> images = [];
    for (var i = 0; i < _imageBox.length; i++) {
      var imageModel = _imageBox.getAt(i) as ImageModel;
      images.add(imageModel);
    }
    return images;
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position p = await Geolocator.getCurrentPosition();
    currentPosition = "location: ${p.latitude}, ${p.longitude}";
  }

  Future<void> _getImage(bool isCamera) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    Uint8List pic = await File(pickedFile!.path).readAsBytes();

    setState(() {
      if (pickedFile != null) {
        if (currentPosition != "") {
          _imageBox.add(ImageModel(pic, position: currentPosition));
        } else {
          print("No location");
        }
      } else {
        print('No image selected');
      }
    });
  }

  //Форма добавление
  void _showForm(BuildContext ctx, int? itemKey) async {
    getCurrentLocation();
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: currentPosition == ''
                            ? const Text("Мы не можем тебя найти!")
                            : Text(currentPosition),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              //Вставка данных из камеры
                              await _getImage(true);
                            },
                            icon: const Icon(Icons.camera),
                            label: const Text('Камера')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton.icon(
                            onPressed: () async {
                              //Вставка данных из галерии
                              await _getImage(false);
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text('Галерея')),
                      )
                    ]),
              ),
            ));
  }

  //Показать картинки
  Future<void> _showPicture(BuildContext ctx, dynamic key) async {
    ImageModel? photo = _imageBox.get(key);
    if (photo != null) {
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15),
          child: Center(
            child: Image.memory(photo.image),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imageBox.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              setState(() {
                context.read<ThemeProvider>().toggleTheme();
              });
            },
            icon: const Icon(Icons.theater_comedy)),
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.exit_to_app_sharp))
      ]),
      body: ListView.builder(
        itemCount: _imageBox.length,
        itemBuilder: (context, index) {
          final ImageModel element = _imageBox.getAt(index) as ImageModel;
          return ListTile(
              title: Text(element.position.toString() != ""
                  ? element.key.toString()
                  : "No title!"),
              subtitle: Text(element.position.toString() != ""
                  ? element.position.toString()
                  : "No position!"),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _imageBox.delete(element.key);
                  });
                },
              ),
              onTap: () {
                // ignore: use_build_context_synchronously
                _showPicture(context, element.key);
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

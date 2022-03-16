import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/routes/screens.dart';
import 'package:hyper_garage_sale/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

const primaryColor = Color(0xFF82B1FF);

class AddPostPage extends StatelessWidget {
  static const String routeName = '/addPost';

  const AddPostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Add New Post'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: const Center(
        child: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  PostData _newPost = PostData();
  List<Asset> _images = <Asset>[];
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: _images,
        cupertinoOptions: const CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Done",
        ),
        materialOptions: const MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } catch (e) {
      return;
    }

    setState(() {
      _images = resultList;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> uploadPost() async {
      if (_images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least 1 image.')),
        );
        return false;
      }

      List<String> refs = <String>[];
      for (int i = 0; i < _images.length; i++) {
        ByteData data = await _images[i].getByteData();
        Reference ref = FirebaseStorage.instance
            .ref("yuwang/${_images[i].identifier}:${_images[i].name}");
        await ref.putData(Uint8List.view(data.buffer));
        refs.add(ref.fullPath);
      }

      return _firestore.collection("yuwang-posts").add({
        'title': _newPost.title,
        'price': _newPost.price,
        'description': _newPost.description,
        'image_paths': refs,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New post uploaded successfully.')),
        );
        return true;
      }).catchError((error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload new post.')),
        );
        return false;
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              icon: Icon(Icons.list_alt_outlined),
              hintText: 'Enter title of the item',
              labelText: 'Title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter title of the item';
              }
              return null;
            },
            onSaved: (value) {
              _newPost.title = value!;
            },
          ),
          TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              icon: Icon(Icons.monetization_on),
              hintText: 'Enter price',
              labelText: 'Price',
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
            onSaved: (value) {
              _newPost.price = value!;
            },
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.inventory_rounded),
              hintText: 'Enter description of the item',
              labelText: 'Info',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              if (value.length < 20) {
                return 'Description must be at least 20 characters';
              }
              return null;
            },
            onSaved: (value) {
              _newPost.description = value!;
            },
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                child: Text("Pick images (${_images.length})"),
                onPressed: loadAssets,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 160.0, vertical: 50.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.indigo.shade100;
                    }
                    return primaryColor;
                  },
                ),
              ),
              onPressed: () async {
                final form = _formKey.currentState;
                if (form != null && form.validate()) {
                  form.save();
                  if (await uploadPost()) {
                    titleController.clear();
                    priceController.clear();
                    descriptionController.clear();
                    setState(() {
                      _newPost = PostData();
                      _images.clear();
                    });
                  }
                }
              },
              child: const Text('POST'),
            ),
          ),
        ],
      ),
    );
  }
}

class PostData {
  String title = '';
  String price = '';
  String description = '';
}

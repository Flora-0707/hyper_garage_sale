import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/widgets/drawer.dart';
import 'package:path_provider/path_provider.dart';

class PostDetailsPage extends StatelessWidget {
  static const String routeName = '/postDetails';

  final DocumentSnapshot post;

  const PostDetailsPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                TextPairBox(title: ' Title', content: post['title']),
                const SizedBox(width: 15.0),
                TextPairBox(title: ' Price', content: '\$ ${post['price']}'),
              ],
            ),
            TextPairBox(title: ' Description', content: post['description']),
            const SizedBox(height: 5.0),
            Expanded(
              child: ImageGridView(
                post: post,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageGridView extends StatelessWidget {
  final DocumentSnapshot post;

  const ImageGridView({Key? key, required this.post}) : super(key: key);

  Future<List<File>> downloadImages(BuildContext context) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    FirebaseStorage storage = FirebaseStorage.instance;
    List<File> ret = <File>[];
    for (var i = 0; i < post['image_paths'].length; i++) {
      String imageName = post['image_paths'][i];
      File f = File("${appDocDir.path}/$imageName");
      if (f.existsSync()) {
        ret.add(f);
        continue;
      }
      try {
        await storage.ref(imageName).writeToFile(f);
        ret.add(f);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load image.')),
        );
        return <File>[];
      }
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: downloadImages(context),
      builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
        if (snapshot.hasError) {
          return const Text('Failed to upload post.');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          List<File> images = snapshot.data!;
          return GridView.count(
            crossAxisCount: 2,
            children: List.generate(images.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullPicture(image: images[index]),
                      ),
                    );
                  },
                  child: Image.file(images[index]),
                ),
              );
            }),
          );
        }
        return const Text("Loading images");
      },
    );
  }
}

class FullPicture extends StatelessWidget {
  final File image;
  const FullPicture({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post detail"),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}

class TextPairBox extends StatelessWidget {
  final String title;
  final String content;

  const TextPairBox({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title,
            style: const TextStyle(fontSize: 12.0, color: Colors.black87)),
        const SizedBox(height: 2.0),
        Material(
          // borderRadius: BorderRadius.all(Radius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Text(content,
                style:
                    TextStyle(fontSize: 18.0, color: Colors.blueAccent[100])),
          ),
          // color: Colors.blueAccent[100],
        ),
        const SizedBox(height: 15.0),
      ],
    );
  }
}

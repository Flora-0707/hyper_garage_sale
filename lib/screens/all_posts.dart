import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/routes/screens.dart';
import 'package:hyper_garage_sale/screens/add_post.dart';
import 'package:hyper_garage_sale/screens/homepage.dart';
import 'package:hyper_garage_sale/screens/post_details.dart';
import 'package:hyper_garage_sale/widgets/drawer.dart';

class Choice {
  const Choice({required this.title, required this.routeName});
  final String title;
  final String routeName;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Homepage', routeName: MyHomePage.routeName),
  Choice(title: 'Add Post', routeName: AddPostPage.routeName),
];

class AllPostsPage extends StatelessWidget {
  static const String routeName = '/allPosts';

  const AllPostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _handleChoiceSelection(Choice choice) {
      Navigator.pushNamed(context, choice.routeName);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Posts'),
        backgroundColor: Colors.blueAccent[100],
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _handleChoiceSelection,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const GetPosts(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddPostPage.routeName);
        },
        backgroundColor: Colors.blueAccent[100],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetPosts extends StatelessWidget {
  const GetPosts({Key? key}) : super(key: key);

  void _showPostPage(BuildContext context, DocumentSnapshot post) {
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: PostDetailsPage.routeName),
          builder: (BuildContext context) => PostDetailsPage(post: post),
        ));
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference posts =
        FirebaseFirestore.instance.collection('yuwang-posts');

    return FutureBuilder<QuerySnapshot>(
      future: posts.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Text("No posts yet.");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return ListView.separated(
            itemBuilder: (context, index) {
              DocumentSnapshot post = docs[index];
              return ListTile(
                  title: Text(post["title"]),
                  onTap: () {
                    _showPostPage(context, post);
                  });
            },
            separatorBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Divider(color: Colors.blueAccent[100]),
              );
            },
            itemCount: docs.length,
          );
        }
        return const Text("loading");
      },
    );
  }
}

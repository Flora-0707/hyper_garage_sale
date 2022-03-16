import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/widgets/drawer.dart';

class MyHomePage extends StatelessWidget {
  static const String routeName = '/homepage';

  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('HyperGarageSale'),
        backgroundColor: Colors.blueAccent[100],
      ),
      body: const Center(
        child: Text('Welcome to - not pretty but useful - Hyper Garage Sale!'),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   child: Row(
      //     children: [
      //       // IconButton(
      //       //   icon: Icon(Icons.menu),
      //       //   onPressed: () {
      //       //     // Animate a bottom drawer
      //       //   },
      //       // ),
      //       Spacer(),
      //       IconButton(icon: Icon(Icons.search), onPressed: () {}),
      //       IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
      //     ],
      //   ),
      // ),
    );
  }
}

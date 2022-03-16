import 'package:flutter/material.dart';
import 'package:hyper_garage_sale/routes/screens.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
            icon: Icons.contacts,
            text: 'Homepage',
            onTap: () =>
                Navigator.pushReplacementNamed(context, Routes.homepage),
          ),
          _createDrawerItem(
            icon: Icons.contacts,
            text: 'All Items',
            onTap: () =>
                Navigator.pushReplacementNamed(context, Routes.allPosts),
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
      child: const Text(
        'Side menu',
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      decoration: BoxDecoration(
        color: Colors.blueAccent[100],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}

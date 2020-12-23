import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'LiveSawa menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration( color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Accueil'),
            onTap: () => {Navigator.pushReplacementNamed(context,'/home')},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Plateforme d’apprentissage'),
            onTap: () => { Navigator.pushReplacementNamed(context,'/plateforme')},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Webconférence'),
            onTap: () => {Navigator.of(context).pushReplacementNamed('/classe-virtuelle')},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Nos services'),
            onTap: () => {Navigator.of(context).pushReplacementNamed('/nos-services')},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}

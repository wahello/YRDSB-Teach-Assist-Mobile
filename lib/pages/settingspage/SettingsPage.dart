import 'package:flutter/material.dart';
import 'package:ta/dataStore.dart';
import 'package:ta/main.dart';
import 'package:ta/pages/settingspage/SelectColorDialog.dart';
import 'package:ta/res/Strings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.get("settings")),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(Strings.get("manage_accounts_alt")),
            leading: Icon(Icons.account_circle),
            onTap: () {
              Navigator.pushNamed(context, "/accounts_list");
            },
          ),
          ListTile(
            title: Text(Strings.get("dark_mode")),
            leading: Icon(Icons.brightness_4),
            trailing: DropdownButton<int>(
                value: Config.darkMode,
                onChanged: (v) {
                  App.updateBrightness(v);
                },
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(Strings.get("force_light")),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(Strings.get("follow_system")),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(Strings.get("force_dark")),
                  ),
                ]),
          ),
          ListTile(
            title: Text(Strings.get("primary_color")),
            leading: Icon(Icons.color_lens),
            trailing: Container(
              width: 24.0,
              height: 24.0,
              decoration: new BoxDecoration(
                color: Config.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SelectColorDialog();
                  });
            },
          ),
          ListTile(
            title: Text(Strings.get("default_first_page")),
            leading: Icon(Icons.home),
            trailing: DropdownButton<int>(
                value: Config.firstPage,
                onChanged: (v) {
                  setState(() {
                    Config.firstPage = v;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(Strings.get("summary")),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text(Strings.get("time_line")),
                  ),
                ]),
          ),
          ListTile(
            title: Text(Strings.get("show_more_decimal_places")),
            leading: Icon(Icons.exposure_plus_2),
            trailing: Switch(
              value: Config.showMoreDecimal,
              onChanged: (v) {
                setState(() {
                  Config.showMoreDecimal = v;
                });
              },
            ),
            onTap: () {
              setState(() {
                Config.showMoreDecimal = !Config.showMoreDecimal;
              });
            },
          )
        ],
      ),
    );
  }
}
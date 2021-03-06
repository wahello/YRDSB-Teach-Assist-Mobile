import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:ta/model/Mark.dart';
import 'package:ta/model/User.dart';
import 'package:ta/pages/detailpage/assignmentstab/MarksListTile.dart';
import 'package:ta/plugins/dataStore.dart';
import 'package:ta/res/Strings.dart';
import 'package:ta/tools.dart';

class AssignmentSearchDelegate extends SearchDelegate {
  List<String> history;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return isLightMode(context: context) ? super.appBarTheme(context) : Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query == "") {
            close(context, "");
          } else {
            query = "";
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query != "") onAddHistory(query);
    return getResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return getResultList(context);
  }

  List<String> onGetHistory() {
    if (history == null) {
      history = List<String>();
      (jsonDecode(prefs.getString("search-history") ?? "[]") as List<dynamic>)
          .forEach((historyStr) {
        history.add(historyStr.toString());
      });
    }
    return history;
  }

  onAddHistory(String str) {
    history.remove(str);
    history.insert(0, str);
    prefs.setString("search-history", jsonEncode(history));
  }

  onClearHistory() {
    history.clear();
    prefs.setString("search-history", "[]");
  }

  onSelectHistory(String str, BuildContext context) {
    onAddHistory(str);
    query = str;
    showResults(context);
  }

  Widget getResultList(BuildContext context) {
    if (query == "") {
      return _SearchHistoryList(
          onGetHistory: onGetHistory,
          onClearHistory: onClearHistory,
          onSelectHistory: onSelectHistory);
    }

    var sidePadding = (getScreenWidth(context) - 500) / 2;
    var listItems = List<Widget>();
    getCourseListOf(currentUser.number).forEach((course) {
      var matchedItems = List<Widget>();
      if (course.assignments != null)
        course.assignments.reversed.forEach((assignment) {
          if (_isRelated(assignment.displayName, query)) {
            matchedItems.add(MarksListTile(
              assignment,
              course.weightTable,
              false,
              key: Key(assignment.hashCode.toString()),
            ));
          }
        });

      if (matchedItems.length > 0)
        listItems.add(StickyHeader(
          header: Container(
            color: isLightMode(context: context) ? Colors.grey[200] : Colors.grey[800],
            padding: EdgeInsets.fromLTRB((sidePadding > 0 ? sidePadding : 0) + 16.0, 8, 16, 8),
            alignment: Alignment.centerLeft,
            child: Text(sprintf(Strings.get("results_from"), [course.displayName])),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sidePadding > 0 ? sidePadding : 0,
            ),
            child: Column(
              children: matchedItems,
            ),
          ),
          key: Key(course.displayName),
        ));
    });

    if (listItems.length > 0) {
      return ListView(
        padding: EdgeInsets.only(
          bottom: getBottomPadding(context),
        ),
        children: listItems,
      );
    } else {
      return Center(
        child: Text(Strings.get("no_results_found")),
      );
    }
  }
}

bool _isRelated(String str, String query) {
  var loweredStr = str.toLowerCase();
  var keywords = query.toLowerCase().split(" ");
  for (var keyword in keywords) {
    if (loweredStr.indexOf(keyword) == -1) {
      return false;
    }
  }
  return true;
}

class _SearchHistoryList extends StatefulWidget {
  final onGetHistory;
  final onClearHistory;
  final onSelectHistory;

  _SearchHistoryList({this.onGetHistory, this.onClearHistory, this.onSelectHistory});

  @override
  _SearchHistoryListState createState() => _SearchHistoryListState();
}

class _SearchHistoryListState extends State<_SearchHistoryList> {
  List<String> history;

  List<String> onGetHistory() {
    if (history == null) {
      history = widget.onGetHistory();
    }
    return history;
  }

  onSelectHistory(String str, BuildContext context) {
    widget.onSelectHistory(str, context);
  }

  onClearHistory() {
    setState(() {
      history.clear();
      widget.onClearHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    var historyWidgets = List<Widget>();
    onGetHistory().forEach((historyStr) {
      historyWidgets.add(ListTile(
        key: Key(historyStr),
        title: Text(historyStr),
        leading: Icon(Icons.history),
        onTap: () {
          onSelectHistory(historyStr, context);
        },
      ));
    });
    if (historyWidgets.length > 0) {
      historyWidgets.add(Center(
        child: FlatButton.icon(
            onPressed: onClearHistory,
            icon: Icon(Icons.clear_all),
            label: Text(Strings.get("clear_all").toUpperCase())),
      ));
    }

    var sidePadding = (getScreenWidth(context) - 500) / 2;
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: sidePadding > 0 ? sidePadding : 0,
      ),
      children: historyWidgets,
    );
  }
}

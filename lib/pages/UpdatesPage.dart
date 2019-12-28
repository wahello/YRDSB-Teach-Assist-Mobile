import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ta/model/TimeLineUpdateModels.dart';
import 'package:ta/model/User.dart';
import 'package:ta/pages/summarypage/timelinecontents/getUpdateWidget.dart';
import 'package:ta/widgets/BetterState.dart';

import '../tools.dart';

class UpdatesPage extends StatefulWidget {
  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends BetterState<UpdatesPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Updates"),
            forceElevated:true,
            floating: true,
            snap: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                _getTimelineCards(getTimelineOf(currentUser.number))
            ),
          )
        ],
      )
    );
  }

  List<Widget> _getTimelineCards(List<TAUpdate> timeline) {
    var list = List<Widget>();
    var sameDayContents = List<Widget>();
    DateTime lastContentDate;

    timeline.reversed.forEach((update) {
      if (sameDayContents.length == 0) {
        addIfNotNull(sameDayContents, getUpdateWidget(update));
        lastContentDate = update.time;
      } else if (isSameDay(lastContentDate, update.time)) {
        addIfNotNull(sameDayContents, getUpdateWidget(update));
      } else {
        list.add(_cardOfDate(time: lastContentDate, children: sameDayContents));
        sameDayContents = List<Widget>();
        addIfNotNull(sameDayContents, getUpdateWidget(update));
        lastContentDate = update.time;
      }
    });
    if (sameDayContents.length != 0) {
      list.add(_cardOfDate(time: lastContentDate, children: sameDayContents));
    }

    return list;
  }

  Widget _cardOfDate({List<Widget> children, DateTime time}) {
    var contents = List<Widget>();
    for (var i = 0; i < children.length; i++) {
      contents.add(children[i]);
      if (i != children.length - 1) {
        contents.add(SizedBox(height: 4));
        contents.add(Divider());
        contents.add(SizedBox(height: 4));
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(DateFormat("EEE, MMM d").format(time),
                style: Theme.of(context).textTheme.title),
          ),
          SizedBox(
            height: 4,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: contents,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
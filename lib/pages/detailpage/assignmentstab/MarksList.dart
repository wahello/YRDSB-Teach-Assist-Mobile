import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ta/dataStore.dart';
import 'package:ta/model/Mark.dart';
import 'package:ta/pages/detailpage/assignmentstab/SmallMarkChartDetail.dart';
import 'package:ta/pages/detailpage/assignmentstab/TipsCard.dart';
import 'package:ta/res/Strings.dart';

import '../../../tools.dart';
import 'SmallMarkChart.dart';

class MarksList extends StatefulWidget {
  MarksList(this._course);

  final Course _course;

  @override
  _MarksListState createState() => _MarksListState(_course);
}

class _MarksListState extends State<MarksList> with TickerProviderStateMixin {
  final Course _course;
  var showTips = prefs.getBool("show_tap_to_view_detail_tip") ?? true;

  _MarksListState(this._course);

  @override
  Widget build(BuildContext context) {
    return _course.overallMark != null
        ? ListView.builder(
            cacheExtent: double.maxFinite,
            itemCount: _course.assignments.length * 2 + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return AnimatedSize(
                  vsync: this,
                  curve: Curves.easeInOutCubic,
                  duration: Duration(milliseconds: 300),
                  child: AnimatedSwitcher(
                      child: showTips
                          ? TipsCard(
                              text: Strings.get("tap_to_view_detail"),
                              onDismiss: () {
                                setState(() {
                                  showTips = false;
                                  prefs.setBool("show_tap_to_view_detail_tip", false);
                                });
                              })
                          : SizedBox(
                              height: 8,
                            ),
                      duration: Duration(milliseconds: 300)),
                );
              }
              if (index.isOdd) {
                var assignment =
                    _course.assignments[_course.assignments.length - 1 - ((index - 1) ~/ 2)];
                return _MarksListTile(assignment, _course.weightTable);
              } else {
                return Divider();
              }
            },
          )
        : Center(
            child: Text(
              Strings.get("assignments_unavailable"),
              style: Theme.of(context).textTheme.subhead,
            ),
          );
  }
}

class _MarksListTile extends StatefulWidget {
  final Assignment _assignment;
  final WeightTable _weights;

  _MarksListTile(this._assignment, this._weights);

  @override
  _MarksListTileState createState() => _MarksListTileState(_assignment, _weights);
}

class _MarksListTileState extends State<_MarksListTile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final Assignment _assignment;
  final WeightTable _weights;
  var showDetail = false;

  _MarksListTileState(this._assignment, this._weights);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var avg = _assignment.getAverage(_weights);
    var avgText = avg == null
        ? SizedBox(width: 0, height: 0)
        : Text(Strings.get("avg:") + _assignment.getAverage(_weights),
            style: TextStyle(fontSize: 16, color: Colors.grey));

    bool noWeight = isZeroOrNull(_assignment.KU.weight) &&
        isZeroOrNull(_assignment.T.weight) &&
        isZeroOrNull(_assignment.C.weight) &&
        isZeroOrNull(_assignment.A.weight) &&
        isZeroOrNull(_assignment.F.weight) &&
        isZeroOrNull(_assignment.O.weight);

    var summary = Row(
      key: Key("summary"),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_assignment.beautifulName, style: Theme.of(context).textTheme.title),
              SizedBox(
                height: 4,
              ),
              avgText,
              if (noWeight)
                Text(Strings.get("no_weight"), style: TextStyle(fontSize: 16, color: Colors.grey)),
              if (_assignment.feedback != "")
                Text("Feedback avaliable", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
        Flexible(child: SmallMarkChart(_assignment))
      ],
    );
    var detail = Column(
      key: Key("detail"),
      children: <Widget>[
        Text(
          _assignment.beautifulName,
          style: Theme.of(context).textTheme.title,
        ),
        SizedBox(
          height: 4,
        ),
        avgText,
        SizedBox(
          height: 4,
        ),
        if (_assignment.feedback != "")
          Text(
            "Feedback: " + _assignment.feedback,
            style: TextStyle(
                fontSize: 16, color: isLightMode(context) ? Colors.grey[800] : Colors.grey[200]),
            textAlign: TextAlign.center,
          ),
        SizedBox(
          height: 12,
        ),
        SmallMarkChartDetail(_assignment)
      ],
    );

    return InkWell(
      onTap: () {
        setState(() {
          showDetail = !showDetail;
        });
      },
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedCrossFade(
            firstChild: summary,
            secondChild: detail,
            crossFadeState: showDetail ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOutCubic,
            secondCurve: Curves.easeInOutCubic,
            sizeCurve: Curves.easeInOutCubic,
          )),
    );
  }
}

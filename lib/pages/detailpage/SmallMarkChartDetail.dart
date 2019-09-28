import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ta/model/Mark.dart';
import 'package:ta/tools.dart';

class _SmallMarkChartDetailPainter extends CustomPainter {
  final Assignment _assi;
  final Color _Kcolor = Color(0xffffeb3b);
  final Color _Tcolor = Color(0xff8bc34a);
  final Color _Ccolor = Color(0xff9fa8da);
  final Color _Acolor = Color(0xffffb74d);
  final Color _Ocolor = Color(0xff90a4ae);
  final Color _Fcolor = Color(0xff81d4fa);

  _SmallMarkChartDetailPainter(this._assi);

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width;
    var height = size.height;

    var barCount = 4;
    if (_assi.O.available) {
      barCount++;
    }
    if (_assi.F.available) {
      barCount++;
    }
    var barWidth = width / barCount;
    var i = 0;

    _paintBar(
        canvas, "K", _Kcolor, _assi.KU, barWidth * (i++), barWidth, height);
    _paintBar(
        canvas, "T", _Tcolor, _assi.T, barWidth * (i++), barWidth, height);
    _paintBar(
        canvas, "C", _Ccolor, _assi.C, barWidth * (i++), barWidth, height);
    _paintBar(
        canvas, "A", _Acolor, _assi.A, barWidth * (i++), barWidth, height);

    if (_assi.O.available) {
      _paintBar(
          canvas, "O", _Ocolor, _assi.O, barWidth * (i++), barWidth, height);
    }
    if (_assi.F.available) {
      _paintBar(
          canvas, "F", _Fcolor, _assi.F, barWidth * (i++), barWidth, height);
    }
  }

  void _paintBar(Canvas canvas, String text, Color color, SmallMark smallMark,
      double x, double width, double height) {
    var bottomLabelPainter = TextPainter(
        text: TextSpan(
            text: text, style: TextStyle(fontSize: 16.0, color: Colors.grey)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: width, minWidth: width)
      ..paint(canvas, Offset(x, height - 30));

    if (smallMark.available) {
      var mark = smallMark.get / smallMark.total * 100;
      var paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color
        ..isAntiAlias = true;
      canvas.drawRRect(
          RRect.fromLTRBAndCorners(7 + x, (height - 66) * (1 - mark / 100) + 33,
              width - 7 + x, height - 33,
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          paint);

      bottomLabelPainter.text = TextSpan(
          text: "W:" + getRoundString(smallMark.weight, 2),
          style: TextStyle(fontSize: 12.0, color: Colors.grey));
      bottomLabelPainter.layout(maxWidth: width, minWidth: width);
      bottomLabelPainter.paint(canvas, Offset(x, height - 12));

      TextPainter(
          text: TextSpan(
              text: getRoundString(mark, 1),
              style: TextStyle(fontSize: 16.0, color: Colors.grey)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: width, minWidth: width)
        ..paint(canvas, Offset(x, (height - 60) * (1 - mark / 100)))
        ..text = TextSpan(
            text: getRoundString(smallMark.get, 2) +
                "/" +
                getRoundString(smallMark.total, 2),
            style: TextStyle(fontSize: 12.0, color: Colors.grey))
        ..layout(maxWidth: width, minWidth: width)
        ..paint(canvas, Offset(x, (height - 60) * (1 - mark / 100) + 16));
    } else {
      TextPainter(
          text: TextSpan(
              text: "N/A",
              style: TextStyle(fontSize: 16.0, color: Colors.grey)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: width, minWidth: width)
        ..paint(canvas, Offset(x, height - 50));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SmallMarkChartDetail extends StatelessWidget {
  final Assignment _assi;

  SmallMarkChartDetail(this._assi);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.maxFinite,
      child: CustomPaint(
        painter: _SmallMarkChartDetailPainter(_assi),
      ),
    );
  }
}

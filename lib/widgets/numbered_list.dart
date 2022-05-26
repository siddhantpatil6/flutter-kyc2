import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shared_widgets/utils/custom_colors.dart';

class NumberedList extends StatelessWidget {
  List<String> instructions;

  NumberedList({required this.instructions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      children: buildList(context),
    );
  }

  List<Widget> buildList(BuildContext context) {
    List<Widget> list = [];
    instructions.asMap().forEach((index, element) {
      list.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).splashColor,
              ),
              child: Center(
                  child: Text((index + 1).toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).textTheme.bodyText1?.color,
                        fontFamily: 'Barlow',
                      ))),
            ),
            Expanded(
              child: Text(element,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).textTheme.bodyText1?.color,
                    fontFamily: 'Barlow',
                  )),
            )
          ],
        ),
      ));
    });
    return list;
  }
}

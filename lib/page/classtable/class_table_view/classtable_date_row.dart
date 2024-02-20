// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

/// The index row of the class table, shows the index of the day and the week.
class ClassTableDateRow extends StatelessWidget {
  final List<DateTime> dateList = [];
  ClassTableDateRow({super.key, required DateTime firstDay}) {
    /// Here, we get the first day of the week, and generate the date row.
    dateList.addAll(List.generate(7, (i) => firstDay.add(Duration(days: i))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /// This will detertime the height of the row, also the way week info and
      /// day shows.
      height: midRowHeight,
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey.shade200.withOpacity(0.75),
      child: Row(children: [
        Text(
          "${dateList.first.month}月",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ).center().constrained(width: leftRow),
        ...List.generate(
          7,
          (index) => WeekInfomation(
            time: dateList[index],
          ),
        ),
      ]),
    );
  }
}

/// The week index info, shows the day and the week.
class WeekInfomation extends StatelessWidget {
  final DateTime time;
  const WeekInfomation({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    bool isToday =
        (time.month == DateTime.now().month && time.day == DateTime.now().day);
    Size mediaQuerySize = MediaQuery.of(context).size;
    return SizedBox(
      width: (mediaQuerySize.width - leftRow) / 7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            weekList[time.weekday - 1],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            time.day.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : null,
              color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          )
              .center()
              .constrained(
                width: 26,
                height: 20,
              )
              .decorated(
                color: isToday
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.transparent,
              )
              .clipRRect(all: 8),
        ],
      ),
    );
  }
}

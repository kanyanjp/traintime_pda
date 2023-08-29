// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/page/both_side_sheet.dart';
import 'package:watermeter/page/creative_job/creative_job_choice.dart';
import 'package:watermeter/page/creative_job/creative_job_description.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/xidian_ids/creative_service_session.dart';

class CreativeJobView extends StatefulWidget {
  const CreativeJobView({super.key});

  @override
  State<CreativeJobView> createState() => _CreativeJobViewState();
}

class _CreativeJobViewState extends State<CreativeJobView> {
  TextEditingController text = TextEditingController.fromValue(
    const TextEditingValue(text: ""),
  );
  late Future<List<Job>> data;

  List<String> get categories => skill.keys.toList();

  /// where, or, fuzzyWhere, fuzzyOr
  Map query = {
    "order": "created_at desc",
    "size": 20,
  };

  (String, List<String>)? searchTags;
  String searchParameter = "";

  Future<void> search() async {
    /// where, or, fuzzyWhere, fuzzyOr
    Map query = {
      "order": "created_at desc",
      "size": 20,
    };

    if (searchParameter.isNotEmpty) {
      query.addAll(
        {
          "fuzzyOr": [
            {"name": searchParameter},
            {"description": searchParameter},
            {"reward": searchParameter}
          ],
        },
      );
    }

    query.addAll(
      {
        "where": [
          {
            if (searchTags != null && searchTags!.$1.isNotEmpty)
              "skill": searchTags?.$1,
            "tags": searchTags?.$2 ?? [],
          }
        ],
      },
    );

    data = CreativeServiceSession().getJob(
      searchParameter: query,
    );
  }

  @override
  void initState() {
    super.initState();
    search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  controller: text,
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    hintText: "搜索需求",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (String text) {
                    setState(() {
                      searchParameter = text;
                      search();
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: () async {
                  searchTags = await BothSideSheet.show<(String, List<String>)>(
                    context: context,
                    child: CategoryChoiceView(
                      data: searchTags ?? ("", []),
                    ),
                    title: "选择种类",
                  );
                  setState(() {
                    search();
                  });
                },
                child: const Text("职位类型"),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: search,
              child: FutureBuilder<List<Job>>(
                future: data,
                builder:
                    (BuildContext context, AsyncSnapshot<List<Job>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(child: Text("坏事: ${snapshot.error}"));
                    } else {
                      if ((snapshot.data?.length ?? 0) > 0) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: sheetMaxWidth),
                            child: ListView.separated(
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) =>
                                  CreativeJobListTile(
                                      job: snapshot.data![index]),
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(height: 0),
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: Text("没有查到结果"));
                      }
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreativeJobListTile extends StatelessWidget {
  final Job job;
  const CreativeJobListTile({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(job.name),
          TagsBoxes(
            text: job.skill,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2.0),
          Wrap(
            spacing: 8.0,
            children: List.generate(
              job.tags.length,
              (i) => TagsBoxes(
                text: job.tags[i],
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4.0,
            children: [
              Text(
                "招募 ${job.exceptNumber} 人 · ",
              ),
              Text(
                "${job.project.name} · ",
              ),
              Text(
                "截止日期 ${Jiffy.parseFromDateTime(job.endTime).format(pattern: "yyyy 年 MM 月 dd 日")}",
              ),
            ],
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreativeJobDescription(job: job),
        ),
      ),
    );
  }
}
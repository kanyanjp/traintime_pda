// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Setting window.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/setting/about_page/about_page.dart';
import 'package:watermeter/page/setting/dialogs/change_brightness_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/setting/dialogs/electricity_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';
import 'package:watermeter/themes/demo_blue.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({super.key});
  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  Widget _buildListSubtitle(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
          .padding(
            bottom: 8,
          )
          .center();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: Platform.isIOS || Platform.isMacOS
                        ? "XDYou"
                        : 'Traintime PDA',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: '\nWritten by BenderBlog Rodriguez and contributors',
                  ),
                ],
              ),
            ).padding(horizontal: 8.0),
            // 功能1
            const SizedBox(height: 20),
            ReXCard(
                title: _buildListSubtitle('关于'),
                remaining: const [],
                bottomRow: Column(
                  children: [
                    ListTile(
                      title: const Text("关于本程序"),
                      subtitle: Text(
                          '版本号：${preference.packageInfo.version}+${preference.packageInfo.buildNumber}'),
                      onTap: () => context.pushReplacement(const AboutPage()),
                      trailing: const Icon(Icons.navigate_next),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('用户信息'),
                      subtitle: Text(
                        "${preference.getString(preference.Preference.name)} ${preference.getString(preference.Preference.execution)}\n"
                        "${preference.getString(preference.Preference.institutes)} ${preference.getString(preference.Preference.subject)}",
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            // ReXCard(
            //   title: _buildListSubtitle('颜色设置'),
            //   remaining: [],
            //   bottomRow: Column(
            //     children: [
            //       ListTile(
            //           title: const Text('设置程序主题色'),
            //           subtitle: Text(ColorSeed
            //               .values[
            //                   preference.getInt(preference.Preference.color)]
            //               .label),
            //           onTap: () {
            //             showDialog(
            //               context: context,
            //               builder: (context) => const ChangeColorDialog(),
            //             );
            //           }),
            //     ],
            //   ),
            // ),
            ReXCard(
                title: _buildListSubtitle('主题设置'),
                remaining: const [],
                bottomRow: Column(children: [
                  ListTile(
                      title: const Text('设置深浅色'),
                      subtitle: Text(demoBlueModeName[
                          preference.getInt(preference.Preference.brightness)]),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const ChangeBrightnessDialog());
                      }),
                ])),
            ReXCard(
              title: _buildListSubtitle('帐号设置'),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                      title: const Text('体育系统密码设置'),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SportPasswordDialog(),
                        );
                      }),
                  const Divider(),
                  ListTile(
                      title: const Text('物理实验系统密码设置'),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const ExperimentPasswordDialog(),
                        );
                      }),
                  const Divider(),
                  ListTile(
                      title: const Text('电费帐号密码设置'),
                      subtitle: const Text('非 123456 请设置'),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const ElectricityPasswordDialog(),
                        );
                      }),
                ],
              ),
            ),
            ReXCard(
              title: _buildListSubtitle('课表相关设置'),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: const Text("开启课表背景图"),
                    trailing: Switch(
                      value:
                          preference.getBool(preference.Preference.decorated),
                      onChanged: (bool value) {
                        if (value == true &&
                            !preference
                                .getBool(preference.Preference.decoration)) {
                          Fluttertoast.showToast(msg: '你先选个图片罢，就在下面');
                        } else {
                          setState(() {
                            preference.setBool(
                                preference.Preference.decorated, value);
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('课表背景图选择'),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.image);
                      if (mounted) {
                        if (result != null) {
                          File(result.files.single.path!)
                              .copySync("${supportPath.path}/decoration.jpg");
                          preference.setBool(
                              preference.Preference.decoration, true);
                          if (mounted) {
                            Fluttertoast.showToast(msg: '设定成功');
                          }
                        } else {
                          Fluttertoast.showToast(msg: '你没有选图片捏');
                        }
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("清除所有用户添加课程"),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("确认对话框"),
                        content: const Text(
                          "是否要清除所有用户添加课程？"
                          "这个功能对从学校获取的日程没有影响。",
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              var file = File(
                                "${supportPath.path}/"
                                "${ClassTableFile.userDefinedClassName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }
                              Get.find<ClassTableController>()
                                  .updateClassTable();
                              Fluttertoast.showToast(msg: "已经清除完毕");
                              Navigator.pop(context);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("强制刷新课表"),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("确认对话框"),
                        content: const Text(
                          "是否要强制刷新课表？同意后，"
                          "将会从学校一站式后端重新获取课表，耗时会比较久。",
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.put(ClassTableController())
                                  .updateClassTable(isForce: true);
                              Navigator.pop(context);
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('课程偏移设置'),
                    subtitle: Text(
                      '正数错后开学日期 负数提前开学日期 '
                      '目前为 ${preference.getInt(preference.Preference.swift)}',
                    ),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChangeSwiftDialog(),
                      ).then((value) {
                        Get.put(ClassTableController()).updateCurrent();
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
            ReXCard(
              title: _buildListSubtitle('缓存登录设置'),
              remaining: const [],
              bottomRow: Column(
                children: [
                  ListTile(
                    title: const Text('查看网络拦截器和日志'),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => alice.showInspector(),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('清除缓存后重启'),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("确认对话框"),
                        content: const Text(
                          "确定清楚缓存后重启程序？",
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () async {
                              ProgressDialog pd =
                                  ProgressDialog(context: context);
                              pd.show(msg: "正在清理缓存");
                              try {
                                await NetworkSession().clearCookieJar();
                              } on PathNotFoundException {
                                log.d(
                                  "[setting][ClearAllCache]"
                                  "No cookies.",
                                );
                              }

                              /// Clean Classtable cache.
                              var file = File(
                                "${supportPath.path}/${ClassTableFile.schoolClassName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              file = File(
                                "${supportPath.path}/${ExamController.examDataCacheName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              file = File(
                                "${supportPath.path}/${ExperimentController.experimentCacheName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              if (mounted) {
                                Fluttertoast.showToast(msg: '缓存已被清除');
                                Restart.restartApp();
                              }
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('退出登录并重启应用'),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("确认对话框"),
                        content: const Text(
                          "确定退出登录？你的所有数据将会被彻底删除！",
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () async {
                              ProgressDialog pd =
                                  ProgressDialog(context: context);
                              pd.show(msg: '正在退出登录');

                              /// Clean Cookie
                              try {
                                await NetworkSession().clearCookieJar();
                                // I don't care.
                                // ignore: empty_catches
                              } on Exception {}

                              /// Clean Classtable cache.
                              var file = File(
                                "${supportPath.path}/${ClassTableFile.schoolClassName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              file = File(
                                "${supportPath.path}/${ClassTableFile.userDefinedClassName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              file = File(
                                "${supportPath.path}/${ExamController.examDataCacheName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              file = File(
                                "${supportPath.path}/${ExperimentController.experimentCacheName}",
                              );
                              if (file.existsSync()) {
                                file.deleteSync();
                              }

                              /// Clean user information
                              await preference.prefrenceClear();

                              /// Theme back to default
                              ThemeController toChange =
                                  Get.put(ThemeController());
                              toChange.onUpdate();

                              /// Restart app
                              if (mounted) {
                                pd.close();
                                Restart.restartApp();
                              }
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).constrained(maxWidth: 600).center(),
      ),
    );
  }
}

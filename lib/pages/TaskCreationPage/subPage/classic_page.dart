import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/theme/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ClassicPage extends ConsumerStatefulWidget {
  const ClassicPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClassicPageState();
}

class _ClassicPageState extends ConsumerState<ClassicPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('任务标题'),
        SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          //child: customTextField(hintText: '任务标题'),
          child: TextField(
            decoration: InputDecoration(
              hintText: '任务标题',
              border: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(64),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.base),
        SizedBox(
          width: double.infinity,
          child: TextField(
            decoration: InputDecoration(
              hintText: '任务描述',
              border: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
            ),
            maxLines: 5,
          ),
        ),
        SizedBox(height: AppSpacing.base),
        GlassCard(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('截止时间'),
                    Spacer(),
                    CupertinoTimePickerButton(), //TODO: 数据获取
                  ],
                ),
                GlassDivider(),
                Row(
                  children: [
                    Text('预计耗时'),
                    Spacer(),
                    CupertinoTimePickerButton(), //TODO: 数据获取
                  ],
                ),
                GlassDivider(),
                Row(
                  children: [
                    Text('优先级'),
                    SizedBox(width: AppSpacing.base),
                    SizedBox(
                      width: 200, // Set a fixed width for the segmented control
                      child: GlassSegmentedControl(
                        onSegmentSelected: (_) {},
                        selectedIndex: 0,
                        segments: [
                          GlassSegment(label: '无'),
                          GlassSegment(label: '低'),
                          GlassSegment(label: '中'),
                          GlassSegment(label: '高'),
                        ],
                      ),
                    ),
                  ],
                ),
                GlassDivider(),
                Row(
                  children: [
                    Text('项目'),
                    Spacer(),
                    GlassButton(onTap: () {}, icon: null, label: '请选择项目'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

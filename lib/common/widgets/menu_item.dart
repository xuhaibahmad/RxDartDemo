import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    Key? key,
    this.assetName,
    required this.title,
    required this.onPressed,
    this.padding,
    this.trailing,
  }) : super(key: key);

  final String? assetName;
  final String title;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
      child: Container(
        padding: padding ?? EdgeInsets.only(top: 16.h, bottom: 18.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: assetName != null
                      ? EdgeInsets.only(left: 20.w)
                      : EdgeInsets.zero,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
              trailing ?? Container(),
            ],
          ),
        ),
      ),
    );
  }

  factory MenuItemWidget.arrow({
    required BuildContext context,
    String? assetName,
    required String title,
    required VoidCallback onPressed,
  }) {
    return MenuItemWidget(
      assetName: assetName,
      title: title,
      onPressed: onPressed,
      trailing: Icon(
        Icons.arrow_forward_ios_sharp,
        size: 16.w,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

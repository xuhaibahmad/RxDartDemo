import './custom_alert_dialog_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.controlWidgets,
    this.height,
    this.onWillPop,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final List<Widget> controlWidgets;
  final double? height;
  final WillPopCallback? onWillPop;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Center(
        child: SingleChildScrollView(
          child: Dialog(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 26.h),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Row(
                      children: controlWidgets,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  factory CustomAlertDialog.unableToOpenLink({
    required BuildContext context,
  }) {
    return CustomAlertDialog(
      title: AppLocalizations.of(context)!.linkErrorAlertTitle,
      subtitle: AppLocalizations.of(context)!.linkErrorAlertSubtitle,
      height: 240.h,
      controlWidgets: [
        Expanded(
          child: ElevatedButton(
            child: Text(AppLocalizations.of(context)!.linkErrorAlertButton),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

Future<T?> showCustomAlertDialog<T>({
  required BuildContext context,
  required CustomAlertDialogUiModel uiModel,
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: uiModel.title,
        subtitle: uiModel.subtitle,
        controlWidgets: [
          Expanded(
            child: ElevatedButton(
              onPressed: uiModel.onButtonPressed,
              child: Text(uiModel.buttonTitle),
            ),
          ),
        ],
      );
    },
  );
}

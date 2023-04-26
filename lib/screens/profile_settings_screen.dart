import '../common/widgets/custom_alert_dialog/custom_alert_dialog.dart';
import '../common/widgets/loading_dialog.dart';
import '../common/widgets/menu_item.dart';
import '../data/provider/profile_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  static const routeName = '/profileSettingsScreen';

  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProviderListener<Object?>(
          provider: profileSettingsShowRemoveWalletDialogProvider,
          onChange: (context, _) {
            _showWarningDialog(context);
          },
          child: Container(),
        ),
        ProviderListener<Object?>(
          provider: profileSettingsShowLoadingDialogProvider,
          onChange: (context, action) {
            if (action != null) {
              Navigator.of(context)
                  .popUntil((route) => route is! RawDialogRoute);
              showLoadingDialog(context, null);
            }
          },
          child: Container(),
        ),
        Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 12.h, left: 16.w, right: 16.w, bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.profileSettingsTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(top: 24.h),
                      children: [
                        Consumer(builder: (context, watch, _) {
                          final title = watch(
                              profileSettingsSwitchBiometricTitleProvider(
                                  context));
                          final value = watch(
                              profileSettingsSwitchBiometricValueProvider);
                          return MenuItemWidget(
                            title: title,
                            onPressed: () {
                              context
                                  .read(profileSettingsProvider)
                                  .switchBiometric();
                            },
                            padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                            trailing: value != null
                                ? Switch(
                                    onChanged: (_) {
                                      context
                                          .read(profileSettingsProvider)
                                          .switchBiometric();
                                    },
                                    value: value,
                                  )
                                : Container(),
                          );
                        }),
                        MenuItemWidget(
                          title: AppLocalizations.of(context)!
                              .profileSettingsItemRate,
                          onPressed: () {},
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'USD',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 15.w,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 48.h),
                          child: Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .profileSettingsRemoveButton,
                                ),
                                onPressed: () {
                                  context
                                      .read(profileSettingsProvider)
                                      .removeWallet();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog<CustomAlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: AppLocalizations.of(context)!.profileSettingsRemoveAlertTitle,
          subtitle:
              AppLocalizations.of(context)!.profileSettingsRemoveAlertSubtitle,
          height: 360.h,
          controlWidgets: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton(
                    child: Text(
                      AppLocalizations.of(context)!
                          .profileSettingsRemoveAlertCancelButton,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  Container(
                    height: 12.h,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .profileSettingsRemoveAlertConfirmButton,
                    ),
                    onPressed: () async {
                      context
                          .read(profileSettingsProvider)
                          .removeWalletAccept();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

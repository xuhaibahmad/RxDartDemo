import 'dart:io';

import 'app_provider.dart';
import '/data/provider/passcode/passcode_processing_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

final profileSettingsProvider = Provider.autoDispose<ProfileSettingsProvider>(
    (ref) => ProfileSettingsProvider(ref));

class ProfileSettingsProvider {
  ProfileSettingsProvider(this._ref) {
    _ref.onDispose(() {
      _removeWalletSubject.close();
      _switchBiometricSubject.close();
      _switchPasscodeSubject.close();
      _removeWalletAcceptSubject.close();
    });
  }

  final AutoDisposeProviderReference _ref;

  final PublishSubject<void> _removeWalletSubject = PublishSubject();
  void removeWallet() {
    _removeWalletSubject.add(null);
  }

  Stream<Object> _showRemoveWalletDialogStream() =>
      _removeWalletSubject.map((_) => Object());

  final PublishSubject<void> _removeWalletAcceptSubject = PublishSubject();
  void removeWalletAccept() {
    _removeWalletAcceptSubject.add(null);
  }

  late final Stream<AsyncValue<void>> _removeWalletAcceptStream = Rx.merge([
    _removeWalletAcceptSubject.switchMap((_) => Stream.value(_)
        .asyncMap((_) => _ref.read(appProvider).biometricEnabled())
        .map((_) => true)
        .onErrorReturn(false)
        .switchMap((biometricEnabled) => biometricEnabled
            ? Stream.value(null)
                .asyncMap((_) => _ref.read(appProvider).getMnemonic())
                .map((_) => Object())
                .onErrorResumeNext(const Stream.empty())
            : Stream.value(null)
                .asyncMap((_) => _ref.read(appProvider).passcodeEnabled())
                .map((_) => true)
                .onErrorReturn(false)
                .asyncMap<void>((passcodeEnabled) => passcodeEnabled
                    ? _handlePasscodeUnlockResultSubject
                        .switchMap((result) =>
                            result is PasscodeUnlockSuccessResult
                                ? Stream<void>.value(null)
                                : const Stream<void>.empty())
                        .first
                    : Future.value(null))
                .map((_) => Object())
                .onErrorResumeNext(const Stream.empty()))),
  ]).switchMap((_) {
    return Stream.value(_)
        .asyncMap((_) async => await _ref.read(appProvider).disconnect())
        .asyncMap((_) async => await _ref.read(appProvider).clearStorage())
        .doOnData((_) {
          _ref.read(appProvider).authorize();
        })
        .switchMap((_) => _ref.read(appProvider).authStream)
        .switchMap<void>((value) => value.maybeWhen(
              error: (_, __) => Stream.value(null),
              orElse: () => const Stream.empty(),
            ))
        .map((_) => AsyncValue.data(_))
        .startWith(const AsyncValue.loading())
        .onErrorReturnWith(
            (error, stackTrace) => AsyncValue.error(error, stackTrace));
  }).shareReplay(maxSize: 1);

  Stream<Object> showLoadingDialogStream() =>
      _removeWalletAcceptStream.switchMap((value) => value.maybeWhen(
            loading: () => Stream.value(Object()),
            orElse: () => const Stream.empty(),
          ));

  Stream<String> _biometricSwitchTitleStream(BuildContext context) =>
      Stream.value(null).map((_) {
        if (Platform.isAndroid) {
          return AppLocalizations.of(context)!.profileSettingsItemTouchId;
        } else if (Platform.isIOS) {
          return AppLocalizations.of(context)!.profileSettingsItemFaceId;
        } else {
          throw ProfileSettingsUnsupportedPlatformException();
        }
      }).onErrorResumeNext(const Stream.empty());

  final PublishSubject<void> _switchBiometricSubject = PublishSubject();
  void switchBiometric() {
    _switchBiometricSubject.add(null);
  }

  late final Stream<AsyncValue<bool>> _switchBiometricInitialValueStream =
      Stream.value(null)
          .asyncMap((_) => _ref.read(appProvider).biometricEnabled())
          .map((enabled) => const AsyncValue.data(true))
          .startWith(const AsyncValue.loading())
          .onErrorReturn(const AsyncValue.data(false))
          .shareReplay(maxSize: 1);

  late final Stream<AsyncValue<void>> _biometricProccessingStream =
      _switchBiometricSubject
          .switchMap((_) => Stream.value(null)
              .asyncMap((event) => _ref.read(appProvider).biometricEnabled())
              .map((_) => true)
              .onErrorReturn(false)
              .asyncMap((enabled) => enabled
                  ? Stream.value(null)
                      .asyncMap((mnemonic) =>
                          _ref.read(appProvider).disableBiometric())
                      .first
                  : Stream.value(null)
                      .asyncMap((_) => _ref.read(appProvider).passcodeEnabled())
                      .map((_) => true)
                      .onErrorReturn(false)
                      .asyncMap<void>((passcodeEnabled) => passcodeEnabled
                          ? _handlePasscodeUnlockResultSubject
                              .switchMap((result) => result is PasscodeUnlockSuccessResult
                                  ? Stream<void>.value(null)
                                  : const Stream<void>.empty())
                              .first
                          : Future.value(null))
                      .asyncMap((_) => _ref.read(appProvider).enableBiometric())
                      .first)
              .map((_) => AsyncValue.data(_))
              .startWith(const AsyncValue.loading())
              .onErrorReturnWith(
                  (error, stackTrace) => AsyncValue.error(error, stackTrace)))
          .shareReplay(maxSize: 1);

  Stream<bool> _switchBiometricEnabled() =>
      _switchBiometricInitialValueStream.switchMap((value) => value.maybeWhen(
            data: (initiallyEnabled) => Rx.merge([
              _biometricProccessingStream,
              _passcodeProccessingStream,
            ])
                .switchMap((value) => value.maybeWhen(
                      loading: () => const Stream<bool>.empty(),
                      orElse: () => Stream.value(null)
                          .asyncMap(
                              (_) => _ref.read(appProvider).biometricEnabled())
                          .map((_) => true)
                          .onErrorReturn(false),
                    ))
                .startWith(initiallyEnabled),
            orElse: () => const Stream<bool>.empty(),
          ));

  final PublishSubject<void> _switchPasscodeSubject = PublishSubject();
  void switchPasscode() {
    _switchPasscodeSubject.add(null);
  }

  late final Stream<AsyncValue<String>> _fallbackMnemonicStream =
      _switchPasscodeSubject
          .switchMap((_) => Stream.value(_)
              .asyncMap((event) => _ref.read(appProvider).getMnemonic())
              .map((mnemonic) => AsyncValue.data(mnemonic))
              .startWith(const AsyncValue.loading())
              .onErrorReturnWith(
                  (error, stackTrace) => AsyncValue.error(error, stackTrace)))
          .shareReplay(maxSize: 1);

  Stream<Object> _showPasscodeEnableStream() =>
      _fallbackMnemonicStream.switchMap((value) => value.maybeWhen(
            data: (_) => Stream.value(_)
                .asyncMap((_) => _ref.read(appProvider).passcodeEnabled())
                .switchMap((_) => const Stream<Object>.empty())
                .onErrorReturn(Object()),
            orElse: () => const Stream.empty(),
          ));

  final PublishSubject<Object?> _handlePasscodeUnlockResultSubject =
      PublishSubject();
  void handlePasscodeUnlockResult(Object? result) {
    _handlePasscodeUnlockResultSubject.add(result);
  }

  Stream<Object> _showPasscodeLockStream() => Rx.merge([
        _switchBiometricSubject,
        _switchPasscodeSubject,
        _removeWalletAcceptSubject,
        _handlePasscodeUnlockResultSubject.switchMap((result) =>
            result is PasscodeUnlockFailureResult
                ? Stream<void>.value(null)
                : const Stream<void>.empty()),
      ]).switchMap((_) => Stream.value(_)
          .asyncMap((event) => _ref.read(appProvider).passcodeEnabled())
          .map((_) => Object())
          .onErrorResumeNext(const Stream<Object>.empty()));

  late final Stream<AsyncValue<bool>> _switchPasscodeInitialValueStream =
      Stream.value(null)
          .asyncMap((_) => _ref.read(appProvider).passcodeEnabled())
          .map((_) => const AsyncValue.data(true))
          .startWith(const AsyncValue.loading())
          .onErrorReturn(const AsyncValue.data(false))
          .shareReplay(maxSize: 1);

  final PublishSubject<String> _enablePasscodeSubject = PublishSubject();
  void enablePasscode(String passcode) {
    _enablePasscodeSubject.add(passcode);
  }

  late final Stream<AsyncValue<void>> _passcodeProccessingStream = _switchPasscodeSubject
      .switchMap((_) => Stream.value(_)
          .asyncMap((_) => _ref.read(appProvider).passcodeEnabled())
          .map((_) => true)
          .onErrorReturn(false)
          .asyncMap((enabled) => enabled
              ? _handlePasscodeUnlockResultSubject
                  .switchMap((result) => result is PasscodeUnlockSuccessResult
                      ? Stream<void>.value(null)
                      : const Stream<void>.empty())
                  .asyncMap((event) => _ref.read(appProvider).disablePasscode())
                  .first
              : _fallbackMnemonicStream
                  .switchMap((value) => value.maybeWhen(
                      data: (_) => _enablePasscodeSubject.asyncMap((passcode) =>
                          _ref.read(appProvider).enablePasscode(passcode)),
                      orElse: () => const Stream<void>.empty()))
                  .first)
          .map((_) => AsyncValue.data(_))
          .startWith(const AsyncValue.loading())
          .onErrorReturnWith(
              (error, stackTrace) => AsyncValue.error(error, stackTrace)))
      .shareReplay(maxSize: 1);

  Stream<bool> _switchPasscodeEnabled() =>
      _switchPasscodeInitialValueStream.switchMap((value) => value.maybeWhen(
            data: (initiallyEnabled) => Rx.merge([
              _biometricProccessingStream,
              _passcodeProccessingStream,
            ])
                .switchMap((value) => value.maybeWhen(
                      loading: () => const Stream<bool>.empty(),
                      orElse: () => Stream.value(null)
                          .asyncMap(
                              (_) => _ref.read(appProvider).passcodeEnabled())
                          .map((_) => true)
                          .onErrorReturn(false),
                    ))
                .startWith(initiallyEnabled),
            orElse: () => const Stream<bool>.empty(),
          ));
}

final _profileSettingsShowRemoveWalletDialogStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._showRemoveWalletDialogStream();
});

final profileSettingsShowRemoveWalletDialogProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref
      .watch(_profileSettingsShowRemoveWalletDialogStreamProvider)
      .data
      ?.value;
});

final _profileSettingsRemoveWalletAcceptStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._removeWalletAcceptStream;
});

final profileSettingsRemoveWalletAcceptProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref
      .watch(_profileSettingsRemoveWalletAcceptStreamProvider)
      .data
      ?.value;
});

final _profileSettingsSwitchPasscodeValueStreamProvider =
    StreamProvider.autoDispose<bool>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._switchPasscodeEnabled();
});

final profileSettingsSwitchPasscodeValueProvider =
    Provider.autoDispose<bool?>((ref) {
  return ref
      .watch(_profileSettingsSwitchPasscodeValueStreamProvider)
      .data
      ?.value;
});

final _profileSettingsSwitchBiometricTitleStreamProvider = StreamProvider.family
    .autoDispose<String, BuildContext>((ref, context) async* {
  yield* ref
      .watch(profileSettingsProvider)
      ._biometricSwitchTitleStream(context);
});

final profileSettingsSwitchBiometricTitleProvider =
    Provider.family.autoDispose<String, BuildContext>((ref, context) {
  return ref
          .watch(_profileSettingsSwitchBiometricTitleStreamProvider(context))
          .data
          ?.value ??
      '';
});

final _profileSettingsSwitchBiometricValueStreamProvider =
    StreamProvider.autoDispose<bool>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._switchBiometricEnabled();
});

final profileSettingsSwitchBiometricValueProvider =
    Provider.autoDispose<bool?>((ref) {
  return ref
      .watch(_profileSettingsSwitchBiometricValueStreamProvider)
      .data
      ?.value;
});

final _profileSettingsShowPasscodeEnableStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._showPasscodeEnableStream();
});

final profileSettingsShowPasscodeEnableProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref
      .watch(_profileSettingsShowPasscodeEnableStreamProvider)
      .data
      ?.value;
});

final _profileSettingsShowPasscodeLockStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileSettingsProvider)._showPasscodeLockStream();
});

final profileSettingsShowPasscodeLockProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref.watch(_profileSettingsShowPasscodeLockStreamProvider).data?.value;
});

final _profileSettingsShowLoadingDialogStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileSettingsProvider).showLoadingDialogStream();
});

final profileSettingsShowLoadingDialogProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref.watch(_profileSettingsShowLoadingDialogStreamProvider).data?.value;
});

class ProfileSettingsUnsupportedPlatformException implements Exception {}

class ProfileSettingsInvalidMnemonicException implements Exception {}

class ProfileSettingsBiometricFailureException implements Exception {}

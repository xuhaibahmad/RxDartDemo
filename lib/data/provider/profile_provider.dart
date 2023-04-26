import 'app_provider.dart';
import '/data/provider/passcode/passcode_processing_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

final profileProvider =
    Provider.autoDispose<ProfileProvider>((ref) => ProfileProvider(ref));

class ProfileProvider {
  ProfileProvider(this.ref) {
    ref.onDispose(() {
      _openLinkSubject.close();
      _handlePasscodeUnlockResultSubject.close();
    });
  }

  final AutoDisposeProviderReference ref;

  final PublishSubject<String> _openLinkSubject = PublishSubject();
  late final Stream<AsyncValue<void>> _processLinkOpeningStream =
      _openLinkSubject
          .switchMap((link) => Stream.value(null)
              .asyncMap((_) => canLaunch(link))
              .asyncMap((result) async {
                if (!result) {
                  throw ProfileUnableToLaunchLinkException();
                }
                return;
              })
              .asyncMap((_) => launch(link))
              .asyncMap((result) async {
                if (!result) {
                  throw ProfileUnableToLaunchLinkException();
                }
                return;
              })
              .map((data) => AsyncValue.data(data))
              .startWith(const AsyncValue.loading())
              .onErrorReturnWith(
                  (error, stackTrace) => AsyncValue.error(error, stackTrace)))
          .shareReplay(maxSize: 1);

  void openLink(String link) {
    _openLinkSubject.add(link);
  }

  final PublishSubject<void> _openRecoveryPhraseSubject = PublishSubject();
  void openRecoveryPhrase() {
    _openRecoveryPhraseSubject.add(null);
  }

  final PublishSubject<Object?> _handlePasscodeUnlockResultSubject =
      PublishSubject();
  void handlePasscodeUnlockResult(Object? result) {
    _handlePasscodeUnlockResultSubject.add(result);
  }

  Stream<Object> _showRecoveryPhraseLockStream() => Rx.merge([
        _openRecoveryPhraseSubject.switchMap((_) => Stream.value(_)
            .asyncMap((_) => ref.read(appProvider).passcodeEnabled())
            .map((_) => Object())
            .onErrorResumeNext(const Stream<Object>.empty())),
        _handlePasscodeUnlockResultSubject.switchMap((result) =>
            (result is PasscodeUnlockFailureResult)
                ? Stream.value(Object())
                : const Stream<Object>.empty()),
      ]);

  Stream<Object> _showRecoveryPhraseStream() => Rx.merge([
        _openRecoveryPhraseSubject.switchMap((_) => Stream.value(_)
            .asyncMap((_) => ref.read(appProvider).biometricEnabled())
            .map((_) => true)
            .onErrorReturn(false)
            .switchMap((biometricEnabled) => biometricEnabled
                ? Stream.value(null)
                    .asyncMap((_) => ref.read(appProvider).getMnemonic())
                    .map((_) => Object())
                    .onErrorResumeNext(const Stream.empty())
                : Stream.value(null)
                    .asyncMap((_) => ref.read(appProvider).passcodeEnabled())
                    .switchMap((_) => const Stream<Object>.empty())
                    .onErrorReturn(Object()))),
        _handlePasscodeUnlockResultSubject.switchMap((result) =>
            (result is PasscodeUnlockSuccessResult)
                ? Stream.value(Object())
                : const Stream<Object>.empty()),
      ]);
}

final _profileProcessLinkOpeningStreamProvider =
    StreamProvider.autoDispose<AsyncValue<void>>((ref) async* {
  yield* ref.watch(profileProvider)._processLinkOpeningStream;
});

final profileProcessLinkOpeningProvider =
    Provider.autoDispose<AsyncValue<void>?>((ref) {
  return ref.watch(_profileProcessLinkOpeningStreamProvider).data?.value;
});

final _profileShowRecoveryPhraseLockStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileProvider)._showRecoveryPhraseLockStream();
});

final profileShowRecoveryPhraseLockProvider =
    Provider.autoDispose<Object?>((ref) {
  return ref.watch(_profileShowRecoveryPhraseLockStreamProvider).data?.value;
});

final _profileShowRecoveryPhraseStreamProvider =
    StreamProvider.autoDispose<Object>((ref) async* {
  yield* ref.watch(profileProvider)._showRecoveryPhraseStream();
});

final profileShowRecoveryPhraseProvider = Provider.autoDispose<Object?>((ref) {
  return ref.watch(_profileShowRecoveryPhraseStreamProvider).data?.value;
});

class ProfileUnableToLaunchLinkException implements Exception {}

class ProfileInvalidBiometricMnemonicException implements Exception {}

class ProfileBiometricEncryptionException implements Exception {}

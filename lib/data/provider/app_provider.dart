import 'package:rxdartdemo/common/utils/custom_logger.dart';
import 'package:rxdartdemo/data/backend/lib_gdk.dart';;
import 'package:rxdartdemo/data/provider/bitcoin_provider.dart';
import 'package:rxdartdemo/data/provider/liquid_provider.dart';
import 'package:rxdartdemo/data/provider/network_frontend.dart';
import 'package:rxdartdemo/data/provider/sideshift/sideshift_order_provider.dart';
import 'package:rxdartdemo/data/provider/sqlite_database/sqlite_database_provider.dart';
import 'package:rxdartdemo/utils/extensions/iterable_ext.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final appProvider = Provider<AppProvider>((ref) => AppProvider(ref));

class AppProvider {
  AppProvider(
    this.ref,
  );

  final ProviderReference ref;
  final bool runTestCode = false;
  static const _channel = MethodChannel('io.wallet/protection');

  final PublishSubject<void> _startAuthSubject = PublishSubject();
  late final Stream<void> _startAuthStream = _startAuthSubject.switchMap((_) =>
      authStream.first.asStream().switchMap<void>((value) => value.maybeWhen(
            loading: () => const Stream.empty(),
            orElse: () => Stream.value(null),
          )));

  late final Stream<AsyncValue<String>> mnemonicStringStream = _startAuthStream
      .startWith(null)
      .switchMap((_) => Stream.value(_)
          .asyncMap((_) => getMnemonic())
          .map((mnemonic) => AsyncValue.data(mnemonic))
          .startWith(const AsyncValue.loading())
          .onErrorReturnWith(
              (error, stackTrace) => AsyncValue.error(error, stackTrace)))
      .shareReplay(maxSize: 1);

  late final Stream<AsyncValue<void>> authStream = mnemonicStringStream
      .switchMap((value) => value.when(
            data: (mnemonic) => Stream.value(mnemonic)
                .asyncMap((_) async => await disconnect())
                .asyncMap((_) => Rx.zipList([
                      Stream.value(null)
                          .asyncMap((_) async =>
                              await ref.read(liquidProvider).connect())
                          .asyncMap((_) async {
                            return GdkLoginCredentials(mnemonic: mnemonic);
                          })
                          .asyncMap((credentials) => ref
                              .read(liquidProvider)
                              .loginUser(credentials: credentials))
                          .asyncMap<void>((id) async {
                            if (id == null || id.isEmpty) {
                              throw AppProviderLiquidAuthFailureException();
                            }
                            return;
                          }),
                      Stream.value(null)
                          .asyncMap((_) async =>
                              await ref.read(bitcoinProvider).connect())
                          .asyncMap((_) async {
                            return GdkLoginCredentials(mnemonic: mnemonic);
                          })
                          .asyncMap((credentials) => ref
                              .read(bitcoinProvider)
                              .loginUser(credentials: credentials))
                          .asyncMap<void>((id) async {
                            if (id == null || id.isEmpty) {
                              throw AppProviderBitcoinAuthFailureException();
                            }
                            return;
                          }),
                    ]).first)
                .map<AsyncValue<void>>((_) => const AsyncValue.data(null))
                .startWith(const AsyncValue.loading())
                .onErrorReturnWith(
                    (error, stackTrace) => AsyncValue.error(error, stackTrace)),
            loading: () => Stream.value(const AsyncValue<void>.loading()),
            error: (error, stackTrace) =>
                Stream.value(AsyncValue<void>.error(error, stackTrace)),
          ))
      .shareReplay(maxSize: 1);

  void authorize() {
    _startAuthSubject.add(null);
  }

  Future<void> disconnect() => Rx.zipList([
        Stream.value(null).asyncMap(
            (event) async => await ref.read(liquidProvider).disconnect()),
        Stream.value(null).asyncMap(
            (event) async => await ref.read(bitcoinProvider).disconnect()),
      ]).asyncMap<void>((_) {
        return null;
      }).first;

  Future<void> skipProtection() =>
      _channel.invokeMethod<void>('skipProtection');
  Future<void> getProtectionSkipped() =>
      _channel.invokeMethod<void>('getProtectionSkipped');
  Future<String> getMnemonic() =>
      _channel.invokeMethod<String?>('getMnemonic').then((value) async {
        if (value == null) {
          throw AppProviderInvalidMnemonicException();
        }
        return value;
      });
  Future<void> setMnemonic(String mnemonic) =>
      _channel.invokeMethod<void>('setMnemonic', {'mnemonic': mnemonic});
  Future<String?> getPasscode() =>
      _channel.invokeMethod<String?>('getPasscode');
  Future<void> passcodeEnabled() => getPasscode().then((_) async {
        return;
      });
  Future<void> enablePasscode(String passcode) =>
      _channel.invokeMethod<void>('enablePasscode', {'passcode': passcode});
  Future<void> disablePasscode() =>
      _channel.invokeMethod<void>('disablePasscode');
  Future<void> canAuthenticate() =>
      _channel.invokeMethod<void>('canAuthenticate');
  Future<void> biometricEnabled() =>
      _channel.invokeMethod<void>('getBiometricEnabled');
  Future<void> enableBiometric() =>
      _channel.invokeMethod<void>('enableBiometric');
  Future<void> disableBiometric() =>
      _channel.invokeMethod<void>('disableBiometric');
  Future<bool?> requiresBackup() =>
      _channel.invokeMethod<bool>('requiresBackup');
  Future<void> ignoreBackup() => _channel.invokeMethod<void>('ignoreBackup');
  Future<void> clearStorage() => _channel.invokeMethod<void>('clearStorage');
  Future<void> setEnv(String env) =>
      _channel.invokeMethod<void>('setEnv', {'env': env});
  Future<String?> getEnv() => _channel.invokeMethod<String?>('getEnv');
  Future<bool?> tutorialEnabled() =>
      _channel.invokeMethod<bool>('getTutorialEnabled');
  Future<void> enableTutorial() =>
      _channel.invokeMethod<void>('enableTutorial');
  Future<void> disableTutorial() =>
      _channel.invokeMethod<void>('disableTutorial');

  Future<List<Asset>> _bitcoinAssets() =>
      ref.read(bitcoinProvider).getBalance().then((balances) async {
        final btcBalance = balances?['btc'] as int;
        return [
          Asset(
            assetId: 'btc',
            amount: btcBalance,
            name: 'Bitcoin',
            ticker: 'BTC',
            precision: 8,
            isLBTC: false,
            isUSDt: false,
          )
        ];
      });

  Future<List<Asset>> liquidAssetsWithBalance() {
    return Stream.value(null)
        .asyncMap((_) => gdkRawAssets())
        .asyncMap((gdkAssets) {
      return ref.read(liquidProvider).getBalance().then((balances) {
        return Stream.fromIterable(balances?.keys ?? <String>[]).flatMap((key) {
          return Stream.value(key).switchMap((key) {
            final gdkAsset = gdkAssets?[key];
            if (gdkAsset != null) {
              return Stream.value(gdkAsset);
            } else {
              return const Stream<GdkAssetInformation>.empty();
            }
          }).asyncMap((gdkAsset) {
            return Stream.value(key).switchMap((key) {
              dynamic balance = balances?[key];
              if (balance is int) {
                return Stream.value(balance);
              } else {
                return const Stream<int>.empty();
              }
            }).asyncMap((balance) {
              return _buildLiquidAsset(gdkAsset, balance: balance);
            }).first;
          });
        }).toList();
      }).then((assets) {
        assets.sort((a, b) => a.name.compareTo(b.name));
        return assets;
      });
    }).first;
  }

  Future<Map<String, GdkAssetInformation>?> gdkRawAssets() => authStream
      .switchMap<void>((value) => value.maybeWhen(
            data: (_) => Stream.value(null),
            orElse: () => const Stream.empty(),
          ))
      .asyncMap((_) => ref.read(liquidProvider).refreshAssets())
      .first;

  Future<Asset?> liquidAssetById(String id) =>
      gdkRawAssets().then((gdkAssets) => gdkAssets?[id]).then((gdkAsset) =>
          gdkAsset != null ? _buildLiquidAsset(gdkAsset) : Future.value(null));

  Future<GdkAssetInformation?> gdkRawAssetForAssetId(String assetId) {
    return Stream.value(null).asyncMap((_) async {
      return gdkRawAssets();
    }).map((gdkAssets) {
      return gdkAssets?.values ?? <GdkAssetInformation>[];
    }).asyncMap((gdkAssets) async {
      if (gdkAssets.any((asset) => asset.assetId == assetId)) {
        return gdkAssets.firstWhere((asset) => asset.assetId == assetId);
      }

      return null;
    }).first;
  }

  Stream<List<Asset>> walletAssets() => Rx.combineLatestList([
        Stream.value(null)
            .switchMap((_) => ref
                .read(bitcoinProvider)
                .transactionEventSubject
                .startWith(null)
                .asyncMap((_) => ref.read(bitcoinProvider).getTransactions()))
            .startWith([]).asyncMap((_) => _bitcoinAssets()),
        Stream.value(null).asyncMap((_) => gdkRawAssets()).switchMap((gdkAssets) => ref
            .read(liquidProvider)
            .transactionEventSubject
            .startWith(null)
            .asyncMap((_) => ref.read(liquidProvider).getTransactions())
            .asyncMap((transactions) => liquidAssetsWithBalance().then(
                (assetsWithBalances) => Stream.value(transactions)
                    .map((transactions) => transactions
                        ?.map((transaction) => transaction.satoshi?.keys ?? [])
                        .expand((key) => key)
                        .toSet())
                    .map((transactionKeys) {
                      final assetsWithBalancesKeys = assetsWithBalances
                          .map((asset) => asset.assetId)
                          .toSet();
                      return transactionKeys
                              ?.difference(assetsWithBalancesKeys) ??
                          {};
                    })
                    .asyncMap((excludedTransactionKeys) => Stream.fromIterable(
                            excludedTransactionKeys)
                        .flatMap((key) => Stream.value(key).switchMap((key) {
                              final gdkAsset = gdkAssets?[key];
                              if (gdkAsset != null) {
                                return Stream.value(gdkAsset);
                              } else {
                                return const Stream<
                                    GdkAssetInformation>.empty();
                              }
                            }).asyncMap((gdkAsset) => _buildLiquidAsset(gdkAsset)))
                        .toList())
                    .map((assetsInTransactions) => assetsWithBalances + assetsInTransactions)
                    .first))),
        Stream.value(null)
            .asyncMap((_) => liquidAssetsWithBalance())
            .switchMap((assets) => assets.any((asset) => asset.isUSDt)
                ? Stream<List<Asset>>.value([])
                : Stream.value(null)
                    .asyncMap((_) => gdkRawAssets())
                    .switchMap((gdkAssets) {
                      final gdkAsset = gdkAssets?[usdtAssetId];
                      if (gdkAsset != null) {
                        return Stream.value(gdkAsset);
                      } else {
                        return const Stream<GdkAssetInformation>.empty();
                      }
                    })
                    .asyncMap((gdkAsset) => _buildLiquidAsset(gdkAsset))
                    .map((asset) => [asset])),
        Stream.value(null).asyncMap((_) => gdkRawAssets()).switchMap(
            (gdkAssets) => ref
                .read(sqliteDatabaseProvider)
                .assetsStream()
                .asyncMap((favorites) => Stream.fromIterable(favorites)
                    .map((favorite) => gdkAssets?[favorite])
                    .switchMap((gdkAsset) => gdkAsset != null
                        ? Stream.value(gdkAsset)
                        : const Stream<GdkAssetInformation>.empty())
                    .asyncMap((gdkAsset) => _buildLiquidAsset(gdkAsset))
                    .toList()))
      ])
          .map((data) =>
              data.expand((_) => _).distinctBy((asset) => asset.assetId))
          .map((assets) => assets.sorted((a, b) {
                if (a.isBTC) {
                  return -1;
                } else if (b.isBTC) {
                  return 1;
                } else if (a.isLBTC) {
                  return -1;
                } else if (b.isLBTC) {
                  return 1;
                } else if (a.isUSDt) {
                  return -1;
                } else if (b.isUSDt) {
                  return 1;
                } else if (a.amount > 0) {
                  return -1;
                } else if (b.amount > 0) {
                  return 1;
                }
                return a.name.compareTo(b.name);
              }));
}

class AppProviderUnathorizedException implements Exception {}

class AppProviderInvalidMnemonicException implements Exception {}

class AppProviderBiometricFailureException implements Exception {}

class AppProviderLiquidAuthFailureException implements Exception {}

class AppProviderBitcoinAuthFailureException implements Exception {}

class AppProviderAssetForAssetIdEmptyException implements Exception {}

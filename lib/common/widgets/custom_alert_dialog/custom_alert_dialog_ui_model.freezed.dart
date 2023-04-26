// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'custom_alert_dialog_ui_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CustomAlertDialogUiModel {
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  String get buttonTitle => throw _privateConstructorUsedError;
  VoidCallback get onButtonPressed => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CustomAlertDialogUiModelCopyWith<CustomAlertDialogUiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomAlertDialogUiModelCopyWith<$Res> {
  factory $CustomAlertDialogUiModelCopyWith(CustomAlertDialogUiModel value,
          $Res Function(CustomAlertDialogUiModel) then) =
      _$CustomAlertDialogUiModelCopyWithImpl<$Res>;
  $Res call(
      {String title,
      String subtitle,
      String buttonTitle,
      VoidCallback onButtonPressed});
}

/// @nodoc
class _$CustomAlertDialogUiModelCopyWithImpl<$Res>
    implements $CustomAlertDialogUiModelCopyWith<$Res> {
  _$CustomAlertDialogUiModelCopyWithImpl(this._value, this._then);

  final CustomAlertDialogUiModel _value;
  // ignore: unused_field
  final $Res Function(CustomAlertDialogUiModel) _then;

  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? buttonTitle = freezed,
    Object? onButtonPressed = freezed,
  }) {
    return _then(_value.copyWith(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: subtitle == freezed
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      buttonTitle: buttonTitle == freezed
          ? _value.buttonTitle
          : buttonTitle // ignore: cast_nullable_to_non_nullable
              as String,
      onButtonPressed: onButtonPressed == freezed
          ? _value.onButtonPressed
          : onButtonPressed // ignore: cast_nullable_to_non_nullable
              as VoidCallback,
    ));
  }
}

/// @nodoc
abstract class _$$_CustomAlertDialogUiModelCopyWith<$Res>
    implements $CustomAlertDialogUiModelCopyWith<$Res> {
  factory _$$_CustomAlertDialogUiModelCopyWith(
          _$_CustomAlertDialogUiModel value,
          $Res Function(_$_CustomAlertDialogUiModel) then) =
      __$$_CustomAlertDialogUiModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {String title,
      String subtitle,
      String buttonTitle,
      VoidCallback onButtonPressed});
}

/// @nodoc
class __$$_CustomAlertDialogUiModelCopyWithImpl<$Res>
    extends _$CustomAlertDialogUiModelCopyWithImpl<$Res>
    implements _$$_CustomAlertDialogUiModelCopyWith<$Res> {
  __$$_CustomAlertDialogUiModelCopyWithImpl(_$_CustomAlertDialogUiModel _value,
      $Res Function(_$_CustomAlertDialogUiModel) _then)
      : super(_value, (v) => _then(v as _$_CustomAlertDialogUiModel));

  @override
  _$_CustomAlertDialogUiModel get _value =>
      super._value as _$_CustomAlertDialogUiModel;

  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? buttonTitle = freezed,
    Object? onButtonPressed = freezed,
  }) {
    return _then(_$_CustomAlertDialogUiModel(
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: subtitle == freezed
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      buttonTitle: buttonTitle == freezed
          ? _value.buttonTitle
          : buttonTitle // ignore: cast_nullable_to_non_nullable
              as String,
      onButtonPressed: onButtonPressed == freezed
          ? _value.onButtonPressed
          : onButtonPressed // ignore: cast_nullable_to_non_nullable
              as VoidCallback,
    ));
  }
}

/// @nodoc

class _$_CustomAlertDialogUiModel implements _CustomAlertDialogUiModel {
  const _$_CustomAlertDialogUiModel(
      {required this.title,
      required this.subtitle,
      required this.buttonTitle,
      required this.onButtonPressed});

  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String buttonTitle;
  @override
  final VoidCallback onButtonPressed;

  @override
  String toString() {
    return 'CustomAlertDialogUiModel(title: $title, subtitle: $subtitle, buttonTitle: $buttonTitle, onButtonPressed: $onButtonPressed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CustomAlertDialogUiModel &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.subtitle, subtitle) &&
            const DeepCollectionEquality()
                .equals(other.buttonTitle, buttonTitle) &&
            (identical(other.onButtonPressed, onButtonPressed) ||
                other.onButtonPressed == onButtonPressed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(subtitle),
      const DeepCollectionEquality().hash(buttonTitle),
      onButtonPressed);

  @JsonKey(ignore: true)
  @override
  _$$_CustomAlertDialogUiModelCopyWith<_$_CustomAlertDialogUiModel>
      get copyWith => __$$_CustomAlertDialogUiModelCopyWithImpl<
          _$_CustomAlertDialogUiModel>(this, _$identity);
}

abstract class _CustomAlertDialogUiModel implements CustomAlertDialogUiModel {
  const factory _CustomAlertDialogUiModel(
          {required final String title,
          required final String subtitle,
          required final String buttonTitle,
          required final VoidCallback onButtonPressed}) =
      _$_CustomAlertDialogUiModel;

  @override
  String get title;
  @override
  String get subtitle;
  @override
  String get buttonTitle;
  @override
  VoidCallback get onButtonPressed;
  @override
  @JsonKey(ignore: true)
  _$$_CustomAlertDialogUiModelCopyWith<_$_CustomAlertDialogUiModel>
      get copyWith => throw _privateConstructorUsedError;
}

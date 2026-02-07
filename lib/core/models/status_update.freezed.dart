// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatusUpdate _$StatusUpdateFromJson(Map<String, dynamic> json) {
  return _StatusUpdate.fromJson(json);
}

/// @nodoc
mixin _$StatusUpdate {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // text, image, video
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'media_url')
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'background_color')
  String? get backgroundColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_color')
  String? get textColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_name')
  String? get contactName => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_avatar')
  String? get contactAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;
  bool get viewed => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt => throw _privateConstructorUsedError;

  /// Serializes this StatusUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusUpdateCopyWith<StatusUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusUpdateCopyWith<$Res> {
  factory $StatusUpdateCopyWith(
          StatusUpdate value, $Res Function(StatusUpdate) then) =
      _$StatusUpdateCopyWithImpl<$Res, StatusUpdate>;
  @useResult
  $Res call(
      {String id,
      String type,
      String? text,
      @JsonKey(name: 'media_url') String? mediaUrl,
      String? caption,
      @JsonKey(name: 'background_color') String? backgroundColor,
      @JsonKey(name: 'text_color') String? textColor,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_avatar') String? contactAvatar,
      @JsonKey(name: 'view_count') int viewCount,
      bool viewed,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'scheduled_at') DateTime? scheduledAt});
}

/// @nodoc
class _$StatusUpdateCopyWithImpl<$Res, $Val extends StatusUpdate>
    implements $StatusUpdateCopyWith<$Res> {
  _$StatusUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? text = freezed,
    Object? mediaUrl = freezed,
    Object? caption = freezed,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactAvatar = freezed,
    Object? viewCount = null,
    Object? viewed = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? scheduledAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactAvatar: freezed == contactAvatar
          ? _value.contactAvatar
          : contactAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewed: null == viewed
          ? _value.viewed
          : viewed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatusUpdateImplCopyWith<$Res>
    implements $StatusUpdateCopyWith<$Res> {
  factory _$$StatusUpdateImplCopyWith(
          _$StatusUpdateImpl value, $Res Function(_$StatusUpdateImpl) then) =
      __$$StatusUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String? text,
      @JsonKey(name: 'media_url') String? mediaUrl,
      String? caption,
      @JsonKey(name: 'background_color') String? backgroundColor,
      @JsonKey(name: 'text_color') String? textColor,
      @JsonKey(name: 'contact_name') String? contactName,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'contact_avatar') String? contactAvatar,
      @JsonKey(name: 'view_count') int viewCount,
      bool viewed,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt,
      @JsonKey(name: 'scheduled_at') DateTime? scheduledAt});
}

/// @nodoc
class __$$StatusUpdateImplCopyWithImpl<$Res>
    extends _$StatusUpdateCopyWithImpl<$Res, _$StatusUpdateImpl>
    implements _$$StatusUpdateImplCopyWith<$Res> {
  __$$StatusUpdateImplCopyWithImpl(
      _$StatusUpdateImpl _value, $Res Function(_$StatusUpdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? text = freezed,
    Object? mediaUrl = freezed,
    Object? caption = freezed,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactAvatar = freezed,
    Object? viewCount = null,
    Object? viewed = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? scheduledAt = freezed,
  }) {
    return _then(_$StatusUpdateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _value.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactAvatar: freezed == contactAvatar
          ? _value.contactAvatar
          : contactAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewed: null == viewed
          ? _value.viewed
          : viewed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusUpdateImpl implements _StatusUpdate {
  const _$StatusUpdateImpl(
      {required this.id,
      required this.type,
      this.text,
      @JsonKey(name: 'media_url') this.mediaUrl,
      this.caption,
      @JsonKey(name: 'background_color') this.backgroundColor,
      @JsonKey(name: 'text_color') this.textColor,
      @JsonKey(name: 'contact_name') this.contactName,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'contact_avatar') this.contactAvatar,
      @JsonKey(name: 'view_count') this.viewCount = 0,
      this.viewed = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'scheduled_at') this.scheduledAt});

  factory _$StatusUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatusUpdateImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
// text, image, video
  @override
  final String? text;
  @override
  @JsonKey(name: 'media_url')
  final String? mediaUrl;
  @override
  final String? caption;
  @override
  @JsonKey(name: 'background_color')
  final String? backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  final String? textColor;
  @override
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'contact_avatar')
  final String? contactAvatar;
  @override
  @JsonKey(name: 'view_count')
  final int viewCount;
  @override
  @JsonKey()
  final bool viewed;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;

  @override
  String toString() {
    return 'StatusUpdate(id: $id, type: $type, text: $text, mediaUrl: $mediaUrl, caption: $caption, backgroundColor: $backgroundColor, textColor: $textColor, contactName: $contactName, contactPhone: $contactPhone, contactAvatar: $contactAvatar, viewCount: $viewCount, viewed: $viewed, createdAt: $createdAt, expiresAt: $expiresAt, scheduledAt: $scheduledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactAvatar, contactAvatar) ||
                other.contactAvatar == contactAvatar) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.viewed, viewed) || other.viewed == viewed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      text,
      mediaUrl,
      caption,
      backgroundColor,
      textColor,
      contactName,
      contactPhone,
      contactAvatar,
      viewCount,
      viewed,
      createdAt,
      expiresAt,
      scheduledAt);

  /// Create a copy of StatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusUpdateImplCopyWith<_$StatusUpdateImpl> get copyWith =>
      __$$StatusUpdateImplCopyWithImpl<_$StatusUpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusUpdateImplToJson(
      this,
    );
  }
}

abstract class _StatusUpdate implements StatusUpdate {
  const factory _StatusUpdate(
          {required final String id,
          required final String type,
          final String? text,
          @JsonKey(name: 'media_url') final String? mediaUrl,
          final String? caption,
          @JsonKey(name: 'background_color') final String? backgroundColor,
          @JsonKey(name: 'text_color') final String? textColor,
          @JsonKey(name: 'contact_name') final String? contactName,
          @JsonKey(name: 'contact_phone') final String? contactPhone,
          @JsonKey(name: 'contact_avatar') final String? contactAvatar,
          @JsonKey(name: 'view_count') final int viewCount,
          final bool viewed,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'expires_at') final DateTime? expiresAt,
          @JsonKey(name: 'scheduled_at') final DateTime? scheduledAt}) =
      _$StatusUpdateImpl;

  factory _StatusUpdate.fromJson(Map<String, dynamic> json) =
      _$StatusUpdateImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // text, image, video
  @override
  String? get text;
  @override
  @JsonKey(name: 'media_url')
  String? get mediaUrl;
  @override
  String? get caption;
  @override
  @JsonKey(name: 'background_color')
  String? get backgroundColor;
  @override
  @JsonKey(name: 'text_color')
  String? get textColor;
  @override
  @JsonKey(name: 'contact_name')
  String? get contactName;
  @override
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @override
  @JsonKey(name: 'contact_avatar')
  String? get contactAvatar;
  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  bool get viewed;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'scheduled_at')
  DateTime? get scheduledAt;

  /// Create a copy of StatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusUpdateImplCopyWith<_$StatusUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContactStatus _$ContactStatusFromJson(Map<String, dynamic> json) {
  return _ContactStatus.fromJson(json);
}

/// @nodoc
mixin _$ContactStatus {
  String get contactId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  List<StatusUpdate> get statuses => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_unviewed')
  bool get hasUnviewed => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_update_time')
  DateTime? get lastUpdateTime => throw _privateConstructorUsedError;

  /// Serializes this ContactStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactStatusCopyWith<ContactStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactStatusCopyWith<$Res> {
  factory $ContactStatusCopyWith(
          ContactStatus value, $Res Function(ContactStatus) then) =
      _$ContactStatusCopyWithImpl<$Res, ContactStatus>;
  @useResult
  $Res call(
      {String contactId,
      String name,
      String? phone,
      String? avatar,
      List<StatusUpdate> statuses,
      @JsonKey(name: 'has_unviewed') bool hasUnviewed,
      @JsonKey(name: 'last_update_time') DateTime? lastUpdateTime});
}

/// @nodoc
class _$ContactStatusCopyWithImpl<$Res, $Val extends ContactStatus>
    implements $ContactStatusCopyWith<$Res> {
  _$ContactStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contactId = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatar = freezed,
    Object? statuses = null,
    Object? hasUnviewed = null,
    Object? lastUpdateTime = freezed,
  }) {
    return _then(_value.copyWith(
      contactId: null == contactId
          ? _value.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      statuses: null == statuses
          ? _value.statuses
          : statuses // ignore: cast_nullable_to_non_nullable
              as List<StatusUpdate>,
      hasUnviewed: null == hasUnviewed
          ? _value.hasUnviewed
          : hasUnviewed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContactStatusImplCopyWith<$Res>
    implements $ContactStatusCopyWith<$Res> {
  factory _$$ContactStatusImplCopyWith(
          _$ContactStatusImpl value, $Res Function(_$ContactStatusImpl) then) =
      __$$ContactStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String contactId,
      String name,
      String? phone,
      String? avatar,
      List<StatusUpdate> statuses,
      @JsonKey(name: 'has_unviewed') bool hasUnviewed,
      @JsonKey(name: 'last_update_time') DateTime? lastUpdateTime});
}

/// @nodoc
class __$$ContactStatusImplCopyWithImpl<$Res>
    extends _$ContactStatusCopyWithImpl<$Res, _$ContactStatusImpl>
    implements _$$ContactStatusImplCopyWith<$Res> {
  __$$ContactStatusImplCopyWithImpl(
      _$ContactStatusImpl _value, $Res Function(_$ContactStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContactStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contactId = null,
    Object? name = null,
    Object? phone = freezed,
    Object? avatar = freezed,
    Object? statuses = null,
    Object? hasUnviewed = null,
    Object? lastUpdateTime = freezed,
  }) {
    return _then(_$ContactStatusImpl(
      contactId: null == contactId
          ? _value.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      statuses: null == statuses
          ? _value._statuses
          : statuses // ignore: cast_nullable_to_non_nullable
              as List<StatusUpdate>,
      hasUnviewed: null == hasUnviewed
          ? _value.hasUnviewed
          : hasUnviewed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: freezed == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactStatusImpl implements _ContactStatus {
  const _$ContactStatusImpl(
      {required this.contactId,
      required this.name,
      this.phone,
      this.avatar,
      final List<StatusUpdate> statuses = const [],
      @JsonKey(name: 'has_unviewed') this.hasUnviewed = false,
      @JsonKey(name: 'last_update_time') this.lastUpdateTime})
      : _statuses = statuses;

  factory _$ContactStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactStatusImplFromJson(json);

  @override
  final String contactId;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? avatar;
  final List<StatusUpdate> _statuses;
  @override
  @JsonKey()
  List<StatusUpdate> get statuses {
    if (_statuses is EqualUnmodifiableListView) return _statuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statuses);
  }

  @override
  @JsonKey(name: 'has_unviewed')
  final bool hasUnviewed;
  @override
  @JsonKey(name: 'last_update_time')
  final DateTime? lastUpdateTime;

  @override
  String toString() {
    return 'ContactStatus(contactId: $contactId, name: $name, phone: $phone, avatar: $avatar, statuses: $statuses, hasUnviewed: $hasUnviewed, lastUpdateTime: $lastUpdateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactStatusImpl &&
            (identical(other.contactId, contactId) ||
                other.contactId == contactId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality().equals(other._statuses, _statuses) &&
            (identical(other.hasUnviewed, hasUnviewed) ||
                other.hasUnviewed == hasUnviewed) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      contactId,
      name,
      phone,
      avatar,
      const DeepCollectionEquality().hash(_statuses),
      hasUnviewed,
      lastUpdateTime);

  /// Create a copy of ContactStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactStatusImplCopyWith<_$ContactStatusImpl> get copyWith =>
      __$$ContactStatusImplCopyWithImpl<_$ContactStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactStatusImplToJson(
      this,
    );
  }
}

abstract class _ContactStatus implements ContactStatus {
  const factory _ContactStatus(
          {required final String contactId,
          required final String name,
          final String? phone,
          final String? avatar,
          final List<StatusUpdate> statuses,
          @JsonKey(name: 'has_unviewed') final bool hasUnviewed,
          @JsonKey(name: 'last_update_time') final DateTime? lastUpdateTime}) =
      _$ContactStatusImpl;

  factory _ContactStatus.fromJson(Map<String, dynamic> json) =
      _$ContactStatusImpl.fromJson;

  @override
  String get contactId;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get avatar;
  @override
  List<StatusUpdate> get statuses;
  @override
  @JsonKey(name: 'has_unviewed')
  bool get hasUnviewed;
  @override
  @JsonKey(name: 'last_update_time')
  DateTime? get lastUpdateTime;

  /// Create a copy of ContactStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactStatusImplCopyWith<_$ContactStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

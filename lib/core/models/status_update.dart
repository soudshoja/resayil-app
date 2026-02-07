import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_update.freezed.dart';
part 'status_update.g.dart';

@freezed
class StatusUpdate with _$StatusUpdate {
  const factory StatusUpdate({
    required String id,
    required String type, // text, image, video
    String? text,
    @JsonKey(name: 'media_url') String? mediaUrl,
    String? caption,
    @JsonKey(name: 'background_color') String? backgroundColor,
    @JsonKey(name: 'text_color') String? textColor,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_avatar') String? contactAvatar,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @Default(false) bool viewed,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
  }) = _StatusUpdate;

  factory StatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$StatusUpdateFromJson(json);
}

@freezed
class ContactStatus with _$ContactStatus {
  const factory ContactStatus({
    required String contactId,
    required String name,
    String? phone,
    String? avatar,
    @Default([]) List<StatusUpdate> statuses,
    @JsonKey(name: 'has_unviewed') @Default(false) bool hasUnviewed,
    @JsonKey(name: 'last_update_time') DateTime? lastUpdateTime,
  }) = _ContactStatus;

  factory ContactStatus.fromJson(Map<String, dynamic> json) =>
      _$ContactStatusFromJson(json);
}

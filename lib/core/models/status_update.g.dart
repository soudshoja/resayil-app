// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatusUpdateImpl _$$StatusUpdateImplFromJson(Map<String, dynamic> json) =>
    _$StatusUpdateImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String?,
      mediaUrl: json['media_url'] as String?,
      caption: json['caption'] as String?,
      backgroundColor: json['background_color'] as String?,
      textColor: json['text_color'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactAvatar: json['contact_avatar'] as String?,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      viewed: json['viewed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
    );

Map<String, dynamic> _$$StatusUpdateImplToJson(_$StatusUpdateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'text': instance.text,
      'media_url': instance.mediaUrl,
      'caption': instance.caption,
      'background_color': instance.backgroundColor,
      'text_color': instance.textColor,
      'contact_name': instance.contactName,
      'contact_phone': instance.contactPhone,
      'contact_avatar': instance.contactAvatar,
      'view_count': instance.viewCount,
      'viewed': instance.viewed,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
    };

_$ContactStatusImpl _$$ContactStatusImplFromJson(Map<String, dynamic> json) =>
    _$ContactStatusImpl(
      contactId: json['contactId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => StatusUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasUnviewed: json['has_unviewed'] as bool? ?? false,
      lastUpdateTime: json['last_update_time'] == null
          ? null
          : DateTime.parse(json['last_update_time'] as String),
    );

Map<String, dynamic> _$$ContactStatusImplToJson(_$ContactStatusImpl instance) =>
    <String, dynamic>{
      'contactId': instance.contactId,
      'name': instance.name,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'statuses': instance.statuses,
      'has_unviewed': instance.hasUnviewed,
      'last_update_time': instance.lastUpdateTime?.toIso8601String(),
    };

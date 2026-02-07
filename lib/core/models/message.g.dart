// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      type: json['type'] as String,
      text: json['text'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaCaption: json['media_caption'] as String?,
      fileName: json['file_name'] as String?,
      mimeType: json['mime_type'] as String?,
      outgoing: json['outgoing'] as bool,
      status: json['status'] as String? ?? 'sent',
      senderName: json['sender_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'type': instance.type,
      'text': instance.text,
      'media_url': instance.mediaUrl,
      'media_caption': instance.mediaCaption,
      'file_name': instance.fileName,
      'mime_type': instance.mimeType,
      'outgoing': instance.outgoing,
      'status': instance.status,
      'sender_name': instance.senderName,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
    };

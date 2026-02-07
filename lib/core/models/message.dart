import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType { text, image, video, document, audio, sticker, location }

enum MessageStatus { sending, sent, delivered, read, failed }

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    required String type, // text, image, video, document, audio
    String? text,
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'media_caption') String? mediaCaption,
    @JsonKey(name: 'file_name') String? fileName,
    @JsonKey(name: 'mime_type') String? mimeType,
    required bool outgoing,
    @Default('sent') String status, // sending, sent, delivered, read, failed
    @JsonKey(name: 'sender_name') String? senderName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

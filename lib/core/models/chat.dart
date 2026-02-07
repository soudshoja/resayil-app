import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String name,
    String? phone,
    String? avatar,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @Default(false) bool archived,
    @Default(false) bool resolved,
    @Default(false) bool pinned,
    @Default([]) List<String> labels,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    String? status, // online, offline, typing
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}

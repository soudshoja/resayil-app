import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String name,
    String? description,
    String? avatar,
    @JsonKey(name: 'participant_count') @Default(0) int participantCount,
    @JsonKey(name: 'invite_link') String? inviteLink,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<Participant> participants,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String name,
    String? phone,
    String? avatar,
    @Default('member') String role, // admin, member
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}

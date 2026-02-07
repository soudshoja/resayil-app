import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/contact.dart';
import '../../../core/models/group.dart';
import '../../../core/models/message.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(ref.read(dioProvider));
});

class GroupsRepository {
  final Dio _dio;

  GroupsRepository(this._dio);

  /// Fetch all groups with optional pagination
  Future<List<Group>> getGroups({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.groups,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseList<Group>(response.data, Group.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch a single group with full details
  Future<Group?> getGroup(String groupId) async {
    try {
      final response = await _dio.get(ApiConstants.group(groupId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final groupData = data['data'] ?? data;
        return Group.fromJson(groupData as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch messages for a group
  Future<List<Message>> getMessages(
    String groupId, {
    int page = 1,
    int perPage = 50,
    String? before,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (before != null) params['before'] = before;

      final response = await _dio.get(
        ApiConstants.chatMessages(groupId),
        queryParameters: params,
      );
      return _parseList<Message>(response.data, Message.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Send a text message to a group
  Future<Message?> sendTextMessage(String groupId, String text) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendMessage,
        data: {
          'chat_id': groupId,
          'to': groupId,
          'type': 'text',
          'text': {'body': text},
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['data'] != null) {
          return Message.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Message(
          id: data['message_id'] ??
              'local_${DateTime.now().millisecondsSinceEpoch}',
          chatId: groupId,
          type: 'text',
          text: text,
          outgoing: true,
          status: data['status'] ?? 'sent',
          createdAt: DateTime.now(),
        );
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Send a media message to a group
  Future<Message?> sendMediaMessage({
    required String groupId,
    required String type,
    required String filePath,
    String? caption,
    String? fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'chat_id': groupId,
        'to': groupId,
        'type': type,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (caption != null) 'caption': caption,
      });

      final response = await _dio.post(
        ApiConstants.sendMedia,
        data: formData,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return Message.fromJson(data['data'] as Map<String, dynamic>);
      }
      return Message(
        id: data?['message_id'] ??
            'local_${DateTime.now().millisecondsSinceEpoch}',
        chatId: groupId,
        type: type,
        mediaCaption: caption,
        outgoing: true,
        status: 'sent',
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Create a new group
  Future<Group?> createGroup({
    required String name,
    String? description,
    required List<String> participantIds,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.groups,
        data: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
          'participants': participantIds,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final groupData = data['data'] ?? data;
        return Group.fromJson(groupData as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update group info (name, description)
  Future<bool> updateGroup(
    String groupId, {
    String? name,
    String? description,
  }) async {
    try {
      await _dio.put(
        ApiConstants.group(groupId),
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get group participants
  Future<List<Participant>> getParticipants(String groupId) async {
    try {
      final response = await _dio.get(ApiConstants.groupParticipants(groupId));
      return _parseList<Participant>(response.data, Participant.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Add participants to group
  Future<bool> addParticipants(
      String groupId, List<String> participantIds) async {
    try {
      await _dio.post(
        ApiConstants.groupParticipants(groupId),
        data: {'participants': participantIds},
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Remove a participant from group
  Future<bool> removeParticipant(
      String groupId, String participantId) async {
    try {
      await _dio.delete(
        '${ApiConstants.groupParticipants(groupId)}/$participantId',
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Promote participant to admin
  Future<bool> promoteParticipant(
      String groupId, String participantId) async {
    try {
      await _dio.post(
        ApiConstants.groupPromote(groupId),
        data: {'participant': participantId},
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Demote admin to member
  Future<bool> demoteParticipant(
      String groupId, String participantId) async {
    try {
      await _dio.post(
        ApiConstants.groupDemote(groupId),
        data: {'participant': participantId},
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get group invite link
  Future<String?> getInviteLink(String groupId) async {
    try {
      final response = await _dio.get(ApiConstants.groupInviteLink(groupId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['invite_link'] ?? data['link'] ?? data['data']?['link'];
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Regenerate group invite link
  Future<String?> regenerateInviteLink(String groupId) async {
    try {
      final response = await _dio.post(ApiConstants.groupInviteLink(groupId));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['invite_link'] ?? data['link'] ?? data['data']?['link'];
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Leave a group
  Future<bool> leaveGroup(String groupId) async {
    try {
      await _dio.delete(ApiConstants.group(groupId));
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch contacts for participant selection
  Future<List<Contact>> getContacts({String? search}) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _dio.get(
        ApiConstants.contacts,
        queryParameters: params,
      );
      return _parseList<Contact>(response.data, Contact.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

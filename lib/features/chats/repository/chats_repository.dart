import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/chat.dart';
import '../../../core/models/message.dart';

final chatsRepositoryProvider = Provider<ChatsRepository>((ref) {
  return ChatsRepository(ref.read(dioProvider));
});

class ChatsRepository {
  final Dio _dio;

  ChatsRepository(this._dio);

  /// Fetch all chats with optional pagination
  Future<List<Chat>> getChats({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.chats,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseList<Chat>(response.data, Chat.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch messages for a chat with pagination
  Future<List<Message>> getMessages(
    String chatId, {
    int page = 1,
    int perPage = 50,
    String? before, // message ID for cursor-based pagination
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (before != null) params['before'] = before;

      final response = await _dio.get(
        ApiConstants.chatMessages(chatId),
        queryParameters: params,
      );
      return _parseList<Message>(response.data, Message.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Send a text message
  Future<Message?> sendTextMessage(String chatId, String text) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendMessage,
        data: {
          'chat_id': chatId,
          'to': chatId, // some APIs use 'to' instead of 'chat_id'
          'type': 'text',
          'text': {'body': text},
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Return the sent message or construct one from the response
        if (data['data'] != null) {
          return Message.fromJson(data['data'] as Map<String, dynamic>);
        }
        // Build a local message from API response
        return Message(
          id: data['message_id'] ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
          chatId: chatId,
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

  /// Send a media message (image, document, video, audio)
  Future<Message?> sendMediaMessage({
    required String chatId,
    required String type,
    required String filePath,
    String? caption,
    String? fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'chat_id': chatId,
        'to': chatId,
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
        id: data?['message_id'] ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
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

  /// Archive a chat
  Future<bool> archiveChat(String chatId) async {
    try {
      await _dio.post(ApiConstants.chatArchive(chatId));
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Unarchive a chat
  Future<bool> unarchiveChat(String chatId) async {
    try {
      await _dio.delete(ApiConstants.chatArchive(chatId));
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Resolve a chat
  Future<bool> resolveChat(String chatId) async {
    try {
      await _dio.post(ApiConstants.chatResolve(chatId));
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Set labels on a chat
  Future<bool> setChatLabels(String chatId, List<String> labels) async {
    try {
      await _dio.put(
        ApiConstants.chatLabels(chatId),
        data: {'labels': labels},
      );
      return true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Fetch available labels
  Future<List<Map<String, dynamic>>> getLabels() async {
    try {
      final response = await _dio.get(ApiConstants.labels);
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Helper to parse list responses
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

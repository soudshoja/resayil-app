import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/chat.dart';
import '../../../core/models/message.dart';

final chatsProvider =
    AsyncNotifierProvider<ChatsNotifier, List<Chat>>(ChatsNotifier.new);

class ChatsNotifier extends AsyncNotifier<List<Chat>> {
  @override
  Future<List<Chat>> build() => fetchChats();

  Future<List<Chat>> fetchChats() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.chats);
      final data = response.data;

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => Chat.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => Chat.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchChats);
  }
}

final chatMessagesProvider = FutureProvider.family<List<Message>, String>(
  (ref, chatId) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.chatMessages(chatId));
      final data = response.data;

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  },
);

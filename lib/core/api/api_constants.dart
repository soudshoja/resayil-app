class ApiConstants {
  ApiConstants._();

  static const baseUrl = 'https://wa.resayil.io/api/v1';
  static const baseWebUrl = 'https://wa.resayil.io';

  // Auth endpoints
  static const login = '/login';
  static const registerUrl = 'https://wa.resayil.io/register';
  static const recoverUrl = 'https://wa.resayil.io/recover';

  // Chat endpoints
  static const chats = '/chats';
  static String chatMessages(String chatId) => '/chats/$chatId/messages';
  static String chatArchive(String chatId) => '/chats/$chatId/archive';
  static String chatResolve(String chatId) => '/chats/$chatId/resolve';
  static String chatLabels(String chatId) => '/chats/$chatId/labels';

  // Message endpoints
  static const messages = '/messages';
  static const sendMessage = '/messages/send';
  static const sendMedia = '/messages/media';
  static const sendTemplate = '/messages/template';
  static String messageStatus(String id) => '/messages/$id/status';

  // Group endpoints
  static const groups = '/groups';
  static String group(String id) => '/groups/$id';
  static String groupParticipants(String id) => '/groups/$id/participants';
  static String groupInviteLink(String id) => '/groups/$id/invite';
  static String groupPromote(String id) => '/groups/$id/promote';
  static String groupDemote(String id) => '/groups/$id/demote';

  // Status endpoints
  static const status = '/status';
  static String statusById(String id) => '/status/$id';

  // Contact endpoints
  static const contacts = '/contacts';
  static String contact(String id) => '/contacts/$id';

  // Profile
  static const profile = '/profile';

  // Labels
  static const labels = '/labels';

  // Files
  static const files = '/files';
  static String file(String id) => '/files/$id';

  // Webhooks
  static const webhooks = '/webhooks';

  // Device / Push Notifications
  static const deviceToken = '/devices/token';
}

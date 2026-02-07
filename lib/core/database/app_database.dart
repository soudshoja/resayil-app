import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────

class CachedChats extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get lastMessage => text().nullable()();
  DateTimeColumn get lastMessageTime => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get labels => text().withDefault(const Constant(''))(); // JSON array
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get type => text()();
  TextColumn get textContent => text().nullable()();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get mediaCaption => text().nullable()();
  TextColumn get fileName => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  BoolColumn get outgoing => boolean()();
  TextColumn get status => text().withDefault(const Constant('sent'))();
  TextColumn get senderName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ────────────────────────────────────────────────

@DriftDatabase(tables: [CachedChats, CachedMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ─── Chat Operations ───────────────────────────────────────

  Future<List<CachedChat>> getAllChats() =>
      (select(cachedChats)..orderBy([(t) => OrderingTerm.desc(t.lastMessageTime)]))
          .get();

  Future<void> upsertChat(CachedChatsCompanion chat) =>
      into(cachedChats).insertOnConflictUpdate(chat);

  Future<void> upsertChats(List<CachedChatsCompanion> chats) async {
    await batch((b) {
      for (final chat in chats) {
        b.insert(cachedChats, chat, onConflict: DoUpdate((_) => chat));
      }
    });
  }

  Future<void> deleteChat(String chatId) =>
      (delete(cachedChats)..where((t) => t.id.equals(chatId))).go();

  // ─── Message Operations ────────────────────────────────────

  Future<List<CachedMessage>> getMessages(String chatId, {int limit = 50, int offset = 0}) =>
      (select(cachedMessages)
            ..where((t) => t.chatId.equals(chatId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit, offset: offset))
          .get();

  Future<void> upsertMessage(CachedMessagesCompanion message) =>
      into(cachedMessages).insertOnConflictUpdate(message);

  Future<void> upsertMessages(List<CachedMessagesCompanion> messages) async {
    await batch((b) {
      for (final msg in messages) {
        b.insert(cachedMessages, msg, onConflict: DoUpdate((_) => msg));
      }
    });
  }

  Future<void> updateMessageStatus(String messageId, String newStatus) =>
      (update(cachedMessages)..where((t) => t.id.equals(messageId)))
          .write(CachedMessagesCompanion(status: Value(newStatus)));

  Future<void> deleteMessagesForChat(String chatId) =>
      (delete(cachedMessages)..where((t) => t.chatId.equals(chatId))).go();

  // ─── Pending Messages (outbox) ─────────────────────────────

  Future<List<CachedMessage>> getPendingMessages() =>
      (select(cachedMessages)
            ..where((t) => t.status.equals('sending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'resayil.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ─── Provider ────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

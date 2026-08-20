

import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_exception.dart';

class ChatDatabaseException extends AppException {
  const ChatDatabaseException(super.message);

  factory ChatDatabaseException.from(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();

    switch (code) {
      // ── Auth / Permission ───────────────────────────────────────────────
      case '42501': // insufficient_privilege
        return const ChatDatabaseException('You do not have permission to perform this action.');
      case 'PGRST301': // JWT expired
        return const ChatDatabaseException('Your session has expired. Please sign in again.');
      case 'PGRST116': // row not found (single() returned nothing)
        return const ChatDatabaseException('The requested data was not found.');

      // ── Constraint violations ───────────────────────────────────────────
      case '23505': // unique_violation
        return const ChatDatabaseException('This record already exists.');
      case '23503': // foreign_key_violation
        return const ChatDatabaseException('Related data not found. Please try again.');
      case '23502': // not_null_violation
        return const ChatDatabaseException('Required information is missing. Please try again.');

      // ── RLS violations ──────────────────────────────────────────────────
      case '42P01': // undefined_table
        return const ChatDatabaseException('A server error occurred. Please try again.');
    }

    // Fallback — check message string
    if (message.contains('jwt') || message.contains('token')) {
      return const ChatDatabaseException('Your session has expired. Please sign in again.');
    }
    if (message.contains('permission') || message.contains('policy')) {
      return const ChatDatabaseException('You do not have permission to perform this action.');
    }
    if (message.contains('not found') || message.contains('no rows')) {
      return const ChatDatabaseException('The requested data was not found.');
    }

    return ChatDatabaseException(e.message.isNotEmpty ? e.message : 'A database error occurred. Please try again.');
  }
}

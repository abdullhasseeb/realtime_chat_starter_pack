import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:realtime_chat/utils/exceptions/storage_exception.dart';
import 'package:realtime_chat/utils/exceptions/unknown_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_exception.dart';
import 'base_exception.dart';
import 'database_exception.dart';
import 'google_sign_in_exception.dart';
import 'network_exception.dart';

/// Wraps any repository call with standard exception mapping.
/// Use this in every repository method instead of repeating try-catch.
///
/// Usage:
/// ```dart
/// return await runSafe(() async {
///   final response = await _client.auth.signIn(...);
///   return UserModel.fromSupabase(response.user!);
/// });
/// ```
Future<T> runSafe<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on AppException {
    rethrow;
  } on GoogleSignInException catch (e) {
    throw ChatGoogleSignInException.from(e);
  } on AuthException catch (e) {
    throw ChatAuthException.from(e);
  } on PostgrestException catch (e) {
    throw ChatDatabaseException.from(e);
  } on StorageException catch (e) {
    throw ChatStorageException.from(e);
  } on SocketException catch (e) {
    throw ChatNetworkException.from(e);
  } on TimeoutException catch (e) {
    throw ChatNetworkException.from(e);
  } catch (_) {
    throw const ChatUnknownException();
  }
}
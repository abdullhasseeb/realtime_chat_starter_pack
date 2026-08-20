

import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_exception.dart';

class ChatAuthException extends AppException {
  const ChatAuthException(super.message);

  // Factory — maps Supabase AuthException → ChatAuthException
  factory ChatAuthException.from(AuthException e) {
    // AuthException has both .code and .message
    // .code is the official error code (snake_case) — most reliable
    // .message is human readable but can change — use as fallback only
    final code = e.code ?? '';

    switch (code) {
      // ── Credentials ──────────────────────────────────────────────────────
      case 'invalid_credentials':
        return const ChatAuthException('Wrong email or password. Please try again.');

      case 'user_not_found':
        return const ChatAuthException('No account found with this email address.');

      case 'weak_password':
        return const ChatAuthException(
          'Password is too weak. Please use at least 8 characters with letters and numbers.',
        );

      case 'same_password':
        return const ChatAuthException('New password must be different from your current password.');

      case 'validation_failed':
        return const ChatAuthException('Invalid information provided. Please check your details and try again.');

      // ── Email ─────────────────────────────────────────────────────────────
      case 'email_exists':
      case 'user_already_exists':
        return const ChatAuthException('An account with this email already exists. Please sign in instead.');

      case 'email_not_confirmed':
        return const ChatAuthException('Please verify your email address. Check your inbox for a verification link.');

      case 'email_provider_disabled':
        return const ChatAuthException('Email sign-in is currently unavailable. Please try another method.');

      case 'email_address_invalid':
        return const ChatAuthException('This email address is not valid. Please enter a correct email.');

      case 'over_email_send_rate_limit':
        return const ChatAuthException(
          'Too many emails sent to this address. Please wait a few minutes and try again.',
        );

      // ── Session / Token ───────────────────────────────────────────────────
      case 'bad_jwt':
        return const ChatAuthException('Your session is invalid. Please sign in again.');

      case 'session_expired':
        return const ChatAuthException('Your session has expired. Please sign in again.');

      case 'session_not_found':
        return const ChatAuthException('Session not found. Please sign in again.');

      case 'refresh_token_not_found':
      case 'refresh_token_already_used':
        return const ChatAuthException('Your session has ended. Please sign in again.');

      case 'flow_state_expired':
      case 'flow_state_not_found':
        return const ChatAuthException('Sign-in session expired. Please try signing in again.');

      // ── Rate Limiting ─────────────────────────────────────────────────────
      case 'over_request_rate_limit':
        return const ChatAuthException('Too many attempts. Please wait a few minutes and try again.');

      // ── Account Status ─────────────────────────────────────────────────────
      case 'user_banned':
        return const ChatAuthException('This account has been suspended. Please contact support.');

      case 'signup_disabled':
        return const ChatAuthException('New account registration is currently disabled. Please try again later.');

      // ── OAuth / Google ────────────────────────────────────────────────────
      case 'bad_oauth_callback':
      case 'bad_oauth_state':
        return const ChatAuthException('Google sign-in failed. Please try again.');

      case 'provider_disabled':
      case 'oauth_provider_not_supported':
        return const ChatAuthException('This sign-in method is currently disabled.');

      case 'provider_email_needs_verification':
        return const ChatAuthException('Please verify your email address to continue.');

      // ── Network / Server ──────────────────────────────────────────────────
      case 'request_timeout':
        return const ChatAuthException('Request timed out. Please check your connection and try again.');

      case 'unexpected_failure':
        return const ChatAuthException('A server error occurred. Please try again in a moment.');

      case 'conflict':
        return const ChatAuthException('A conflict occurred. Please try again.');

      // ── No code — fallback to message parsing ─────────────────────────────
      default:
        return _fromMessage(e.message);
    }
  }

  // Fallback — when code is null or unrecognized
  // Parse the raw message string for common patterns
  static ChatAuthException _fromMessage(String message) {
    final m = message.toLowerCase();

    if (m.contains('invalid login credentials') || m.contains('invalid_credentials')) {
      return const ChatAuthException('Wrong email or password. Please try again.');
    }
    if (m.contains('email') && m.contains('exist')) {
      return const ChatAuthException('An account with this email already exists.');
    }
    if (m.contains('not confirmed')) {
      return const ChatAuthException('Please verify your email address before signing in.');
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return const ChatAuthException('Too many attempts. Please wait a moment and try again.');
    }
    if (m.contains('network') || m.contains('connection')) {
      return const ChatAuthException('Connection failed. Please check your internet and try again.');
    }
    if (m.contains('expired')) {
      return const ChatAuthException('Your session has expired. Please sign in again.');
    }

    // unknown — return raw message as last resort
    return ChatAuthException(message.isNotEmpty ? message : 'Authentication failed. Please try again.');
  }
}

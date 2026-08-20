import 'dart:async';
import 'dart:io';

import 'base_exception.dart';

class ChatNetworkException extends AppException {
  const ChatNetworkException(super.message);

  // Factory — maps network errors → ChatNetworkException
  factory ChatNetworkException.from(Object e) {
    if (e is SocketException) {
      // SocketException — no internet or server unreachable
      final message = e.message.toLowerCase();
      final code = e.osError?.errorCode;

      // OS error codes for common network failures
      switch (code) {
        case 7: // no address associated with hostname
        case 8:
        case 101: // network unreachable
        case 111: //connection refused
        case 113: // no route to host
          return const ChatNetworkException('No internet connection. Please check your network and try again.');
        case 110: //  connection timed out
          return const ChatNetworkException('Connection timed out. Please check your network and try again.');
      }

      // Fallback — check message string
      if (message.contains('failed host lookup') ||
          message.contains('no address') ||
          message.contains('network unreachable')) {
        return const ChatNetworkException('No internet connection. Please check your network and try again.');
      }

      return const ChatNetworkException('Connection failed. Please check your internet and try again.');
    }

    if (e is TimeoutException) {
      return const ChatNetworkException('Request timed out. Please check your connection and try again.');
    }

    if (e is HandshakeException) {
      // SSL/TLS handshake failure
      return const ChatNetworkException('Secure connection failed. Please try again.');
    }

    if (e is HttpException) {
      return const ChatNetworkException('Network error occurred. Please try again.');
    }

    return const ChatNetworkException('Connection failed. Please check your internet and try again.');
  }
}

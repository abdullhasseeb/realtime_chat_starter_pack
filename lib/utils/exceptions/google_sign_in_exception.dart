
import 'package:google_sign_in/google_sign_in.dart';

import 'base_exception.dart';

class ChatGoogleSignInException extends AppException {
  const ChatGoogleSignInException(super.message);

  // Factory — maps GoogleSignInException → ChatGoogleSignInException
  factory ChatGoogleSignInException.from(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return const ChatGoogleSignInException('Google sign-in was cancelled.');

      case GoogleSignInExceptionCode.interrupted:
        return const ChatGoogleSignInException('Google sign-in was interrupted. Please try again.');

      case GoogleSignInExceptionCode.clientConfigurationError:
        return const ChatGoogleSignInException('Google sign-in is not configured correctly. Please contact support.');

      case GoogleSignInExceptionCode.providerConfigurationError:
        return const ChatGoogleSignInException('Google sign-in service is unavailable. Please try again later.');

      case GoogleSignInExceptionCode.uiUnavailable:
        return const ChatGoogleSignInException('Cannot show Google sign-in screen. Please try again.');

      case GoogleSignInExceptionCode.userMismatch:
        return const ChatGoogleSignInException('Account mismatch. Please sign out and try again.');

      case GoogleSignInExceptionCode.unknownError:
        // unknownError carries description — check it for clues
        final desc = e.description?.toLowerCase() ?? '';

        if (desc.contains('no credential') || desc.contains('no account')) {
          return const ChatGoogleSignInException(
            'No Google account found on this device. Please add a Google account in settings.',
          );
        }
        if (desc.contains('network') || desc.contains('connection')) {
          return const ChatGoogleSignInException('No internet connection. Please check your network.');
        }
        if (desc.contains('developer console') || desc.contains('not set up')) {
          return const ChatGoogleSignInException('Google sign-in is not available right now. Please try again later.');
        }
        return const ChatGoogleSignInException('Google sign-in failed. Please try again.');
    }
  }
}

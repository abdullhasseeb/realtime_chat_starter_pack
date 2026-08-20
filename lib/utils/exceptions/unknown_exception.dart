

import 'base_exception.dart';

class ChatUnknownException extends AppException {
  const ChatUnknownException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
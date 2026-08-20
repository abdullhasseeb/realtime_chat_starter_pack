
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_exception.dart';

class ChatStorageException extends AppException {
  const ChatStorageException(super.message);

  factory ChatStorageException.from(StorageException e) {
    final message = e.message.toLowerCase();

    if (message.contains('not found') || message.contains('404')) {
      return const ChatStorageException('File not found. Please try again.');
    }
    if (message.contains('too large') || message.contains('size')) {
      return const ChatStorageException('File is too large. Please choose a smaller image.');
    }
    if (message.contains('permission') || message.contains('unauthorized')) {
      return const ChatStorageException('You do not have permission to upload files.');
    }
    if (message.contains('duplicate') || message.contains('already exists')) {
      return const ChatStorageException('This file already exists.');
    }
    if (message.contains('invalid') || message.contains('mime')) {
      return const ChatStorageException('Invalid file type. Please choose a valid image.');
    }

    return ChatStorageException(e.message.isNotEmpty ? e.message : 'Failed to upload image. Please try again.');
  }
}

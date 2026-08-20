class SupabaseChannels {

  static String homeConversation(String id) => 'home_conversations_$id';
  static String messages(String conversationId) => 'messages_$conversationId';
  static String messageStatus(String conversationId) => 'message_status_$conversationId';
  static const String globalChannel = 'online_users';
  static String watchTyping(String conversationId) => 'typing_$conversationId';
}
enum MessageTick { pending, failed, sent, delivered, read }

enum UPTimeFormat {
  /// "14:32" / "Mon" / "12/05/25"  —> for conversation list
  conversation,

  /// Always "14:32"  —> for chat bubbles
  bubble,
}

enum MessageType { text, image }

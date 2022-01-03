import 'package:flutter/material.dart';

import 'chat_list_element.dart';
import 'chat_list_render.dart';

class ChatList extends SliverWithKeepAliveWidget {
  /// Creates a sliver that places box children in a linear array.
  const ChatList({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final SliverChildDelegate delegate;

  @override
  ChatListElement createElement() =>
      ChatListElement(this);

  @override
  ChatListRender createRenderObject(BuildContext context) {
    final ChatListElement element =
        context as ChatListElement;

    return ChatListRender(childManager: element);
  }
}

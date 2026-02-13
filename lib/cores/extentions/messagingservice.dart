abstract class MessagingServiceImpl {
  void subscribe(
    Object subscriber, {
    required String channel,
    required void Function(Object) action,
  });

  void unsubscribe(Object subscriber, {required String channel});

  void send({required String channel, required Object parameter});
}

class MessagingService implements MessagingServiceImpl {
  static final _map = <String, Map<String, void Function(Object)>>{};

  @override
  void subscribe(
    Object subscriber, {
    required String channel,
    required void Function(Object val) action,
  }) {
    assert(channel.isNotEmpty);

    if (!_map.containsKey(channel)) {
      _map[channel] = {};
    }

    _map[channel]?.putIfAbsent(subscriber.hashCode.toString(), () => action);
  }

  @override
  void send({required String channel, required Object parameter}) {
    assert(channel.isNotEmpty);

    if (_map.containsKey(channel)) {
      for (final action in _map[channel]!.values) {
        action(parameter);
      }
    }
  }

  @override
  void unsubscribe(Object subscriber, {required String channel}) {
    if (_map.containsKey(channel)) {
      _map[channel]!.removeWhere((k, v) => k == subscriber.hashCode.toString());
    }
  }
}

class MessageChannel {
  const MessageChannel._();
  static const startUserChanged = 'startUserChanged';
  static const modelAIChanged = 'modelAIChanged';
}

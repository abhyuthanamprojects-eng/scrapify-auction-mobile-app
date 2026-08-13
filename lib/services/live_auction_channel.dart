import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/network/api_config.dart';
import '../models/bid.dart';

class LiveAuctionChannel {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _pollTimer;
  String? _auctionCode;

  final _bidController = StreamController<Bid>.broadcast();
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Bid> get onBid => _bidController.stream;
  Stream<Map<String, dynamic>> get onStateChange => _stateController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  Future<void> connect(String auctionCode) async {
    _auctionCode = auctionCode;
    await _disconnect();

    try {
      final uri = Uri(
        scheme: 'ws',
        host: ApiConfig.reverbHost,
        port: ApiConfig.reverbPort,
        path: '/app/${ApiConfig.reverbKey}',
      );

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _connected = true;

      // Subscribe to the auction's public channel
      _channel!.sink.add(jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'channel': 'auction.$auctionCode'},
      }));

      _sub = _channel!.stream.listen(
        _handleMessage,
        onError: (_) => _fallbackToPolling(),
        onDone: () => _fallbackToPolling(),
      );

      if (kDebugMode) debugPrint('[WS] Connected to auction.$auctionCode');
    } catch (e) {
      if (kDebugMode) debugPrint('[WS] Connection failed: $e');
      _fallbackToPolling();
    }
  }

  void _handleMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = msg['event'] as String? ?? '';
      final data = msg['data'] is String
          ? jsonDecode(msg['data'] as String) as Map<String, dynamic>
          : msg['data'] as Map<String, dynamic>? ?? {};

      if (event == 'bid.placed') {
        final bidData = data['bid'] as Map<String, dynamic>? ?? {};
        _bidController.add(Bid.fromBroadcast(bidData));
        if (data['auction'] != null) {
          _stateController.add(data['auction'] as Map<String, dynamic>);
        }
      } else if (event == 'auction.state') {
        if (data['auction'] != null) {
          _stateController.add(data['auction'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[WS] Parse error: $e');
    }
  }

  void _fallbackToPolling() {
    if (_auctionCode == null) return;
    _connected = false;
    if (kDebugMode) debugPrint('[WS] Falling back to polling');

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _stateController.add({'poll': true, 'code': _auctionCode});
    });
  }

  Future<void> _disconnect() async {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connected = false;
  }

  Future<void> dispose() async {
    await _disconnect();
    _bidController.close();
    _stateController.close();
  }
}

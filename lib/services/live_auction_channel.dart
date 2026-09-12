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
  Timer? _reconnectTimer;
  String? _auctionCode;
  Future<Map<String, dynamic>> Function()? _pollRequest;

  final _bidController = StreamController<Bid>.broadcast();
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Bid> get onBid => _bidController.stream;
  Stream<Map<String, dynamic>> get onStateChange => _stateController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  bool _isReconnecting = false;
  bool get isReconnecting => _isReconnecting;

  final _reconnectingController = StreamController<bool>.broadcast();
  Stream<bool> get onReconnectingChange => _reconnectingController.stream;

  Future<void> connect(
    String auctionCode, {
    Future<Map<String, dynamic>> Function()? pollRequest,
  }) async {
    _auctionCode = auctionCode;
    _pollRequest = pollRequest;
    await _disconnect();
    _setReconnecting(false);

    try {
      final uri = Uri(
        scheme: ApiConfig.reverbPort == 443 ? 'wss' : 'ws',
        host: ApiConfig.reverbHost,
        port: ApiConfig.reverbPort,
        path: '/app/${ApiConfig.reverbKey}',
      );

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      _connected = true;
      _setReconnecting(false);
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      // Subscribe to the auction's public channel
      _channel!.sink.add(jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'channel': 'auction.$auctionCode'},
      }));

      _sub = _channel!.stream.listen(
        _handleMessage,
        onError: (_) {
          if (kDebugMode) debugPrint('[WS] Stream error, falling back to polling');
          _fallbackToPolling();
        },
        onDone: () {
          if (kDebugMode) debugPrint('[WS] Stream closed, falling back to polling');
          _fallbackToPolling();
        },
      );

      if (kDebugMode) debugPrint('[WS] Connected to auction.$auctionCode');
    } catch (e) {
      if (kDebugMode) debugPrint('[WS] Connection failed: $e');
      _fallbackToPolling();
    }
  }

  void _setReconnecting(bool value) {
    _isReconnecting = value;
    _reconnectingController.add(value);
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
    _setReconnecting(true);
    if (kDebugMode) debugPrint('[WS] Falling back to polling');

    _pollTimer?.cancel();
    if (_pollRequest != null) {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        try {
          final snapshot = await _pollRequest!();
          _stateController.add(snapshot);
        } catch (e) {
          if (kDebugMode) debugPrint('[WS] API polling failed: $e');
        }
      });
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_auctionCode != null) {
        connect(_auctionCode!, pollRequest: _pollRequest);
      }
    });
  }

  Future<void> _disconnect() async {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connected = false;
    _setReconnecting(false);
  }

  Future<void> dispose() async {
    await _disconnect();
    await _bidController.close();
    await _stateController.close();
    await _reconnectingController.close();
  }
}

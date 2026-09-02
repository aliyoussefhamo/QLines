import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../network/api_config.dart';

class ReservationRealtimeEvent {
  const ReservationRealtimeEvent({
    required this.reservationId,
    required this.status,
  });

  final String reservationId;
  final String status;
}

class ReservationRealtimeService extends ChangeNotifier {
  ReservationRealtimeService(String accessToken) {
    _socket = io.io(
      ApiConfig.serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );
    _socket.onConnect((_) {
      isConnected = true;
      lastEvent = null;
      notifyListeners();
    });
    _socket.onDisconnect((_) {
      isConnected = false;
      lastEvent = null;
      notifyListeners();
    });
    _socket.onConnectError((_) {
      isConnected = false;
      lastEvent = null;
      notifyListeners();
    });
    _socket.on('reservation.changed', _handleReservationChanged);
    _socket.connect();
  }

  late final io.Socket _socket;
  bool isConnected = false;
  ReservationRealtimeEvent? lastEvent;

  void _handleReservationChanged(Object? data) {
    if (data is! Map) return;
    final reservationId = data['reservationId'];
    final status = data['status'];
    if (reservationId is! String || status is! String) return;
    lastEvent = ReservationRealtimeEvent(
      reservationId: reservationId,
      status: status,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}

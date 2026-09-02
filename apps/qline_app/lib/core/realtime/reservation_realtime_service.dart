import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../network/api_config.dart';

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
    _socket.on('reservation.changed', (_) => notifyListeners());
    _socket.connect();
  }

  late final io.Socket _socket;

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}

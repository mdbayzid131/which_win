import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:which_win/config/constants/api_constants.dart';
import 'package:which_win/config/constants/storage_constants.dart';
import 'package:which_win/core/services/storage_service.dart';
import 'package:which_win/core/utils/helpers.dart';
import 'package:which_win/app/modules/notifications/controllers/notifications_controller.dart';

/// ===================== SOCKET SERVICE =====================
/// Manages real-time Socket.IO connection lifecycle.
/// Handles: connection, registration, rooms, messaging, and reconnection.
/// Requires: socket_io_client
class SocketService extends GetxService {
  socket_io.Socket? _socket;

  /// Expose socket for direct event listening in controllers
  socket_io.Socket? get socket => _socket;

  /// Observable connection state
  final isConnected = false.obs;

  /// Callback for incoming notifications
  void Function(dynamic data)? onNotificationReceived;

  /// Callback for incoming messages
  void Function(dynamic data)? onMessageReceived;

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  // ──────────────────── INITIALIZATION ────────────────────

  Future<void> _initSocket() async {
    final token = await StorageService.getString(StorageConstants.bearerToken);
    final userId = await StorageService.getString(StorageConstants.userId);

    if (token.isEmpty) {
      Helpers.warning('Socket initialization skipped: No auth token');
      return;
    }

    // Extract base URL (remove /api/v1 suffix)
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    Helpers.debug('Socket connecting to: $baseUrl');

    _socket = socket_io.io(
      baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _setupListeners(userId);
  }

  void _setupListeners(String userId) {
    _socket?.onConnect((_) {
      Helpers.info('Socket connected');
      isConnected.value = true;
      if (userId.isNotEmpty) {
        registerUser(userId);
        joinRoom(
          'user::$userId',
        ); // Join the user's private room user::{userId}
      }
    });

    _socket?.onDisconnect((_) {
      Helpers.info('Socket disconnected');
      isConnected.value = false;
    });

    _socket?.onConnectError((err) {
      Helpers.error('Socket connect error: $err');
      isConnected.value = false;
    });

    _socket?.onError((err) {
      Helpers.error('Socket error: $err');
    });

    // Default notification handlers
    _socket?.on('notification:new', (data) {
      Helpers.debug('New notification (notification:new): $data');
      _handleIncomingNotification(data);
    });

    _socket?.on('new-notification', (data) {
      Helpers.debug('New notification (new-notification): $data');
      _handleIncomingNotification(data);
    });

    // Default message handler
    _socket?.on('new-message', (data) {
      Helpers.debug('New message: $data');
      onMessageReceived?.call(data);
    });
  }

  void _handleIncomingNotification(dynamic data) {
    try {
      if (data == null) return;

      // Parse notification if data is a map
      if (data is Map) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data);
        Helpers.info('🔔 Real-time notification received: ${jsonMap['title']}');
      }

      // Check if NotificationsController is registered in GetX
      if (Get.isRegistered<NotificationsController>()) {
        // Robust sync: Fetch the latest list of notifications from /notifications/me
        // This automatically updates the list and updates unreadCount.value
        // Get.find<NotificationsController>().fetchNotifications(isRefresh: true);
        Helpers.info('🔄 NotificationsController found, but fetchNotifications is not implemented in the new project yet.');
      }

      // Trigger callback if registered
      onNotificationReceived?.call(data);
    } catch (e) {
      Helpers.error('Error handling incoming socket notification: $e');
    }
  }

  // ──────────────────── PUBLIC METHODS ────────────────────

  /// Connect or reconnect the socket
  void connect() {
    if (_socket == null) {
      _initSocket();
    } else if (!_socket!.connected) {
      Helpers.debug('Manually reconnecting socket...');
      _socket?.connect();
    }
  }

  /// Disconnect the socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  /// Register user identity with the socket server
  void registerUser(String userId) {
    if (_socket?.connected ?? false) {
      _socket?.emit('register', userId);
      Helpers.debug('User registered with socket: $userId');
    } else {
      Helpers.warning('Cannot register: Socket not connected');
    }
  }

  /// Join a chat/notification room
  void joinRoom(String roomId) {
    _socket?.emit('join-room', roomId);
    Helpers.debug('Joined room: $roomId');
  }

  /// Leave a room
  void leaveRoom(String roomId) {
    _socket?.emit('leave-room', roomId);
    Helpers.debug('Left room: $roomId');
  }

  /// Send a message to a room
  void sendMessage(String roomId, String senderId, String content) {
    if (!(_socket?.connected ?? false)) {
      Helpers.warning('Cannot send message: Socket not connected');
      return;
    }

    final payload = {
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
    };

    _socket?.emit('send-message', payload);
    Helpers.debug('Message sent: $payload');
  }

  /// Listen to a custom event
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Emit a custom event
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}

import 'dart:async';
import 'package:mindhearth/core/services/logger.dart';

/// Observer pattern implementation for MindHearth
/// 
/// This provides a robust event-driven architecture for:
/// - State change notifications
/// - Cross-feature communication
/// - Decoupled component interactions
class ObserverPattern {
  static final _logger = AppLogger('ObserverPattern');
  
  // Event streams for different domains
  static final Map<String, StreamController<AppEvent>> _eventControllers = {};
  static final Map<String, List<StreamSubscription>> _subscriptions = {};

  /// Subscribe to events of a specific type
  static StreamSubscription<T> subscribe<T extends AppEvent>(
    String eventType,
    void Function(T event) onEvent, {
    void Function(Object error)? onError,
  }) {
    final controller = _getOrCreateController(eventType);
    final subscription = controller.stream
        .where((event) => event is T)
        .cast<T>()
        .listen(onEvent, onError: onError);
    
    _subscriptions[eventType] ??= [];
    _subscriptions[eventType]!.add(subscription);
    
    _logger.debug('Subscribed to $eventType events');
    return subscription;
  }

  /// Publish an event
  static void publish(AppEvent event) {
    final eventType = event.runtimeType.toString();
    final controller = _getOrCreateController(eventType);
    
    if (!controller.isClosed) {
      controller.add(event);
      _logger.debug('Published $eventType event: ${event.toString()}');
    }
  }

  /// Get or create a stream controller for an event type
  static StreamController<AppEvent> _getOrCreateController(String eventType) {
    if (!_eventControllers.containsKey(eventType)) {
      _eventControllers[eventType] = StreamController<AppEvent>.broadcast();
    }
    return _eventControllers[eventType]!;
  }

  /// Unsubscribe from events
  static void unsubscribe(String eventType, StreamSubscription subscription) {
    subscription.cancel();
    _subscriptions[eventType]?.remove(subscription);
    _logger.debug('Unsubscribed from $eventType events');
  }

  /// Unsubscribe all subscriptions for an event type
  static void unsubscribeAll(String eventType) {
    _subscriptions[eventType]?.forEach((subscription) => subscription.cancel());
    _subscriptions[eventType]?.clear();
    _logger.debug('Unsubscribed all $eventType events');
  }

  /// Close all event streams
  static void closeAll() {
    _eventControllers.values.forEach((controller) => controller.close());
    _eventControllers.clear();
    _subscriptions.clear();
    _logger.info('All event streams closed');
  }
}

/// Base class for all app events
abstract class AppEvent {
  final String id;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AppEvent({
    required this.id,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  String toString() => '${runtimeType}(id: $id, timestamp: $timestamp)';
}

/// Authentication events
class AuthEvent extends AppEvent {
  const AuthEvent({
    required super.id,
    required super.timestamp,
    super.metadata,
  });
}

class UserLoggedInEvent extends AuthEvent {
  final String userId;
  final String email;

  const UserLoggedInEvent({
    required super.id,
    required super.timestamp,
    required this.userId,
    required this.email,
    super.metadata,
  });

  @override
  String toString() => 'UserLoggedInEvent(userId: $userId, email: $email)';
}

class UserLoggedOutEvent extends AuthEvent {
  final String userId;

  const UserLoggedOutEvent({
    required super.id,
    required super.timestamp,
    required this.userId,
    super.metadata,
  });

  @override
  String toString() => 'UserLoggedOutEvent(userId: $userId)';
}

/// Chat events
class ChatEvent extends AppEvent {
  const ChatEvent({
    required super.id,
    required super.timestamp,
    super.metadata,
  });
}

class SessionCreatedEvent extends ChatEvent {
  final String sessionId;
  final String sessionName;

  const SessionCreatedEvent({
    required super.id,
    required super.timestamp,
    required this.sessionId,
    required this.sessionName,
    super.metadata,
  });

  @override
  String toString() => 'SessionCreatedEvent(sessionId: $sessionId, name: $sessionName)';
}

class MessageSentEvent extends ChatEvent {
  final String sessionId;
  final String messageId;
  final String content;

  const MessageSentEvent({
    required super.id,
    required super.timestamp,
    required this.sessionId,
    required this.messageId,
    required this.content,
    super.metadata,
  });

  @override
  String toString() => 'MessageSentEvent(sessionId: $sessionId, messageId: $messageId)';
}

/// Journal events
class JournalEvent extends AppEvent {
  const JournalEvent({
    required super.id,
    required super.timestamp,
    super.metadata,
  });
}

class JournalEntryCreatedEvent extends JournalEvent {
  final String entryId;
  final String header;

  const JournalEntryCreatedEvent({
    required super.id,
    required super.timestamp,
    required this.entryId,
    required this.header,
    super.metadata,
  });

  @override
  String toString() => 'JournalEntryCreatedEvent(entryId: $entryId, header: $header)';
}

/// Billing events
class BillingEvent extends AppEvent {
  const BillingEvent({
    required super.id,
    required super.timestamp,
    super.metadata,
  });
}

class CreditsPurchasedEvent extends BillingEvent {
  final String purchaseId;
  final int credits;
  final double amount;

  const CreditsPurchasedEvent({
    required super.id,
    required super.timestamp,
    required this.purchaseId,
    required this.credits,
    required this.amount,
    super.metadata,
  });

  @override
  String toString() => 'CreditsPurchasedEvent(purchaseId: $purchaseId, credits: $credits)';
}

/// Error events
class ErrorEvent extends AppEvent {
  final String errorType;
  final String errorMessage;
  final String? context;

  const ErrorEvent({
    required super.id,
    required super.timestamp,
    required this.errorType,
    required this.errorMessage,
    this.context,
    super.metadata,
  });

  @override
  String toString() => 'ErrorEvent(type: $errorType, message: $errorMessage)';
}

/// Performance events
class PerformanceEvent extends AppEvent {
  final String operationName;
  final Duration duration;
  final bool success;

  const PerformanceEvent({
    required super.id,
    required super.timestamp,
    required this.operationName,
    required this.duration,
    required this.success,
    super.metadata,
  });

  @override
  String toString() => 'PerformanceEvent(operation: $operationName, duration: ${duration.inMilliseconds}ms)';
}

/// Event factory for creating events
class EventFactory {
  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  static UserLoggedInEvent userLoggedIn({
    required String userId,
    required String email,
    Map<String, dynamic>? metadata,
  }) {
    return UserLoggedInEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      userId: userId,
      email: email,
      metadata: metadata ?? {},
    );
  }

  static UserLoggedOutEvent userLoggedOut({
    required String userId,
    Map<String, dynamic>? metadata,
  }) {
    return UserLoggedOutEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      userId: userId,
      metadata: metadata ?? {},
    );
  }

  static SessionCreatedEvent sessionCreated({
    required String sessionId,
    required String sessionName,
    Map<String, dynamic>? metadata,
  }) {
    return SessionCreatedEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      sessionId: sessionId,
      sessionName: sessionName,
      metadata: metadata ?? {},
    );
  }

  static MessageSentEvent messageSent({
    required String sessionId,
    required String messageId,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return MessageSentEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      sessionId: sessionId,
      messageId: messageId,
      content: content,
      metadata: metadata ?? {},
    );
  }

  static JournalEntryCreatedEvent journalEntryCreated({
    required String entryId,
    required String header,
    Map<String, dynamic>? metadata,
  }) {
    return JournalEntryCreatedEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      entryId: entryId,
      header: header,
      metadata: metadata ?? {},
    );
  }

  static CreditsPurchasedEvent creditsPurchased({
    required String purchaseId,
    required int credits,
    required double amount,
    Map<String, dynamic>? metadata,
  }) {
    return CreditsPurchasedEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      purchaseId: purchaseId,
      credits: credits,
      amount: amount,
      metadata: metadata ?? {},
    );
  }

  static ErrorEvent error({
    required String errorType,
    required String errorMessage,
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      errorType: errorType,
      errorMessage: errorMessage,
      context: context,
      metadata: metadata ?? {},
    );
  }

  static PerformanceEvent performance({
    required String operationName,
    required Duration duration,
    required bool success,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceEvent(
      id: _generateId(),
      timestamp: DateTime.now(),
      operationName: operationName,
      duration: duration,
      success: success,
      metadata: metadata ?? {},
    );
  }
}

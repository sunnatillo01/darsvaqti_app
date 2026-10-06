import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<String>.broadcast();

  static const _channelId = 'lesson_reminders';
  static const _channelName = 'Dars eslatmalari';
  static const _channelDesc = 'Dars boshlanishidan oldin eslatadi';

  @override
  Stream<String> get onTap => _tapController.stream;

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();

    // Vaqt zonasini aniqlash: avval plagin, bo'lmasa telefon offset'i bo'yicha.
    tz.Location? loc;
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      loc = tz.getLocation(info.identifier);
    } catch (e) {
      debugPrint('Timezone aniqlanmadi: $e');
    }
    loc ??= _locationFromOffset(DateTime.now().timeZoneOffset);
    tz.setLocalLocation(loc);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) _tapController.add(p);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
        ));
  }

  /// Telefonning UTC farqiga mos keladigan birinchi zonani topadi.
  tz.Location _locationFromOffset(Duration offset) {
    final ms = offset.inMilliseconds;
    for (final l in tz.timeZoneDatabase.locations.values) {
      if (l.currentTimeZone.offset == ms) return l;
    }
    return tz.UTC;
  }

  @override
  Future<String?> getLaunchPayload() async {
    final d = await _plugin.getNotificationAppLaunchDetails();
    if (d?.didNotificationLaunchApp ?? false) return d?.notificationResponse?.payload;
    return null;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    var granted = true;
    if (android != null) {
      granted = (await android.requestNotificationsPermission()) ?? false;
      final canExact = await android.canScheduleExactNotifications() ?? true;
      if (!canExact) {
        unawaited(android.requestExactAlarmsPermission()); // javobni kutmaymiz
      }
    }
    if (ios != null) {
      granted = (await ios.requestPermissions(alert: true, badge: true, sound: true)) ?? false;
    }
    return granted;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          color: Color(0xFF2563EB),
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );

  /// Avval aniq vaqtda, bo'lmasa taxminiy vaqtda rejalashtiradi.
  Future<void> _zoned(
    int id,
    String title,
    String body,
    tz.TZDateTime when,
    String? payload,
    DateTimeComponents? match,
  ) async {
    Future<void> run(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          _details,
          payload: payload,
          androidScheduleMode: mode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: match,
        );
    try {
      await run(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      await run(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    for (var i = 0; i < 8; i++) {
      final c = tz.TZDateTime(tz.local, now.year, now.month, now.day + i, hour, minute);
      if (c.weekday == weekday && c.isAfter(now)) {
        when = c;
        break;
      }
    }
    await _zoned(id, title, body, when, payload, DateTimeComponents.dayOfWeekAndTime);
  }

  @override
  Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
  }) async {
    await _zoned(id, title, body, tz.TZDateTime.from(at, tz.local), payload, null);
  }

  @override
  Future<void> showNow({required int id, required String title, required String body}) =>
      _plugin.show(id, title, body, _details);

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
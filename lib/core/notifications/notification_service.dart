/// Abstraksiya (DIP): domain/data qatlamlari plugin'ga bog'lanib qolmaydi.
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();

  /// Har hafta takrorlanadigan bildirishnoma.
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1..7
    required int hour,
    required int minute,
    String? payload,
  });

  /// Bir martalik bildirishnoma.
  Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    String? payload,
  });

  Future<void> showNow({required int id, required String title, required String body});
  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// Bildirishnomaga bosilganda payload shu stream'ga tushadi.
  Stream<String> get onTap;

  /// Ilova bildirishnoma orqali ochilgan bo'lsa, payload.
  Future<String?> getLaunchPayload();
}

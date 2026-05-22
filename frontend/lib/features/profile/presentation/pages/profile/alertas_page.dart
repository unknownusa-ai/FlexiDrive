import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexidrive/core/utils/colombia_time.dart';
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/reviews/application/use_cases/review_access_use_case.dart';
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_catalog_use_case.dart';
import 'package:flexidrive/injection_container.dart';

/// Define la responsabilidad de `AlertasPage` dentro de este módulo.
class AlertasPage extends StatefulWidget {
  /// Crea una instancia y prepara el estado inicial de `AlertasPage`.
  const AlertasPage({super.key});

  /// Gestiona crear estado dentro de esta parte del flujo.
  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

/// Define la responsabilidad de `_AlertasPageState` dentro de este módulo.
class _AlertasPageState extends State<AlertasPage> {
  static const _reminderKeysStorage = 'reservation_reminder_keys_v1';
  static const _reviewKeysStorage = 'review_notifications_keys_v1';
  static const List<String> _tabs = <String>[
    'Todas',
    'Solicitudes',
    'Pagos',
    'Reseñas',
    'Recordatorios',
    'Consejos',
  ];

  final AccountAccessUseCase _accountDb =
      InjectionContainer.instance.accountAccessUseCase;
  final CatalogAccessUseCase _catalogDb =
      InjectionContainer.instance.catalogAccessUseCase;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;
  final ReservationAccessUseCase _reservationDb =
      InjectionContainer.instance.reservationAccessUseCase;
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  final ReviewAccessUseCase _reviewDb =
      InjectionContainer.instance.reviewAccessUseCase;
  final VehicleCatalogUseCase _vehicleDb =
      InjectionContainer.instance.vehicleCatalogUseCase;

  int _selectedTab = 0;
  bool _isLoading = true;
  int _unreadCount = 0;
  List<_AlertItem> _alerts = <_AlertItem>[];
  Timer? _refreshTimer;
  bool _isSyncingReviewNotifications = false;

  /// Inicializa el proceso de inicialización del estado antes de su uso.
  @override
  void initState() {
    super.initState();
    _notificationDb.changes.addListener(_onNotificationsChanged);
    _loadAlerts();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      _loadAlerts();
    });
  }

  /// Gestiona dispose dentro de esta parte del flujo.
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _notificationDb.changes.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  /// Gestiona on notificaciones changed dentro de esta parte del flujo.
  void _onNotificationsChanged() {
    _loadAlerts();
  }

  /// Carga los datos necesarios para cargar alerts.
  Future<void> _loadAlerts() async {
    await Future.wait([
      _catalogDb.loadIfNeeded(),
      _notificationDb.loadIfNeeded(),
      _reservationDb.loadIfNeeded(),
      _publicationDb.loadIfNeeded(),
      _reviewDb.loadIfNeeded(),
      _vehicleDb.loadIfNeeded(),
    ]);

    final currentUser = await _accountDb.getCurrentUser();
    final currentUserId = currentUser?.id;
    if (currentUserId != null) {
      await _syncReservationReminders(currentUserId);
      await _syncReviewNotifications(currentUserId);
      await _notificationDb.loadIfNeeded();
    }

    final categoriesById = <int, String>{
      for (final category in _catalogDb.notificationCategories)
        category.id: category.name,
    };

    final source = currentUserId == null
        ? _notificationDb.notifications
        : _notificationDb.notifications
            .where((notification) => notification.userId == currentUserId);

    final loaded = source
        .map(
          (notification) => _toAlertItem(
            notification,
            categoriesById[notification.categoryId],
          ),
        )
        .toList();

    loaded.sort((a, b) => b.sentAt.compareTo(a.sentAt));

    if (!mounted) return;
    setState(() {
      _alerts = loaded;
      _unreadCount = _alerts.where((item) => item.unread).length;
      _isLoading = false;
    });
  }

  /// Gestiona a alert item dentro de esta parte del flujo.
  _AlertItem _toAlertItem(NotificationModel item, String? categoryName) {
    final tab = _resolveTab(categoryName, item.subject, item.description);
    return _AlertItem(
      id: item.id,
      tab: tab,
      title: _cleanTitle(item.subject),
      subtitle: item.description,
      time: _timeAgo(item.sentAt),
      unread: item.status == 'no_leida',
      sentAt: item.sentAt,
    );
  }

  /// Gestiona clean title dentro de esta parte del flujo.
  String _cleanTitle(String subject) {
    return subject
        .replaceAll('✅', '')
        .replaceAll('🚗', '')
        .replaceAll('⏰', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Gestiona resolve tab dentro de esta parte del flujo.
  String _resolveTab(String? categoryName, String subject, String description) {
    final raw = '${categoryName ?? ''} $subject $description'.toLowerCase();
    if (raw.contains('pago') || raw.contains('transferencia')) {
      return 'Pagos';
    }
    if (raw.contains('reseña') ||
        raw.contains('resena') ||
        raw.contains('calificacion')) {
      return 'Reseñas';
    }
    if (raw.contains('recordatorio') ||
        raw.contains('finaliza') ||
        raw.contains('venc')) {
      return 'Recordatorios';
    }
    if (raw.contains('solicitud') ||
        raw.contains('reserva') ||
        raw.contains('renta')) {
      return 'Solicitudes';
    }
    if (raw.contains('consejo') ||
        raw.contains('tip') ||
        raw.contains('optimiza') ||
        raw.contains('ganancia')) {
      return 'Consejos';
    }
    return 'Consejos';
  }

  /// Gestiona time ago dentro de esta parte del flujo.
  String _timeAgo(DateTime sentAt) {
    final now = ColombiaTime.now();
    final diff = now.difference(ColombiaTime.toColombia(sentAt));

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${sentAt.day.toString().padLeft(2, '0')}/${sentAt.month.toString().padLeft(2, '0')}/${sentAt.year}';
  }

  /// Sincronizar reserva reminders esta parte del flujo de trabajo.
  Future<void> _syncReservationReminders(int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final sentKeys =
        (prefs.getStringList(_reminderKeysStorage) ?? <String>[]).toSet();
    final reminderCategoryId = _resolveReminderCategoryId();

    final publicationsById = {
      for (final publication in _publicationDb.publications)
        publication.id: publication,
    };

    final userOwnedPublicationIds = _publicationDb.publications
        .where((publication) => publication.userId == currentUserId)
        .map((publication) => publication.id)
        .toSet();

    final nowColombia = ColombiaTime.now();
    var updated = false;

    for (final reservation in _reservationDb.reservations) {
      // Considerar reservas pendientes/activas/finalizadas para no perder
      // recordatorios cuando el estado aún no se normaliza en UI.
      if (reservation.statusId == 3) continue;

      final start = ColombiaTime.toColombia(reservation.startDate);
      final end = ColombiaTime.toColombia(reservation.endDate);
      final minutesToEnd = end.difference(nowColombia).inMinutes;
      final reminderWindow = _resolveReminderWindow(reservation, start, end);
      final hasEnded = !end.isAfter(nowColombia);

      final publication = publicationsById[reservation.publicationId];
      final ownerId = publication?.userId;

      // Recordatorio al arrendatario (usuario que reservó)
      if (reservation.userId == currentUserId) {
        if (minutesToEnd <= reminderWindow.inMinutes && minutesToEnd > 0) {
          final key = 'renter_ending_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Recordatorio de reserva ⏰',
              description:
                  'Tu reserva ${reservation.code} finaliza pronto. Queda ${_formatRemainingTime(minutesToEnd)}.',
            );
            sentKeys.add(key);
            updated = true;
          }
        } else if (hasEnded) {
          final key = 'renter_ended_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Reserva finalizada ✅',
              description:
                  'Tu reserva ${reservation.code} ya finalizó. Gracias por usar FlexiDrive.',
            );
            sentKeys.add(key);
            updated = true;
          }
        }
      }

      // Recordatorio al arrendador (dueño de la publicación)
      if (ownerId != null &&
          ownerId == currentUserId &&
          userOwnedPublicationIds.contains(reservation.publicationId)) {
        if (minutesToEnd <= reminderWindow.inMinutes && minutesToEnd > 0) {
          final key = 'owner_ending_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Recordatorio de entrega 🚗',
              description:
                  'La renta ${reservation.code} de tu vehículo finaliza pronto. Queda ${_formatRemainingTime(minutesToEnd)}.',
            );
            sentKeys.add(key);
            updated = true;
          }
        } else if (hasEnded) {
          final key = 'owner_ended_${reservation.id}';
          if (!sentKeys.contains(key)) {
            await _notificationDb.addNotification(
              userId: currentUserId,
              categoryId: reminderCategoryId,
              subject: 'Renta finalizada ✅',
              description:
                  'La renta ${reservation.code} de tu vehículo ya finalizó.',
            );
            sentKeys.add(key);
            updated = true;
          }
        }
      }
    }

    if (updated) {
      await prefs.setStringList(_reminderKeysStorage, sentKeys.toList());
    }
  }

  /// Gestiona resolve reminder category id dentro de esta parte del flujo.
  int _resolveReminderCategoryId() {
    for (final category in _catalogDb.notificationCategories) {
      final name = category.name.toLowerCase();
      if (name.contains('recordatorio')) return category.id;
    }
    return _catalogDb.notificationCategories.isEmpty
        ? 1
        : _catalogDb.notificationCategories.first.id;
  }

  /// Sincronizar reseña notificaciones esta parte del flujo de trabajo.
  Future<void> _syncReviewNotifications(int currentUserId) async {
    if (_isSyncingReviewNotifications) return;
    _isSyncingReviewNotifications = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentKeys =
          (prefs.getStringList(_reviewKeysStorage) ?? <String>[]).toSet();
      final users = await _accountDb.getUsers();

      final publicationsById = {
        for (final publication in _publicationDb.publications)
          publication.id: publication,
      };
      final publicationIds = _publicationDb.publications
          .where((publication) => publication.userId == currentUserId)
          .map((publication) => publication.id)
          .toSet();
      final usersById = {for (final user in users) user.id: user};
      final vehiclesById = {
        for (final vehicle in _vehicleDb.vehicles) vehicle.id: vehicle,
      };

      if (publicationIds.isEmpty) return;

      final reviewCategoryId = _resolveReviewCategoryId();
      var updated = false;

      for (final review in _reviewDb.reviews) {
        if (!publicationIds.contains(review.publicationId)) continue;
        if (review.userId == currentUserId) continue;

        final key = 'owner_review_${review.id}';
        final existing = _notificationDb.notifications.where((notification) {
          return notification.userId == currentUserId &&
              _resolveTab(
                    null,
                    notification.subject,
                    notification.description,
                  ) ==
                  'Reseñas' &&
              notification.sentAt.millisecondsSinceEpoch ==
                  review.date.millisecondsSinceEpoch;
        }).toList();

        final publication = publicationsById[review.publicationId];
        final reviewer = usersById[review.userId];
        final vehicle =
            publication == null ? null : vehiclesById[publication.vehicleId];
        final reviewerName =
            reviewer == null || reviewer.fullName.trim().isEmpty
                ? 'Usuario #${review.userId}'
                : reviewer.fullName.trim();
        final publicationLabel = vehicle == null
            ? 'tu publicación #${review.publicationId}'
            : '${vehicle.line} ${vehicle.model}';
        final expectedSubject = '$reviewerName comentó tu publicación';
        final expectedDescription = 'Nueva reseña en $publicationLabel.';

        final hasExpected = existing.any(
          (notification) =>
              notification.subject == expectedSubject &&
              notification.description == expectedDescription,
        );
        if (sentKeys.contains(key) && hasExpected) continue;
        if (hasExpected) {
          sentKeys.add(key);
          continue;
        }

        for (final notification in existing) {
          await _notificationDb.deleteNotification(notification.id);
        }

        await _notificationDb.addNotification(
          userId: currentUserId,
          categoryId: reviewCategoryId,
          subject: expectedSubject,
          description: expectedDescription,
          sentAt: review.date,
        );
        sentKeys.add(key);
        updated = true;
        await prefs.setStringList(_reviewKeysStorage, sentKeys.toList());
      }

      final reviewAlerts = _notificationDb.notifications
          .where((n) => n.userId == currentUserId)
          .where(
              (n) => _resolveTab(null, n.subject, n.description) == 'Reseñas')
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      final seen = <String, int>{};
      for (final n in reviewAlerts) {
        final dedupeKey =
            '${n.subject}||${n.description}||${n.sentAt.millisecondsSinceEpoch}';
        final prevId = seen[dedupeKey];
        if (prevId == null) {
          seen[dedupeKey] = n.id;
        } else {
          await _notificationDb.deleteNotification(n.id);
          updated = true;
        }
      }

      if (updated) {
        await prefs.setStringList(_reviewKeysStorage, sentKeys.toList());
      }
    } finally {
      _isSyncingReviewNotifications = false;
    }
  }

  /// Gestiona resolve reseña category id dentro de esta parte del flujo.
  int _resolveReviewCategoryId() {
    for (final category in _catalogDb.notificationCategories) {
      final name = category.name.toLowerCase();
      if (name.contains('rese') ||
          name.contains('resena') ||
          name.contains('calificacion')) {
        return category.id;
      }
    }
    return _catalogDb.notificationCategories.isEmpty
        ? 1
        : _catalogDb.notificationCategories.first.id;
  }

  Duration _resolveReminderWindow(
    dynamic reservation,
    DateTime start,
    DateTime end,
  ) {
    // Reglas pedidas:
    // - día: 24 horas antes
    // - hora: 30 minutos antes
    // - semana: 3 días antes
    if (reservation.periodTypeId == 4) {
      return const Duration(minutes: 30); // horas
    }
    if (reservation.periodTypeId == 2) {
      return const Duration(days: 3); // semanas
    }
    if (reservation.periodTypeId == 1) {
      return const Duration(hours: 24); // días
    }

    // Fallback por duración real cuando no venga tipificado.
    final duration = end.difference(start);
    if (duration <= const Duration(hours: 6)) {
      return const Duration(minutes: 30);
    }
    if (duration >= const Duration(days: 7)) {
      return const Duration(days: 3);
    }
    return const Duration(hours: 24);
  }

  /// Gestiona format remaining time dentro de esta parte del flujo.
  String _formatRemainingTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours h';
    return '$hours h $remaining min';
  }

  /// Gestiona actual tab alerts dentro de esta parte del flujo.
  List<_AlertItem> _currentTabAlerts() {
    final tabName = _tabs[_selectedTab];
    if (tabName == 'Todas') return _alerts;
    return _alerts.where((item) => item.tab == tabName).toList();
  }

  /// Marca todas las notificaciones como leídas.
  Future<void> _markAllAsRead() async {
    final unread = _alerts.where((item) => item.unread).toList();
    for (final item in unread) {
      await _notificationDb.markAsRead(item.id);
    }
    await _loadAlerts();
  }

  /// Marca una notificación como leída.
  Future<void> _markAsRead(_AlertItem item) async {
    if (!item.unread) return;
    await _notificationDb.markAsRead(item.id);
    await _loadAlerts();
  }

  /// Elimina los datos vinculados a eliminar alert.
  Future<void> _deleteAlert(_AlertItem item) async {
    await _notificationDb.deleteNotification(item.id);
    await _loadAlerts();
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildHeader(isSmallPhone),
            _buildTabBar(isSmallPhone),
            Expanded(
              child: _buildNotificationsList(isSmallPhone),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildHeader(bool isSmallPhone) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        MediaQuery.of(context).padding.top + (isSmallPhone ? 12 : 16),
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                if (_unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_unreadCount sin leer',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.done_all, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Leer todo',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildTabBar(bool isSmallPhone) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardTheme.color,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 12 : 16,
        vertical: isSmallPhone ? 10 : 12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: isSelected ? null : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : theme.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getTabIcon(index, isSelected, theme),
                      const SizedBox(width: 4),
                      Text(
                        _tabs[index],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Obtiene la información asociada a obtener tab icon.
  Widget _getTabIcon(int index, bool isSelected, ThemeData theme) {
    final color = isSelected
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    switch (index) {
      case 0:
        return const SizedBox.shrink();
      case 1:
        return Icon(Icons.car_rental, size: 14, color: color);
      case 2:
        return Icon(Icons.account_balance_wallet, size: 14, color: color);
      case 3:
        return Icon(Icons.star, size: 14, color: color);
      case 4:
        return Icon(Icons.access_time, size: 14, color: color);
      case 5:
        return Icon(Icons.lightbulb_outline, size: 14, color: color);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Construye y devuelve el widget correspondiente a esta sección.
  Widget _buildNotificationsList(bool isSmallPhone) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final notifications = _currentTabAlerts();
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay notificaciones',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(
          isSmallPhone: isSmallPhone,
          notification: notifications[index],
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required bool isSmallPhone,
    required _AlertItem notification,
  }) {
    final theme = Theme.of(context);
    final visual = _visualForNotification(notification);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: notification.unread
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.unread
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(visual.icon, size: 22, color: visual.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallPhone ? 14 : 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (notification.unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                notification.time,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: notification.unread
                    ? () => _markAsRead(notification)
                    : null,
                child: Text(
                  notification.unread ? 'Marcar leído' : 'Leído',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: notification.unread
                        ? const Color(0xFF3B82F6)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteAlert(notification),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: const Color(0xFFEF4444).withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gestiona visual for notificación dentro de esta parte del flujo.
  _AlertVisual _visualForNotification(_AlertItem notification) {
    final raw = '${notification.title} ${notification.subtitle}'.toLowerCase();

    if (raw.contains('finalizada') || raw.contains('finalizó')) {
      return const _AlertVisual(
        icon: Icons.verified_rounded,
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF166534),
      );
    }
    if (raw.contains('recordatorio') ||
        raw.contains('entrega') ||
        raw.contains('finaliza pronto')) {
      return const _AlertVisual(
        icon: Icons.alarm_on_rounded,
        background: Color(0xFFFFEDD5),
        foreground: Color(0xFF9A3412),
      );
    }
    if (raw.contains('pago') || raw.contains('transferencia')) {
      return const _AlertVisual(
        icon: Icons.payments_rounded,
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1D4ED8),
      );
    }
    if (raw.contains('reseña') ||
        raw.contains('resena') ||
        raw.contains('calificacion')) {
      return const _AlertVisual(
        icon: Icons.rate_review_rounded,
        background: Color(0xFFFEF3C7),
        foreground: Color(0xFF92400E),
      );
    }
    if (raw.contains('solicitud') || raw.contains('reserva')) {
      return const _AlertVisual(
        icon: Icons.assignment_turned_in_rounded,
        background: Color(0xFFE0E7FF),
        foreground: Color(0xFF4338CA),
      );
    }
    if (raw.contains('consejo') || raw.contains('tip')) {
      return const _AlertVisual(
        icon: Icons.lightbulb_rounded,
        background: Color(0xFFE0F2FE),
        foreground: Color(0xFF0C4A6E),
      );
    }

    return const _AlertVisual(
      icon: Icons.notifications_active_rounded,
      background: Color(0xFFF3F4F6),
      foreground: Color(0xFF374151),
    );
  }
}

/// Define la responsabilidad de `_AlertVisual` dentro de este módulo.
class _AlertVisual {
  const _AlertVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

/// Define la responsabilidad de `_AlertItem` dentro de este módulo.
class _AlertItem {
  _AlertItem({
    required this.id,
    required this.tab,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
    required this.sentAt,
  });

  final int id;
  final String tab;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;
  final DateTime sentAt;
}

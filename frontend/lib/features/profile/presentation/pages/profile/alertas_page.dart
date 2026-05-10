import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/catalogs/application/use_cases/catalog_access_use_case.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:flexidrive/injection_container.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
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

  int _selectedTab = 0;
  bool _isLoading = true;
  int _unreadCount = 0;
  List<_AlertItem> _alerts = <_AlertItem>[];

  @override
  void initState() {
    super.initState();
    _notificationDb.changes.addListener(_onNotificationsChanged);
    _loadAlerts();
  }

  @override
  void dispose() {
    _notificationDb.changes.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    await Future.wait([
      _catalogDb.loadIfNeeded(),
      _notificationDb.loadIfNeeded(),
    ]);

    final currentUser = await _accountDb.getCurrentUser();
    final currentUserId = currentUser?.id;

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

  _AlertItem _toAlertItem(NotificationModel item, String? categoryName) {
    final tab = _resolveTab(categoryName, item.subject, item.description);
    return _AlertItem(
      id: item.id,
      tab: tab,
      title: item.subject,
      subtitle: item.description,
      time: _timeAgo(item.sentAt),
      unread: item.status == 'no_leida',
      sentAt: item.sentAt,
    );
  }

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

  String _timeAgo(DateTime sentAt) {
    final now = DateTime.now();
    final diff = now.difference(sentAt);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${sentAt.day.toString().padLeft(2, '0')}/${sentAt.month.toString().padLeft(2, '0')}/${sentAt.year}';
  }

  List<_AlertItem> _currentTabAlerts() {
    final tabName = _tabs[_selectedTab];
    if (tabName == 'Todas') return _alerts;
    return _alerts.where((item) => item.tab == tabName).toList();
  }

  Future<void> _markAllAsRead() async {
    final unread = _alerts.where((item) => item.unread).toList();
    for (final item in unread) {
      await _notificationDb.markAsRead(item.id);
    }
    await _loadAlerts();
  }

  Future<void> _markAsRead(_AlertItem item) async {
    if (!item.unread) return;
    await _notificationDb.markAsRead(item.id);
    await _loadAlerts();
  }

  Future<void> _deleteAlert(_AlertItem item) async {
    await _notificationDb.deleteNotification(item.id);
    await _loadAlerts();
  }

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
    final iconData = _iconForTab(notification.tab);
    final iconBg = _iconBgForTab(notification.tab);

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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, size: 22, color: const Color(0xFF1F2937)),
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
                onTap: notification.unread ? () => _markAsRead(notification) : null,
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

  IconData _iconForTab(String tab) {
    switch (tab) {
      case 'Solicitudes':
        return Icons.car_rental;
      case 'Pagos':
        return Icons.payments_outlined;
      case 'Reseñas':
        return Icons.star;
      case 'Recordatorios':
        return Icons.access_time;
      case 'Consejos':
        return Icons.auto_graph;
      default:
        return Icons.notifications_none;
    }
  }

  Color _iconBgForTab(String tab) {
    switch (tab) {
      case 'Solicitudes':
        return const Color(0xFFFFF5F5);
      case 'Pagos':
        return const Color(0xFFF0FDF4);
      case 'Reseñas':
        return const Color(0xFFFFFBEB);
      case 'Recordatorios':
        return const Color(0xFFFEF2F2);
      case 'Consejos':
        return const Color(0xFFF0F9FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

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

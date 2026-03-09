import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    'Todas',
    'Solicitudes',
    'Pagos',
    'Reseñas',
    'Recordatorios',
    'Consejos',
  ];

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '2 sin leer',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ) : null,
                    color: isSelected ? null : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF59E0B) : theme.dividerColor,
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
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    final color = isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6);
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
    final notifications = _getNotificationsForTab(_selectedTab);

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

  List<NotificationItem> _getNotificationsForTab(int tabIndex) {
    final allNotifications = [
      NotificationItem(
        icon: '🚗',
        iconBgColor: const Color(0xFFFFF5F5),
        title: 'Nueva solicitud de renta',
        subtitle: 'María López quiere rentar tu Chevrolet Onix del 12 al 14 de marzo',
        time: 'Hace 5 minutos',
        isUnread: true,
        action: 'Marcar leído',
      ),
      NotificationItem(
        icon: '💰',
        iconBgColor: const Color(0xFFF0FDF4),
        title: 'Pago recibido',
        subtitle: 'Has recibido \$900.000 por la renta de tu Mazda 3 a Carlos Mendoza',
        time: 'Hace 2 horas',
        isUnread: true,
        action: 'Marcar leído',
      ),
      NotificationItem(
        icon: '⭐',
        iconBgColor: const Color(0xFFFFFBEB),
        title: 'Nueva reseña recibida',
        subtitle: 'Andrea Gómez dejó una reseña de 5 ⭐ para tu Mazda 3',
        time: 'Ayer',
        isUnread: false,
        action: 'No leído',
      ),
      NotificationItem(
        icon: '⏰',
        iconBgColor: const Color(0xFFFEF2F2),
        title: 'Renta por finalizar',
        subtitle: 'La renta de tu Mazda 3 a Carlos Mendoza finaliza mañana (15 marzo)',
        time: 'Hace 1 día',
        isUnread: false,
        action: 'No leído',
      ),
      NotificationItem(
        icon: '📈',
        iconBgColor: const Color(0xFFF0F9FF),
        title: 'Optimiza tus ganancias',
        subtitle: 'Ajusta el precio de tu Chevrolet Onix según la demanda de la temporada',
        time: 'Hace 2 días',
        isUnread: false,
        action: 'No leído',
      ),
    ];

    if (tabIndex == 0) return allNotifications;
    if (tabIndex == 1) return allNotifications.where((n) => n.title.contains('solicitud')).toList();
    if (tabIndex == 2) return allNotifications.where((n) => n.title.contains('Pago')).toList();
    if (tabIndex == 3) return allNotifications.where((n) => n.title.contains('reseña')).toList();
    if (tabIndex == 4) return allNotifications.where((n) => n.title.contains('finalizar')).toList();
    if (tabIndex == 5) return allNotifications.where((n) => n.title.contains('ganancias')).toList();
    return allNotifications;
  }

  Widget _buildNotificationCard({
    required bool isSmallPhone,
    required NotificationItem notification,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isSmallPhone ? 12 : 14),
      decoration: BoxDecoration(
        color: notification.isUnread 
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isUnread 
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
                  color: notification.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
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
                        if (notification.isUnread)
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                onTap: () {
                  setState(() {
                    notification.isUnread = !notification.isUnread;
                  });
                },
                child: Text(
                  notification.action,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.delete_outline,
                size: 18,
                color: const Color(0xFFEF4444).withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String time;
  bool isUnread;
  String action;

  NotificationItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.action,
  });
}

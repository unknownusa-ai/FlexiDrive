import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flexidrive/core/session/local_session_store.dart';
import 'package:flexidrive/models/notifications/notification_models.dart';
import 'package:flexidrive/services/catalogs/local_catalog_db.dart';
import 'package:flexidrive/services/notifications/local_notification_db.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedTab = 'Todas';
  int _unreadCount = 0;
  bool _isLoading = true;

  final LocalNotificationDb _notificationDb = LocalNotificationDb.instance;
  final LocalCatalogDb _catalogDb = LocalCatalogDb.instance;
  final LocalSessionStore _sessionStore = LocalSessionStore.instance;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Dark-mode aware palette helpers
  Color get _cardBg => _isDark ? const Color(0xFF161827) : Colors.white;
  Color get _borderColor =>
      _isDark ? const Color(0xFF2E3355) : Colors.grey.shade200;
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF1F3FF) : const Color(0xFF1A1A1A);
  Color get _textSub =>
      _isDark ? const Color(0xFF8B93B8) : Colors.grey.shade500;

  // Icon background colors based on notification type
  Color _getIconBgColor(String type, bool isDark) {
    switch (type) {
      case 'reserva':
        return isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      case 'recordatorio':
        return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFE4E4);
      case 'promo':
        return isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
      case 'auto':
        return isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
      default:
        return isDark ? const Color(0xFF5B21B6) : const Color(0xFFEDE9FE);
    }
  }

  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.wait([
      _sessionStore.init(),
      _catalogDb.loadIfNeeded(),
      _notificationDb.loadIfNeeded(),
    ]);

    final currentUserId = _sessionStore.userId;
    final categoriesById = {
      for (final c in _catalogDb.notificationCategories) c.id: c.name,
    };

    final source = currentUserId == null
        ? _notificationDb.notifications
        : _notificationDb.notifications.where((n) => n.userId == currentUserId);

    final loaded = source.map((item) {
      final type = _mapType(categoriesById[item.categoryId]);
      return _toNotificationCard(item, type);
    }).toList();

    loaded.sort(
      (a, b) => (b['sentAt'] as DateTime).compareTo(a['sentAt'] as DateTime),
    );

    if (!mounted) return;

    setState(() {
      _notifications
        ..clear()
        ..addAll(loaded.isNotEmpty ? loaded : _fallbackNotifications());
      _unreadCount = _notifications.where((n) => n['unread'] == true).length;
      _isLoading = false;
    });
  }

  String _mapType(String? categoryName) {
    final raw = (categoryName ?? '').trim().toLowerCase();
    if (raw == 'reserva') return 'reserva';
    if (raw == 'recordatorio') return 'recordatorio';
    if (raw == 'auto') return 'auto';
    return 'promo';
  }

  Map<String, dynamic> _toNotificationCard(
      NotificationModel item, String type) {
    final defaults = _defaultsByType(type);
    final isGenericSubject =
        item.subject.trim().toLowerCase().startsWith('notificacion');
    final isGenericDescription = item.description
        .trim()
        .toLowerCase()
        .startsWith('detalle de notificacion');

    return {
      'id': item.id,
      'type': type,
      'title': isGenericSubject ? defaults['title'] : item.subject,
      'titleEmoji': defaults['titleEmoji'],
      'description':
          isGenericDescription ? defaults['description'] : item.description,
      'time': _timeAgo(item.sentAt),
      'unread': item.status == 'no_leida',
      'emoji': defaults['emoji'],
      'sentAt': item.sentAt,
    };
  }

  Map<String, String> _defaultsByType(String type) {
    switch (type) {
      case 'reserva':
        return {
          'title': '¡Reserva Confirmada!',
          'titleEmoji': '🎉',
          'description':
              'Tu Mazda CX-5 está listo. Recógelo el 22 Feb a las 8:00 AM en Av. El Dorado.',
          'emoji': '✅',
        };
      case 'recordatorio':
        return {
          'title': 'Recordatorio de Devolución',
          'titleEmoji': '⏰',
          'description':
              'Tu Tesla Model 3 debe ser devuelto mañana a las 6:00 PM. No olvides revisar el estado del vehículo.',
          'emoji': '⏰',
        };
      case 'auto':
        return {
          'title': 'Nuevo Vehículo Disponible',
          'titleEmoji': '🚗',
          'description':
              'El Porsche 718 Cayman ahora está disponible en tu zona. ¡Sé el primero en reservarlo!',
          'emoji': '🆕',
        };
      default:
        return {
          'title': '¡Oferta Exclusiva!',
          'titleEmoji': '🔥',
          'description':
              '30% de descuento en alquileres de más de 3 días este fin de semana. Usa el código FLEXIWEEK.',
          'emoji': '🎁',
        };
    }
  }

  String _timeAgo(DateTime sentAt) {
    final now = DateTime.now();
    final diff = now.difference(sentAt);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} horas';
    if (diff.inDays == 1) return 'Ayer, 3:00 PM';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${sentAt.day.toString().padLeft(2, '0')}/${sentAt.month.toString().padLeft(2, '0')}/${sentAt.year}';
  }

  List<Map<String, dynamic>> _fallbackNotifications() => [
        {
          'type': 'reserva',
          'title': '¡Reserva Confirmada!',
          'titleEmoji': '🎉',
          'description':
              'Tu Mazda CX-5 está listo. Recógelo el 22 Feb a las 8:00 AM en Av. El Dorado.',
          'time': 'Hace 2 horas',
          'unread': true,
          'emoji': '✅',
          'sentAt': DateTime.now(),
        },
        {
          'type': 'recordatorio',
          'title': 'Recordatorio de Devolución',
          'titleEmoji': '⏰',
          'description':
              'Tu Tesla Model 3 debe ser devuelto mañana a las 6:00 PM. No olvides revisar el estado del vehículo.',
          'time': 'Ayer, 3:00 PM',
          'unread': true,
          'emoji': '⏰',
          'sentAt': DateTime.now().subtract(const Duration(hours: 20)),
        },
        {
          'type': 'promo',
          'title': '¡Oferta Exclusiva!',
          'titleEmoji': '🔥',
          'description':
              '30% de descuento en alquileres de más de 3 días este fin de semana. Usa el código FLEXIWEEK.',
          'time': 'Hace 2 días',
          'unread': false,
          'emoji': '🎁',
          'sentAt': DateTime.now().subtract(const Duration(days: 2)),
        },
      ];

  void _markAllAsRead() => setState(() {
        for (var n in _notifications) {
          n['unread'] = false;
        }
        _unreadCount = 0;
      });
  void _markAsRead(Map<String, dynamic> n) => setState(() {
        if (n['unread'] == true) {
          n['unread'] = false;
          if (_unreadCount > 0) _unreadCount--;
        }
      });
  void _deleteNotification(Map<String, dynamic> n) => setState(() {
        if (n['unread'] == true && _unreadCount > 0) _unreadCount--;
        _notifications.remove(n);
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Stack(children: [
        Positioned(
          right: -40,
          top: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notificaciones',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (_unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('$_unreadCount sin leer',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              if (_unreadCount > 0)
                GestureDetector(
                  onTap: _markAllAsRead,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text('Leer todo',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
            ],
          ),
        )),
      ]),
    );
  }

  // ─── TABS ────────────────────────────────────────────────────────
  Widget _buildTabs() {
    final tabs = ['Todas', 'Reservas', 'Recordatorios', 'Promos'];
    return Container(
      color: _cardBg,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: tabs
              .map((tab) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildTabChip(tab),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabChip(String tab) {
    final isSelected = _selectedTab == tab;
    Widget? leading;
    if (tab == 'Reservas') {
      leading = const Text('✅', style: TextStyle(fontSize: 13));
    } else if (tab == 'Recordatorios') {
      leading = const Text('⏰', style: TextStyle(fontSize: 13));
    } else if (tab == 'Promos') {
      leading = const Text('🎁', style: TextStyle(fontSize: 13));
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: _borderColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 5)],
            Text(
              tab,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : _textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LIST ────────────────────────────────────────────────────────
  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _selectedTab == 'Todas'
        ? _notifications
        : _notifications.where((n) {
            if (_selectedTab == 'Reservas') return n['type'] == 'reserva';
            if (_selectedTab == 'Recordatorios') {
              return n['type'] == 'recordatorio';
            }
            if (_selectedTab == 'Promos') return n['type'] == 'promo';
            return true;
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textSub,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildCard(filtered[i]),
    );
  }

  // ─── NOTIFICATION CARD ───────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> n) {
    final bool isUnread = n['unread'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF4F46E5).withValues(alpha: 0.4)
              : _borderColor,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji icon box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getIconBgColor(n['type'] as String, _isDark),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      n['emoji'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with inline emoji
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: n['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: ' ${n['titleEmoji']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        n['description'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _textSub,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Unread blue dot
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row: time + actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  n['time'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _textSub,
                  ),
                ),
                Row(
                  children: [
                    // "Marcar leído" for unread / "No leído" (blue) for read
                    if (isUnread)
                      GestureDetector(
                        onTap: () => _markAsRead(n),
                        child: Text(
                          'Marcar leido',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4F46E5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'No leído',
                        style: GoogleFonts.inter(
                          color: _textSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Delete icon
                    GestureDetector(
                      onTap: () => _deleteNotification(n),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

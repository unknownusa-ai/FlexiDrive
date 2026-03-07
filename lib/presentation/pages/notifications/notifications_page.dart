import 'package:flutter/material.dart';

import '../home/home_page.dart';
import 'widgets/chip_pestana_notificaciones.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedIndex = 2; // Alertas tab selected
  String _selectedTab = 'Todas';
  int _unreadCount = 2;

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['unread'] = false;
      }
      _unreadCount = 0;
    });
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      if (notification['unread'] == true) {
        notification['unread'] = false;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
    });
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    setState(() {
      if (notification['unread'] == true) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      notifications.remove(notification);
    });
  }

  // Sample notifications data
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'reserva',
      'title': '¡Reserva Confirmada! 🎉',
      'description':
          'Tu Mazda CX-5 está listo. Recógelo el 22 Feb a las 8:00 AM en Av. El Dorado.',
      'time': 'Hace 2 horas',
      'unread': true,
      'icon': '✓',
      'iconColor': Color(0xFF10B981),
      'iconBgColor': Color(0xFFD1F2DF),
    },
    {
      'type': 'recordatorio',
      'title': 'Recordatorio de Devolución 😢',
      'description':
          'Tu Tesla Model 3 debe ser devuelto mañana a las 6:00 PM. No olvides revisar el estado del vehículo.',
      'time': 'Ayer, 3:00 PM',
      'unread': true,
      'icon': '⏰',
      'iconColor': Color(0xFFEF4444),
      'iconBgColor': Color(0xFFEEC2C2),
    },
    {
      'type': 'promo',
      'title': '¡Oferta Exclusiva! 🔥',
      'description':
          '30% de descuento en alquileres de más de 3 días este fin de semana. Usa el código FLEXIWEEK.',
      'time': 'Hace 2 días',
      'unread': false,
      'icon': '🎁',
      'iconColor': Color(0xFFF59E0B),
      'iconBgColor': Color(0xFFFFECD2),
    },
    {
      'type': 'auto',
      'title': 'Nuevo Vehículo Disponible 🚗',
      'description':
          'El Porsche 718 Cayman ahora está disponible en tu zona. ¡Sé el primero en reservarlo!',
      'time': 'Hace 3 días',
      'unread': false,
      'icon': '🆕',
      'iconColor': Color(0xFF3B82F6),
      'iconBgColor': Color(0xFFCCE5FF),
    },
    {
      'type': 'promo',
      'title': 'Programa de Referidos 👥',
      'description':
          'Invita a un amigo y gana \$50,000 COP en crédito FlexiDrive para tu próxima renta.',
      'time': 'Hace 5 días',
      'unread': false,
      'icon': '💵',
      'iconColor': Color(0xFF8B5CF6),
      'iconBgColor': Color(0xFFE9D5FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Tabs
          _buildTabs(),
          // Notifications List
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5B6FED),
            Color(0xFF6B5BCD),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Burbujita decorativa transparente
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (_unreadCount > 0)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_unreadCount sin leer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Leer todo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildTabs() {
    final tabs = ['Todas', 'Reservas', 'Recordatorios', 'Promos'];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: tabs
              .map((tab) => Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: ChipPestanaNotificaciones(
                      label: tab,
                      isSelected: _selectedTab == tab,
                      leading: _buildTabLeading(tab),
                      onTap: () => setState(() => _selectedTab = tab),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget? _buildTabLeading(String tab) {
    if (tab == 'Reservas') {
      return Icon(
        Icons.check_circle,
        color: Color(0xFF10B981),
        size: 16,
      );
    }

    if (tab == 'Recordatorios') {
      return Text(
        '⏰',
        style: TextStyle(fontSize: 14),
      );
    }

    if (tab == 'Promos') {
      return Text(
        '🎁',
        style: TextStyle(fontSize: 14),
      );
    }

    return null;
  }

  Widget _buildNotificationsList() {
    // Filter notifications based on selected tab
    List<Map<String, dynamic>> filteredNotifications = notifications;

    if (_selectedTab == 'Reservas') {
      filteredNotifications =
          notifications.where((n) => n['type'] == 'reserva').toList();
    } else if (_selectedTab == 'Recordatorios') {
      filteredNotifications =
          notifications.where((n) => n['type'] == 'recordatorio').toList();
    } else if (_selectedTab == 'Promos') {
      filteredNotifications =
          notifications.where((n) => n['type'] == 'promo').toList();
    }

    return Container(
      color: Color(0xFFF9FAFB),
      child: filteredNotifications.isEmpty
          ? Center(
              child: Text(
                'No hay notificaciones',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              notification['unread'] ? Color(0xFF5B6FED) : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon, Title/Description, and Unread indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: notification['iconBgColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      notification['icon'],
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Title and Description Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // Unread dot
                if (notification['unread'])
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFF5B6FED),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            // Footer: Time and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    if (notification['unread'])
                      GestureDetector(
                        onTap: () => _markAsRead(notification),
                        child: Text(
                          'Marcar leído',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (notification['unread']) SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _deleteNotification(notification),
                      child: Icon(
                        Icons.delete_outline,
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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Inicio', 0),
              _buildNavItem(Icons.description_outlined, 'Reservas', 1),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 2),
              _buildNavItem(Icons.person_outline, 'Perfil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B6FED).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  isSelected ? const Color(0xFF5B6FED) : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? const Color(0xFF5B6FED) : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

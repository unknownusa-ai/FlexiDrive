import 'package:flutter/material.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';
import 'widgets/chip_pestana_notificaciones.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedTab = 'Todas';
  int _unreadCount = 2;

  void _markAllAsRead() => setState(() {
    for (var n in notifications) n['unread'] = false;
    _unreadCount = 0;
  });

  void _markAsRead(Map<String, dynamic> n) => setState(() {
    if (n['unread'] == true) { n['unread'] = false; if (_unreadCount > 0) _unreadCount--; }
  });

  void _deleteNotification(Map<String, dynamic> n) => setState(() {
    if (n['unread'] == true && _unreadCount > 0) _unreadCount--;
    notifications.remove(n);
  });

  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'reserva',
      'title': '¡Reserva Confirmada!',
      'description': 'Tu Mazda CX-5 está listo. Recógelo el 22 Feb a las 8:00 AM en Av. El Dorado.',
      'time': 'Hace 2 horas',
      'unread': true,
      'icon': Icons.check,
      'iconColor': const Color(0xFF10B981),
      'iconBgColor': const Color(0xFFD1F2DF),
    },
    {
      'type': 'recordatorio',
      'title': 'Recordatorio de Devolución',
      'description': 'Tu Tesla Model 3 debe ser devuelto mañana a las 6:00 PM. No olvides revisar el estado del vehículo.',
      'time': 'Ayer, 3:00 PM',
      'unread': true,
      'icon': Icons.access_time,
      'iconColor': const Color(0xFFEF4444),
      'iconBgColor': const Color(0xFFEEC2C2),
    },
    {
      'type': 'promo',
      'title': '¡Oferta Exclusiva!',
      'description': '30% de descuento en alquileres de más de 3 días este fin de semana. Usa el código FLEXIWEEK.',
      'time': 'Hace 2 días',
      'unread': false,
      'icon': Icons.card_giftcard,
      'iconColor': const Color(0xFFF59E0B),
      'iconBgColor': const Color(0xFFFFECD2),
    },
    {
      'type': 'auto',
      'title': 'Nuevo Vehículo Disponible',
      'description': 'El Porsche 718 Cayman ahora está disponible en tu zona. ¡Sé el primero en reservarlo!',
      'time': 'Hace 3 días',
      'unread': false,
      'icon': Icons.new_releases,
      'iconColor': const Color(0xFF3B82F6),
      'iconBgColor': const Color(0xFFCCE5FF),
    },
    {
      'type': 'promo',
      'title': 'Programa de Referidos',
      'description': 'Invita a un amigo y gana \$50,000 COP en crédito FlexiDrive para tu próxima renta.',
      'time': 'Hace 5 días',
      'unread': false,
      'icon': Icons.attach_money,
      'iconColor': const Color(0xFF8B5CF6),
      'iconBgColor': const Color(0xFFE9D5FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        _buildHeader(),
        _buildTabs(),
        Expanded(child: _buildNotificationsList()),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B6FED), Color(0xFF6B5BCD)],
        ),
      ),
      child: Stack(children: [
        Positioned(
          right: -40, top: -30,
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Notificaciones',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (_unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$_unreadCount sin leer',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ]),
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _markAllAsRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Leer todo',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Todas', 'Reservas', 'Recordatorios', 'Promos'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: tabs.map((tab) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChipPestanaNotificaciones(
              label: tab,
              isSelected: _selectedTab == tab,
              leading: _buildTabLeading(tab),
              onTap: () => setState(() => _selectedTab = tab),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget? _buildTabLeading(String tab) {
    if (tab == 'Reservas')      return const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16);
    if (tab == 'Recordatorios') return const Icon(Icons.access_time,  color: Color(0xFFEF4444), size: 16);
    if (tab == 'Promos')        return const Icon(Icons.card_giftcard, color: Color(0xFFF59E0B), size: 16);
    return null;
  }

  Widget _buildNotificationsList() {
    final filtered = _selectedTab == 'Todas'
        ? notifications
        : notifications.where((n) {
            if (_selectedTab == 'Reservas')      return n['type'] == 'reserva';
            if (_selectedTab == 'Recordatorios') return n['type'] == 'recordatorio';
            if (_selectedTab == 'Promos')        return n['type'] == 'promo';
            return true;
          }).toList();

    return Container(
      color: const Color(0xFFF9FAFB),
      child: filtered.isEmpty
          ? Center(child: Text('No hay notificaciones',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              itemCount: filtered.length,
              itemBuilder: (context, i) => _buildNotificationCard(filtered[i]),
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: n['unread'] == true ? const Color(0xFF5B6FED) : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ✅ Usar Icon() porque 'icon' es IconData
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: n['iconBgColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  n['icon'] as IconData,
                  color: n['iconColor'] as Color,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['title'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937), height: 1.2)),
              const SizedBox(height: 4),
              Text(n['description'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 8),
            if (n['unread'] == true)
              Container(width: 12, height: 12,
                  decoration: const BoxDecoration(color: Color(0xFF5B6FED), shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(n['time'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Row(children: [
              if (n['unread'] == true) ...[
                GestureDetector(
                  onTap: () => _markAsRead(n),
                  child: const Text('Marcar leído',
                      style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
              ],
              GestureDetector(
                onTap: () => _deleteNotification(n),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }
}
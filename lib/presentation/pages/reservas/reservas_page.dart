import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_page.dart';
import '../notifications/notifications_page.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  int _selectedIndex = 1; // Reservas tab selected
  String _selectedFilter = 'Activas';

  // Sample data
  final int _activasCount = 1;
  final int _finalizadasCount = 2;
  final int _canceladasCount = 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Column(
          children: [
            // Header with Statistics Cards overlapping
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -45,
                  child: _buildStatisticsCards(),
                ),
              ],
            ),
            SizedBox(height: 58),
            // Filter Buttons
            _buildFilterButtons(),
            SizedBox(height: 20),
            // Reservations List
            Expanded(
              child: _buildReservationsList(),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B6FED),
            Color(0xFF7B68EE),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Reservas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$_activasCount reserva activa',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      height: 86,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              count: _activasCount,
              label: 'Activas',
              color: Color(0xFFD1FAE5),
              textColor: Color(0xFF10B981),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              count: _finalizadasCount,
              label: 'Finalizadas',
              color: Color(0xFFDBEAFE),
              textColor: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              count: _canceladasCount,
              label: 'Canceladas',
              color: Color(0xFFFEE2E2),
              textColor: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int count,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 27,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          SizedBox(height: 1),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color(0xFFDCE2EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                label: 'Activas',
                leadingWidget: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                isSelected: _selectedFilter == 'Activas',
                onTap: () => setState(() => _selectedFilter = 'Activas'),
              ),
            ),
            Expanded(
              child: _buildFilterButton(
                label: 'Historial',
                leadingWidget: Icon(
                  Icons.description_outlined,
                  color: _selectedFilter == 'Historial'
                      ? Color(0xFF1F2937)
                      : Color(0xFF9CA3AF),
                  size: 18,
                ),
                isSelected: _selectedFilter == 'Historial',
                onTap: () => setState(() => _selectedFilter = 'Historial'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required Widget leadingWidget,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leadingWidget,
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Color(0xFF1F2937) : Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList() {
    // For now, showing active reservations
    if (_selectedFilter == 'Activas') {
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildReservationCard(
            vehicleName: 'Mazda CX-5 2024',
            code: 'FXD-2024-0089',
            price: '\$ 440,000',
            startDate: '22 Feb 2026',
            endDate: '24 Feb 2026',
            location: 'Av. El Dorado, Bogotá',
            progress: 0.4,
            status: 'Activa',
            statusColor: Color(0xFF06B6D4),
            imageUrl:
                'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&q=80', // Example car image
          ),
        ],
      );
    } else {
      // Historial (finalizadas y canceladas)
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildReservationCard(
            vehicleName: 'Tesla Model 3 2024',
            code: 'FXD-2024-0087',
            price: '\$ 380,000',
            startDate: '18 Feb 2026',
            endDate: '20 Feb 2026',
            location: 'Cra 7, Bogotá',
            progress: 1.0,
            status: 'Finalizada',
            statusColor: Color(0xFF3B82F6),
            imageUrl:
                'https://images.unsplash.com/photo-1560958089-b8a63c50ce20?w=800&q=80',
          ),
          SizedBox(height: 16),
          _buildReservationCard(
            vehicleName: 'Mercedes GLC 2024',
            code: 'FXD-2024-0086',
            price: '\$ 520,000',
            startDate: '10 Feb 2026',
            endDate: '12 Feb 2026',
            location: 'Av. Paseo Consistorial, Bogotá',
            progress: 0.0,
            status: 'Cancelada',
            statusColor: Color(0xFFEF4444),
            imageUrl:
                'https://images.unsplash.com/photo-1553882900-d5160ca3na01?w=800&q=80',
          ),
        ],
      );
    }
  }

  Widget _buildReservationCard({
    required String vehicleName,
    required String code,
    required String price,
    required String startDate,
    required String endDate,
    required String location,
    required double progress,
    required String status,
    required Color statusColor,
    required String imageUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image (compact)
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE5E7EB),
                    Color(0xFFD1D5DB),
                  ],
                ),
              ),
              child: imageUrl.isEmpty
                  ? _buildPlaceholder()
                  : imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPlaceholder();
                          },
                        )
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        ),
            ),
          ),
          // Card content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicleName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B6FED),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  code,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '$startDate → $endDate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                // Ver Detalles button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ver detalles action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B6FED),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver Detalles',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 64,
          color: Color(0xFF9CA3AF),
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
              _buildNavItem(Icons.home_outlined, 'Inicio', 0),
              _buildNavItem(Icons.description, 'Reservas', 1),
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
    final hasNotification = index == 2; // Alertas has notification

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate to Home
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

        if (index == 2) {
          // Navigate to Notifications
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
          return;
        }

        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
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
                  color: isSelected
                      ? const Color(0xFF5B6FED)
                      : Colors.grey.shade400,
                  size: 24,
                ),
              ),
              if (hasNotification)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color:
                  isSelected ? const Color(0xFF5B6FED) : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

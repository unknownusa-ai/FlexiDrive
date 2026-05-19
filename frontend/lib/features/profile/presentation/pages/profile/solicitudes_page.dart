import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flexidrive/core/api/api_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexidrive/core/utils/responsive_utils.dart';
import 'package:flexidrive/features/accounts/application/use_cases/account_access_use_case.dart';
import 'package:flexidrive/features/reservations/application/use_cases/reservation_access_use_case.dart';
import 'package:flexidrive/features/publications/application/use_cases/publication_access_use_case.dart';
import 'package:flexidrive/features/vehicles/application/use_cases/vehicle_inventory_use_case.dart';
import 'package:flexidrive/features/reservations/domain/entities/reservation_models.dart';
import 'package:flexidrive/features/notifications/application/use_cases/notification_access_use_case.dart';
import 'package:flexidrive/injection_container.dart';
import 'package:flexidrive/core/widgets/flexi_vehicle_image.dart';
import 'package:flexidrive/core/utils/vehicle_image_resolver.dart';

// PÃƒÂ¡gina de solicitudes de reserva
// Muestra las solicitudes de renta recibidas por el arrendador
class SolicitudesPage extends StatefulWidget {
  // Tab inicial a mostrar
  final int initialTab;
  const SolicitudesPage({super.key, this.initialTab = 0});

  @override
  State<SolicitudesPage> createState() => SolicitudesPageState();
}

// Estado de la pÃƒÂ¡gina de solicitudes
// Maneja las pestaÃƒÂ±as y carga de solicitudes
class SolicitudesPageState extends State<SolicitudesPage>
    with SingleTickerProviderStateMixin {
  static const _solicitudCategoryId = 1;
  static const _pagoCategoryId = 2;

  // Controlador de pestaÃƒÂ±as
  late TabController _tabController;
  // ÃƒÂndice de la pestaÃƒÂ±a seleccionada
  int _selectedTabIndex = 1;
  final ReservationAccessUseCase _reservationDb =
      InjectionContainer.instance.reservationAccessUseCase;
  final PublicationAccessUseCase _publicationDb =
      InjectionContainer.instance.publicationAccessUseCase;
  final VehicleInventoryUseCase _vehiculoService =
      InjectionContainer.instance.vehicleInventoryUseCase;
  final AccountAccessUseCase _accountRepository =
      InjectionContainer.instance.accountAccessUseCase;
  final NotificationAccessUseCase _notificationDb =
      InjectionContainer.instance.notificationAccessUseCase;

  // Data management
  List<ReservationModel> _allReservations = [];
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _publications = [];
  final Map<int, String> _accountNamesByUserId = {};
  final Map<int, String> _accountEmailsByUserId = {};
  bool _isLoading = true;

  // Current user ID in session
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _selectedTabIndex = widget.initialTab;
    _tabController.addListener(() {
      if (_selectedTabIndex != _tabController.index) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _loadData();
  }

  @override
  void didUpdateWidget(SolicitudesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void setTab(int index) {
    if (index >= 0 && index < 3) {
      _tabController.animateTo(index);
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final currentUser = await _accountRepository.getCurrentUser();
      _currentUserId = currentUser?.id;

      // Load reservations
      await _reservationDb.loadIfNeeded();
      _allReservations = List.from(_reservationDb.reservations);

      // Load vehicles and users
      await _vehiculoService.init();
      _vehicles = _vehiculoService.vehiculos;
      _users = _vehiculoService.usuarios;
      try {
        final accountUsers = await _accountRepository.getUsers();
        _accountNamesByUserId
          ..clear()
          ..addEntries(
            accountUsers.map(
              (user) => MapEntry(user.id, _normalizeText(user.fullName)),
            ),
          );
        _accountEmailsByUserId
          ..clear()
          ..addEntries(
            accountUsers.map(
              (user) => MapEntry(user.id, _normalizeText(user.email)),
            ),
          );
      } catch (_) {
        _accountNamesByUserId.clear();
        _accountEmailsByUserId.clear();
      }

      for (final rawUser in _users) {
        final id = _asInt(rawUser['usuario_id'] ?? rawUser['id']);
        if (id <= 0) continue;
        final rawName = _normalizeText(
          rawUser['nombre_completo'] ??
              rawUser['full_name'] ??
              rawUser['nombre'],
        );
        final rawEmail = _normalizeText(
          rawUser['correo'] ?? rawUser['email'] ?? rawUser['username'],
        );
        if (rawName.isNotEmpty && (_accountNamesByUserId[id] ?? '').isEmpty) {
          _accountNamesByUserId[id] = rawName;
        }
        if (rawEmail.isNotEmpty && (_accountEmailsByUserId[id] ?? '').isEmpty) {
          _accountEmailsByUserId[id] = rawEmail;
        }
      }

      final reservationUserIds =
          _allReservations.map((reservation) => reservation.userId).toSet();
      for (final userId in reservationUserIds) {
        final name = _normalizeText(_accountNamesByUserId[userId]);
        if (name.isNotEmpty) continue;
        try {
          final payload = await ApiClient.instance.getMap('users/$userId');
          final apiName = _normalizeText(
            payload['nombre_completo'] ??
                payload['full_name'] ??
                payload['nombre'],
          );
          final apiEmail = _normalizeText(
            payload['correo'] ?? payload['email'] ?? payload['username'],
          );
          if (apiName.isNotEmpty) _accountNamesByUserId[userId] = apiName;
          if (apiEmail.isNotEmpty) _accountEmailsByUserId[userId] = apiEmail;
        } catch (_) {
          // keep fallbacks
        }
      }

      // Load publications
      _publications = await _loadPublications();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadPublications() async {
    try {
      await _publicationDb.loadIfNeeded();
      return _publicationDb.publications
          .map((publication) => publication.toJson())
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get reservations filtered by status for current user's vehicles
  List<ReservationModel> _getReservationsByStatus(int statusId) {
    return _allReservations.where((reservation) {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return false;

      final publication = _findPublicationById(reservation.publicationId);
      return publication != null &&
          publication['usuario_id'] == currentUserId &&
          reservation.statusId == statusId;
    }).toList();
  }

  List<ReservationModel> _getCompletedReservations() {
    return _allReservations.where((reservation) {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return false;

      final publication = _findPublicationById(reservation.publicationId);
      if (publication == null || publication['usuario_id'] != currentUserId) {
        return false;
      }
      return reservation.statusId == 2 || reservation.statusId == 3;
    }).toList();
  }

  // Find publication by ID
  Map<String, dynamic>? _findPublicationById(int publicationId) {
    try {
      return _publications
          .firstWhere((p) => p['publicacion_id'] == publicationId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? _getVehicleForReservation(
      ReservationModel reservation) {
    final publication = _findPublicationById(reservation.publicationId);
    if (publication == null) return null;

    final rawVehicleId = publication['vehiculo_id'];
    final vehicleId =
        rawVehicleId is int ? rawVehicleId : int.tryParse('$rawVehicleId');
    if (vehicleId == null) return null;
    return _getVehicleById(vehicleId);
  }

  // Get vehicle info
  Map<String, dynamic>? _getVehicleById(int vehicleId) {
    try {
      return _vehicles.firstWhere(
        (v) => _asInt(v['vehiculo_id'] ?? v['id']) == vehicleId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user info
  Map<String, dynamic>? _getUserById(int userId) {
    try {
      return _users.firstWhere(
        (u) => _asInt(u['usuario_id'] ?? u['id']) == userId,
      );
    } catch (e) {
      return null;
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  String _normalizeText(dynamic value) {
    if (value == null) return '';
    final text = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return '';
    final lowered = text.toLowerCase();
    if (lowered == 'null' || lowered == 'undefined' || lowered == 'nan') {
      return '';
    }
    return _fixMojibake(text);
  }

  String _resolveUserName(int userId, Map<String, dynamic>? user) {
    final mappedName = _normalizeText(_accountNamesByUserId[userId]);
    if (mappedName.isNotEmpty) return mappedName;
    final mappedEmail = _normalizeText(_accountEmailsByUserId[userId]);
    if (mappedEmail.isNotEmpty) return mappedEmail;

    if (user == null) return 'Usuario #$userId';
    final fullName = _normalizeText(
      user['nombre_completo'] ?? user['full_name'] ?? user['nombre'],
    );
    if (fullName.isNotEmpty) return fullName;
    final email = _normalizeText(
      user['correo'] ?? user['email'] ?? user['username'],
    );
    if (email.isNotEmpty) return email;
    return 'Usuario #$userId';
  }

  String _resolveVehicleName(Map<String, dynamic>? vehicle) {
    if (vehicle == null) return 'Vehículo';
    final explicitName = _normalizeText(vehicle['nombre']);
    if (explicitName.isNotEmpty) return explicitName;

    final brand = _normalizeText(vehicle['marca']);
    final line = _normalizeText(vehicle['linea']);
    final model = _normalizeText(vehicle['modelo']);
    final year = _normalizeText(vehicle['anio']);

    final rawModel = line.isNotEmpty ? line : model;
    var cleanedModel = rawModel;
    if (brand.isNotEmpty &&
        cleanedModel.toLowerCase().startsWith(brand.toLowerCase())) {
      cleanedModel = cleanedModel.substring(brand.length).trimLeft();
    }

    var name = [
      if (brand.isNotEmpty) brand,
      if (cleanedModel.isNotEmpty) cleanedModel,
    ].join(' ').trim();
    if (name.isEmpty) name = rawModel.isEmpty ? 'Vehículo' : rawModel;

    final hasYear = RegExp(r'^\d{4}$').hasMatch(year);
    if (hasYear && !name.contains(year)) {
      return '$name $year';
    }
    return name;
  }

  String _resolveVehicleImage(Map<String, dynamic>? vehicle) {
    return VehicleImageResolver.resolveFromVehicle(
      vehicle,
      preferredImage: vehicle?['imagen']?.toString(),
      fallback: 'assets/imagenes_carros/cx5.jpg',
    );
  }

  String _fixMojibake(String input) {
    if (!input.contains('Ã') && !input.contains('Â') && !input.contains('â')) {
      return input;
    }
    try {
      return utf8.decode(latin1.encode(input));
    } catch (_) {
      return input;
    }
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
            _buildTitleSection(isSmallPhone),
            _buildTabBar(isSmallPhone),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendientesList(isSmallPhone),
                  _buildActivasList(isSmallPhone),
                  _buildCompletadasList(isSmallPhone),
                ],
              ),
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
        isSmallPhone ? 14 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitudes',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 4 : 6),
          Text(
            'Gestiona las rentas de tus vehículos',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 15,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardTheme.color,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 12 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitudes de Renta',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallPhone ? 4 : 6),
          Text(
            'Gestiona las solicitudes de tus vehículos',
            style: GoogleFonts.inter(
              fontSize: isSmallPhone ? 13 : 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isSmallPhone) {
    final theme = Theme.of(context);
    final pendingCount =
        _getReservationsByStatus(1).length; // status_id 1 = pendiente
    final activeCount =
        _getReservationsByStatus(4).length; // status_id 4 = activa
    final completedCount = _getCompletedReservations().length; // 2 o 3

    return Container(
      color: theme.cardTheme.color,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 12 : 16,
        vertical: isSmallPhone ? 10 : 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomTab(
              label: 'Pendientes',
              count: '$pendingCount',
              isActive: _selectedTabIndex == 0,
              onTap: () {
                setState(() => _selectedTabIndex = 0);
                _tabController.animateTo(0);
              },
              isSmallPhone: isSmallPhone,
              activeColor: const Color(0xFFF59E0B),
            ),
          ),
          SizedBox(width: isSmallPhone ? 8 : 10),
          Expanded(
            child: _buildCustomTab(
              label: 'Activas',
              count: '$activeCount',
              isActive: _selectedTabIndex == 1,
              onTap: () {
                setState(() => _selectedTabIndex = 1);
                _tabController.animateTo(1);
              },
              isSmallPhone: isSmallPhone,
            ),
          ),
          SizedBox(width: isSmallPhone ? 8 : 10),
          Expanded(
            child: _buildCustomTab(
              label: 'Completadas',
              count: '$completedCount',
              isActive: _selectedTabIndex == 2,
              onTap: () {
                setState(() => _selectedTabIndex = 2);
                _tabController.animateTo(2);
              },
              isSmallPhone: isSmallPhone,
              activeColor: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab({
    required String label,
    required String count,
    required bool isActive,
    required VoidCallback onTap,
    required bool isSmallPhone,
    Color activeColor = const Color(0xFF10B981),
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 8 : 12,
          vertical: isSmallPhone ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode ? const Color(0xFF3B2510) : const Color(0xFFFFFBEB))
              : (isDarkMode ? const Color(0xFF334155) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFE2E8F0),
            width: isActive ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 11 : 14,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendientesList(bool isSmallPhone) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final pendingReservations = _getReservationsByStatus(1);

    if (pendingReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay solicitudes pendientes',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: pendingReservations.map((reservation) {
        final user = _getUserById(reservation.userId);
        final vehicle = _getVehicleForReservation(reservation);

        return _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: _resolveUserName(reservation.userId, user),
          userImage: 'https://i.pravatar.cc/150?img=${reservation.userId}',
          userRating: '4.8', // Default rating
          userType: 'Arrendatario',
          vehicleName: _resolveVehicleName(vehicle),
          vehicleImage: _resolveVehicleImage(vehicle),
          startDate:
              '${reservation.startDate.day}/${reservation.startDate.month}/${reservation.startDate.year}',
          endDate:
              '${reservation.endDate.day}/${reservation.endDate.month}/${reservation.endDate.year}',
          location: _normalizeText(reservation.pickupLocation),
          totalPrice: '\$${reservation.totalValue.toStringAsFixed(0)}',
          status: 'pending',
          reservation: reservation,
        );
      }).toList(),
    );
  }

  Widget _buildActivasList(bool isSmallPhone) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final activeReservations = _getReservationsByStatus(4);

    if (activeReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay rentas activas',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: activeReservations.map((reservation) {
        final user = _getUserById(reservation.userId);
        final vehicle = _getVehicleForReservation(reservation);

        return _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: _resolveUserName(reservation.userId, user),
          userImage: 'https://i.pravatar.cc/150?img=${reservation.userId}',
          userRating: '4.8',
          userType: 'Arrendatario',
          vehicleName: _resolveVehicleName(vehicle),
          vehicleImage: _resolveVehicleImage(vehicle),
          startDate:
              '${reservation.startDate.day}/${reservation.startDate.month}/${reservation.startDate.year}',
          endDate:
              '${reservation.endDate.day}/${reservation.endDate.month}/${reservation.endDate.year}',
          location: _normalizeText(reservation.pickupLocation),
          totalPrice: '\$${reservation.totalValue.toStringAsFixed(0)}',
          status: 'active',
          reservation: reservation,
        );
      }).toList(),
    );
  }

  Widget _buildCompletadasList(bool isSmallPhone) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final completedReservations = _getCompletedReservations();

    if (completedReservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay rentas completadas',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(isSmallPhone ? 14 : 16),
      children: completedReservations.map((reservation) {
        final user = _getUserById(reservation.userId);
        final vehicle = _getVehicleForReservation(reservation);

        return _buildRequestCard(
          isSmallPhone: isSmallPhone,
          userName: _resolveUserName(reservation.userId, user),
          userImage: 'https://i.pravatar.cc/150?img=${reservation.userId}',
          userRating: '4.8',
          userType: 'Arrendatario',
          vehicleName: _resolveVehicleName(vehicle),
          vehicleImage: _resolveVehicleImage(vehicle),
          startDate:
              '${reservation.startDate.day}/${reservation.startDate.month}/${reservation.startDate.year}',
          endDate:
              '${reservation.endDate.day}/${reservation.endDate.month}/${reservation.endDate.year}',
          location: _normalizeText(reservation.pickupLocation),
          totalPrice: '\$${reservation.totalValue.toStringAsFixed(0)}',
          status: 'completed',
          reservation: reservation,
        );
      }).toList(),
    );
  }

  Widget _buildRequestCard({
    required bool isSmallPhone,
    required String userName,
    required String userImage,
    required String userRating,
    required String userType,
    required String vehicleName,
    required String vehicleImage,
    required String startDate,
    required String endDate,
    required String location,
    required String totalPrice,
    required String status,
    ReservationModel? reservation,
  }) {
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFFF7ED);
        statusText = 'PENDIENTE';
        break;
      case 'active':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFE7F7F2);
        statusText = 'ACTIVA';
        break;
      case 'completed':
        statusColor = const Color(0xFF64748B);
        statusBgColor = const Color(0xFFF1F5F9);
        statusText = 'COMPLETADA';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusBgColor = const Color(0xFFF1F5F9);
        statusText = 'DESCONOCIDO';
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con usuario y badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fixMojibake(userName),
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 17 : 19,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fixMojibake(userRating),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '• $userType',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallPhone ? 10 : 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // VehÃƒÂ­culo con imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlexiVehicleImage(
                  imagePath: vehicleImage,
                  width: isSmallPhone ? 90 : 100,
                  height: isSmallPhone ? 72 : 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fixMojibake(vehicleName),
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fixMojibake('$startDate - $endDate'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Detalles con iconos
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fechas',
            value: '$startDate → $endDate',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Ubicación',
            value: location,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.attach_money,
            label: 'Monto total',
            value: totalPrice,
            valueColor: const Color(0xFF10B981),
            valueBold: true,
          ),

          // Botones solo para pendientes
          if (status == 'pending' && reservation != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(reservation),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(
                      'Rechazar',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDialog(reservation),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      'Aprobar',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fixMojibake(label),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _fixMojibake(value),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog(ReservationModel reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¿Aprobar solicitud?',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El usuario será notificado y podrá proceder con el pago. Asegúrate de que tu vehículo estará disponible en las fechas solicitadas.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveReservation(reservation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirmar',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(ReservationModel reservation) {
    String? selectedReason;
    final reasons = [
      'Fechas no disponibles',
      'Mantenimiento programado',
      'Vehículo ya rentado',
      'Perfil del usuario no verificado',
      'Otro motivo',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cancel,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Rechazar solicitud?',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el motivo del rechazo:',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              // ignore_for_file: deprecated_member_use
              ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(
                      reason,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    value: reason,
                    groupValue: selectedReason,
                    activeColor: const Color(0xFFEF4444),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => selectedReason = value);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.pop(context);
                      _rejectReservation(reservation, selectedReason!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Rechazar',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveReservation(ReservationModel reservation) async {
    try {
      // Update reservation status from pending (1) to active (4)
      final updatedReservation = ReservationModel(
        id: reservation.id,
        code: reservation.code,
        userId: reservation.userId,
        publicationId: reservation.publicationId,
        paymentMethodId: reservation.paymentMethodId,
        periodTypeId: reservation.periodTypeId,
        periodCount: reservation.periodCount,
        startDate: reservation.startDate,
        endDate: reservation.endDate,
        pickupLocation: reservation.pickupLocation,
        returnLocation: reservation.returnLocation,
        totalValue: reservation.totalValue,
        statusId: 4, // Change to active
        reservationDate: reservation.reservationDate,
      );

      await _reservationDb.updateReservation(updatedReservation);
      final index = _allReservations.indexWhere((r) => r.id == reservation.id);
      if (index != -1) _allReservations[index] = updatedReservation;

      setState(() {});

      await _createApprovalNotification(reservation);
      await _createPaymentChargedNotification(updatedReservation);
      await _createPaymentReceivedNotification(updatedReservation);

      _showSuccessSnackBar('Solicitud aprobada correctamente');
    } catch (e) {
      _showErrorSnackBar('Error al aprobar solicitud: $e');
    }
  }

  Future<void> _rejectReservation(
      ReservationModel reservation, String reason) async {
    try {
      final rejectedReservation = ReservationModel(
        id: reservation.id,
        code: reservation.code,
        userId: reservation.userId,
        publicationId: reservation.publicationId,
        paymentMethodId: reservation.paymentMethodId,
        periodTypeId: reservation.periodTypeId,
        periodCount: reservation.periodCount,
        startDate: reservation.startDate,
        endDate: reservation.endDate,
        pickupLocation: reservation.pickupLocation,
        returnLocation: reservation.returnLocation,
        totalValue: reservation.totalValue,
        statusId: 3, // 3 = Cancelada/Rechazada
        reservationDate: reservation.reservationDate,
      );

      await _reservationDb.updateReservation(rejectedReservation);
      final index = _allReservations.indexWhere((r) => r.id == reservation.id);
      if (index != -1) {
        _allReservations[index] = rejectedReservation;
      }

      setState(() {});
      await _createRejectionNotification(reservation, reason);
      _showSuccessSnackBar('Solicitud rechazada');
    } catch (e) {
      _showErrorSnackBar('Error al rechazar solicitud: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _createApprovalNotification(ReservationModel reservation) async {
    try {
      final vehicle = _getVehicleForReservation(reservation);
      final vehicleName = vehicle?['nombre'] ?? 'vehiculo';
      await _notificationDb.addNotification(
        userId: reservation.userId,
        categoryId: _solicitudCategoryId,
        subject: 'Solicitud aprobada',
        description:
            'Tu solicitud ${reservation.code} para rentar el $vehicleName fue aprobada.',
      );
    } catch (e) {
      // Error creating notification - silently handle
    }
  }

  Future<void> _createRejectionNotification(
    ReservationModel reservation,
    String reason,
  ) async {
    try {
      final vehicle = _getVehicleForReservation(reservation);
      final vehicleName = vehicle?['nombre'] ?? 'vehiculo';
      await _notificationDb.addNotification(
        userId: reservation.userId,
        categoryId: _solicitudCategoryId,
        subject: 'Solicitud rechazada',
        description:
            'Tu solicitud ${reservation.code} para rentar el $vehicleName fue rechazada. Motivo: $reason.',
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _createPaymentChargedNotification(
    ReservationModel reservation,
  ) async {
    try {
      final vehicle = _getVehicleForReservation(reservation);
      final vehicleName = vehicle?['nombre'] ?? 'vehiculo';
      await _notificationDb.addNotification(
        userId: reservation.userId,
        categoryId: _pagoCategoryId,
        subject: 'Pago procesado',
        description:
            'Se procesó el cobro de la reserva ${reservation.code} por \$${reservation.totalValue.toStringAsFixed(0)} para $vehicleName.',
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _createPaymentReceivedNotification(
    ReservationModel reservation,
  ) async {
    try {
      final publication = _findPublicationById(reservation.publicationId);
      final ownerIdRaw = publication?['usuario_id'];
      final ownerId =
          ownerIdRaw is int ? ownerIdRaw : int.tryParse('$ownerIdRaw');
      if (ownerId == null) return;
      await _notificationDb.addNotification(
        userId: ownerId,
        categoryId: _pagoCategoryId,
        subject: 'Pago confirmado',
        description:
            'La reserva ${reservation.code} fue aprobada y quedó activa con cobro de \$${reservation.totalValue.toStringAsFixed(0)}.',
      );
    } catch (_) {
      // ignore
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

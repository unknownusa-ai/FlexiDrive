import 'package:flutter/material.dart';
import '../../services/vehiculo_service.dart';

/// Página que demuestra el uso de JSON + ArrayList
/// Consumiendo datos desde el VehiculoService
class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  final VehiculoService _service = VehiculoService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _vehiculos = [];
  String _filtroCategoria = 'Todos';
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Carga inicial de datos desde JSON
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    await _service.init();
    setState(() {
      _vehiculos = _service.getVehiculos();
      _isLoading = false;
    });
  }

  /// Filtrar vehículos por categoría
  void _filtrarPorCategoria(String categoria) {
    setState(() {
      _filtroCategoria = categoria;
      if (categoria == 'Todos') {
        _vehiculos = _service.getVehiculos();
      } else {
        _vehiculos = _service.getVehiculosByCategoria(categoria);
      }
    });
  }

  /// Buscar vehículos
  void _buscar(String query) {
    setState(() {
      _busqueda = query;
      if (query.isEmpty) {
        _vehiculos = _service.getVehiculos();
      } else {
        _vehiculos = _service.buscarVehiculos(query);
      }
    });
  }

  /// Agregar vehículo al ArrayList
  void _agregarVehiculo() {
    final nuevoVehiculo = {
      'marca': 'Nissan',
      'modelo': 'Sentra',
      'anio': 2023,
      'categoria': 'Sedán',
      'transmision': 'Automática',
      'puertos': 5,
      'precio_dia': 140000,
      'ubicacion': 'Bogotá',
      'propietario_id': 1,
      'imagen': 'sentra.png',
      'descripcion': 'Nuevo vehículo agregado desde la app',
      'calificacion': 4.5,
      'resenas': 0,
    };

    setState(() {
      _service.addVehiculo(nuevoVehiculo);
      _vehiculos = _service.getVehiculos();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehículo agregado al ArrayList')),
    );
  }

  /// Eliminar vehículo del ArrayList
  void _eliminarVehiculo(int id) {
    setState(() {
      _service.deleteVehiculo(id);
      _vehiculos = _service.getVehiculos();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehículo eliminado del ArrayList')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlexiDrive - Vehículos'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: _buscar,
                    decoration: InputDecoration(
                      hintText: 'Buscar por marca o modelo...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Filtros de categoría
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      'Todos',
                      'Sedán',
                      'SUV',
                      'Compacto',
                      'Premium'
                    ].map((cat) {
                      final isSelected = _filtroCategoria == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => _filtrarPorCategoria(cat),
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color(0xFF4F46E5),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Estadísticas
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('Total', _vehiculos.length.toString()),
                              _statItem(
                                'Promedio',
                                '\$${_service.getPromedioPrecios().toStringAsFixed(0)}',
                              ),
                              _statItem(
                                'Categorías',
                                _service.contarVehiculosPorCategoria().length.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lista de vehículos (ArrayList)
                Expanded(
                  child: _vehiculos.isEmpty
                      ? const Center(
                          child: Text('No hay vehículos en el ArrayList'),
                        )
                      : ListView.builder(
                          itemCount: _vehiculos.length,
                          itemBuilder: (context, index) {
                            final vehiculo = _vehiculos[index];
                            return _buildVehiculoCard(vehiculo);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarVehiculo,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F46E5),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVehiculoCard(Map<String, dynamic> vehiculo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehiculo['marca']} ${vehiculo['modelo']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${vehiculo['anio']} • ${vehiculo['categoria']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarVehiculo(vehiculo['id']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                Text(vehiculo['ubicacion']),
                const SizedBox(width: 16),
                const Icon(Icons.settings, size: 16, color: Colors.grey),
                Text(vehiculo['transmision']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${vehiculo['precio_dia']}/día',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text('${vehiculo['calificacion']}'),
                    Text(' (${vehiculo['resenas']})'),
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

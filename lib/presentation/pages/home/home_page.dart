import 'package:flutter/material.dart';
import 'package:flexidrive/presentation/pages/main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Todos';
  String _selectedDate = 'Hoy';
  String _selectedCity = 'Bogotá';

  static const _cityData = [
    {'name': 'Bogotá',        'emoji': '🏙️', 'vehicles': 48},
    {'name': 'Medellín',      'emoji': '🌸', 'vehicles': 36},
    {'name': 'Cali',          'emoji': '🎵', 'vehicles': 29},
    {'name': 'Barranquilla',  'emoji': '🌊', 'vehicles': 22},
    {'name': 'Cartagena',     'emoji': '🏖️', 'vehicles': 18},
    {'name': 'Bucaramanga',   'emoji': '🏔️', 'vehicles': 15},
    {'name': 'Pereira',       'emoji': '☕', 'vehicles': 12},
    {'name': 'Cúcuta',        'emoji': '🌄', 'vehicles': 12},
    {'name': 'Santa Marta',   'emoji': '🏝️', 'vehicles': 10},
    {'name': 'Ibagué',        'emoji': '🎶', 'vehicles': 9},
    {'name': 'Manizales',     'emoji': '🌋', 'vehicles': 8},
    {'name': 'Villavicencio', 'emoji': '🦋', 'vehicles': 7},
    {'name': 'Armenia',       'emoji': '🌺', 'vehicles': 7},
    {'name': 'Neiva',         'emoji': '🌞', 'vehicles': 6},
    {'name': 'Popayán',       'emoji': '⛪', 'vehicles': 6},
    {'name': 'Montería',      'emoji': '🐄', 'vehicles': 5},
    {'name': 'Valledupar',    'emoji': '🎸', 'vehicles': 5},
    {'name': 'Pasto',         'emoji': '🎭', 'vehicles': 5},
    {'name': 'Sincelejo',     'emoji': '🌿', 'vehicles': 4},
    {'name': 'Tunja',         'emoji': '🏛️', 'vehicles': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),
              if (_selectedCategory == 'Todos') ...[
                _buildDestacadosSection(),
                const SizedBox(height: 24),
                _buildAllVehiclesSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Sedán') ...[
                _buildSedanSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'SUV') ...[
                _buildSUVSection(),
                const SizedBox(height: 24),
              ] else if (_selectedCategory == 'Compacto') ...[
                _buildCompactoSection(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B6FED), Color(0xFF6B5BCD)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => MainPage.of(context).setIndex(3),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(Icons.person, color: Colors.grey.shade600, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Buenas tardes 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
                              Text('Carlos',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => MainPage.of(context).setIndex(2),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                            Positioned(
                              top: 8, right: 8,
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('¿A dónde vas hoy?',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🏞️', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Encuentra el vehículo perfecto para ti',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildSearchBar(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: Colors.grey.shade400, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar vehículo, marca...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showCitySelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: const Color(0xFFEEF3FF), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Color(0xFF5B6FED), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(_selectedCity,
                      style: const TextStyle(color: Color(0xFF5B6FED), fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROMO BANNER ──────────────────────────────────────────────────────────

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft, end: Alignment.centerRight,
            colors: [Color(0xFF10B981), Color(0xFF34D399)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.trending_down, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌿 Ahorra hasta un 60%',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('vs. taxi tradicional en Bogotá',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                Text('Ver más',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── DATE SELECTOR ─────────────────────────────────────────────────────────

  Widget _buildDateSelector() {
    final dates = [
      {'label': 'Hoy', 'date': '22 Feb'},
      {'label': '2 días', 'date': '23-24 Feb'},
      {'label': '1 semana', 'date': '22 Feb-1 Mar'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: dates.map((d) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildDateButton(d['label']!, d['date']!),
        )).toList(),
      ),
    );
  }

  Widget _buildDateButton(String label, String date) {
    final isSelected = _selectedDate == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedDate = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5B6FED), Color(0xFF6B5BCD)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF5B6FED).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              )
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(date, style: TextStyle(color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORIES ────────────────────────────────────────────────────────────

  Widget _buildCategories() {
    final categories = [
      {'name': 'Todos', 'icon': null},
      {'name': 'Sedán',    'icon': '🚗'},
      {'name': 'SUV',      'icon': '🚙'},
      {'name': 'Compacto', 'icon': '🚗'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: categories.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildCategoryButton(cat['name'] as String, cat['icon'] as String?),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String category, String? emoji) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B6FED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(
            color: isSelected ? const Color(0xFF5B6FED).withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 12 : 4,
            offset: const Offset(0, 2),
          )],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[Text(emoji, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8)],
            Text(category,
                style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A1A1A), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ─── VEHICLE SECTIONS ──────────────────────────────────────────────────────

  Widget _buildDestacadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('✨ Destacados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos', style: TextStyle(color: Color(0xFF4D8FF5), fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildVehicleCard(title: 'Mazda CX-5 2024', type: 'SUV', rating: 4.9, reviews: 128, price: 38000, available: true,
                  image: 'https://placehold.co/400x260/2D3436/FFFFFF/png?text=Mazda+CX-5'),
              const SizedBox(width: 16),
              _buildVehicleCard(title: 'Toyota Corolla 2024', type: 'Sedán', rating: 4.8, reviews: 245, price: 25000, available: true,
                  image: 'https://placehold.co/400x260/2D3436/FFFFFF/png?text=Toyota+Corolla'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard({required String title, required String type, required double rating,
      required int reviews, required int price, required bool available, required String image}) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(image, height: 130, width: 200, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 130, width: 200, color: Colors.grey.shade800,
                        child: Icon(Icons.directions_car, size: 50, color: Colors.white.withOpacity(0.5)))),
                Positioned(top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: type == 'SUV' ? const Color(0xFF5B6FED) : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.directions_car, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text(type, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                if (available)
                  Positioned(top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        const Text('DISPONIBLE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                const SizedBox(width: 4),
                Text('$rating', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1F2937))),
                const SizedBox(width: 2),
                Text('($reviews)', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text('\$${(price / 1000).toInt()}K',
                      style: const TextStyle(color: Color(0xFF5B6FED), fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('/hora', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF5B6FED), Color(0xFF6B5BCD)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('RENTAR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAllVehiclesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        const Text('🚗', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        const Expanded(child: Text('Todos los vehículos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
          child: Text('6 disponibles', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _buildSedanSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚗', 'Sedán', '1 disponibles'),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildHorizontalCard('Toyota Corolla 2024', '2024 • Automático • 5 puestos', 4.8, 245, 25000)),
      const SizedBox(height: 24),
      _buildCompareSection(),
    ]);
  }

  Widget _buildSUVSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚙', 'SUV', '1 disponibles'),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildHorizontalCard('Mazda CX-5 2024', '2024 • Automático • 5 puestos', 4.9, 128, 38000)),
      const SizedBox(height: 24),
      _buildCompareSection(),
    ]);
  }

  Widget _buildCompactoSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildCategoryHeader('🚗', 'Compacto', '1 disponibles'),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildHorizontalCard('Renault Sandero 2023', '2023 • Manual • 5 puestos', 4.6, 189, 18000)),
      const SizedBox(height: 24),
      _buildCompareSection(),
    ]);
  }

  Widget _buildCategoryHeader(String emoji, String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: Text(count, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _buildHorizontalCard(String name, String specs, double rating, int reviews, int price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          child: Container(
            width: 120, height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D3436), Color(0xFF636E72)]),
            ),
            child: Center(child: Icon(Icons.directions_car, size: 50, color: Colors.white.withOpacity(0.3))),
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text(specs, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
              const SizedBox(width: 4),
              Text('$rating', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A1A))),
              const SizedBox(width: 2),
              Text('($reviews reseñas)', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: '\$ ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}',
                    style: const TextStyle(color: Color(0xFF5B6FED), fontWeight: FontWeight.bold, fontSize: 18)),
                TextSpan(text: ' /h', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ])),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B6FED),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Ver', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                ]),
              ),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildCompareSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.compare_arrows, color: Color(0xFF5B6FED), size: 24),
            const SizedBox(width: 8),
            const Text('Compara y ahorra 💰',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Column(children: [
              const Text('🚕', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Taxi (8h)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              const Text('\$ 180.000',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
            ])),
            Container(width: 1, height: 80, color: Colors.grey.shade200),
            Expanded(child: Column(children: [
              const Text('🚗', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('FlexiDrive (8h)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              const Text('\$ 72.000',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00C896))),
            ])),
          ]),
        ]),
      ),
    );
  }

  // ─── CITY SELECTOR ─────────────────────────────────────────────────────────

  void _showCitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _cityData.where((c) =>
              (c['name'] as String).toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selecciona tu ciudad',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),
                          Text('${_cityData.length} ciudades disponibles en Colombia',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      )),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (v) => setModalState(() => searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar ciudad...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                // City list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final city = filtered[index];
                      final cityName = city['name'] as String;
                      final isSel = cityName == _selectedCity;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedCity = cityName);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFEEF3FF) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFF5B6FED) : Colors.grey.shade200,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(children: [
                            // Emoji avatar
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFDDE4FF) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(city['emoji'] as String,
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cityName, style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? const Color(0xFF5B6FED) : const Color(0xFF1A1A1A),
                                )),
                                Text('${city['vehicles']} vehículos disponibles',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ],
                            )),
                            if (isSel)
                              const Icon(Icons.check_circle, color: Color(0xFF5B6FED), size: 22),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
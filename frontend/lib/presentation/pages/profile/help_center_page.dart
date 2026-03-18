import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/responsive_utils.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatOpen = false;
  final List<Map<String, dynamic>> _chatMessages = [];

  final Map<String, String> _botResponses = {
    'hola': '¡Hola! Soy Ana, tu asistente FlexiDrive 👋 ¿En qué puedo ayudarte hoy?',
    'cancelar': 'Para cancelar una reserva, ve a "Mis Reservas", selecciona la reserva y presiona "Cancelar". El reembolso depende de la política de cancelación.',
    'documentos': 'Necesitas: 1) Licencia de conducir válida, 2) Cédula de identidad, 3) Tarjeta de crédito como garantía.',
    'seguro': 'Todos los vehículos incluyen seguro básico. Puedes agregar cobertura adicional al momento de reservar.',
    'extender': 'Sí, puedes extender tu reserva desde "Mis Reservas" si el vehículo está disponible.',
    'daño': 'Documenta el daño con fotos y repórtalo inmediatamente a través de la app o llamando al soporte 24/7.',
    'precio': 'Los precios varían según el vehículo. Por ejemplo: Toyota Corolla \$25.000/h, Mazda CX-5 \$38.000/h.',
    'pago': 'Aceptamos tarjetas de crédito/débito (Visa, Mastercard), PSE y efectivo.',
    'gracias': '¡Con gusto! 😊 Estoy aquí para ayudarte cuando lo necesites.',
    'adios': '¡Hasta luego! 👋 Que tengas un excelente día.',
  };

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'icon': Icons.phone_outlined,
      'title': 'Llamar',
      'subtitle': '01 8000 123 456',
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFD1FAE5),
    },
    {
      'icon': Icons.email_outlined,
      'title': 'Email',
      'subtitle': 'soporte@flexidrive.co',
      'color': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFDBEAFE),
    },
    {
      'icon': Icons.description_outlined,
      'title': 'Términos',
      'subtitle': 'Ver condiciones',
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFFEDE9FE),
    },
    {
      'icon': Icons.chat_bubble_outline_rounded,
      'title': 'Chat',
      'subtitle': 'En vivo 24/7',
      'color': const Color(0xFFEF4444),
      'bgColor': const Color(0xFFFEF3C7),
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': '¿Cómo cancelo una reserva?',
      'answer': 'Puedes cancelar tu reserva desde la sección "Mis Reservas". Selecciona la reserva que deseas cancelar y haz clic en "Cancelar Reserva". Recuerda revisar la política de cancelación.',
      'isExpanded': false,
    },
    {
      'question': '¿Qué documentos necesito para rentar?',
      'answer': 'Necesitas licencia de conducir válida, cédula de identidad, y una tarjeta de crédito como garantía. Los documentos deben estar vigentes.',
      'isExpanded': false,
    },
    {
      'question': '¿Cómo funciona el seguro incluido?',
      'answer': 'Todos los vehículos incluyen seguro básico. Puedes adquirir cobertura adicional al momento de hacer tu reserva para mayor tranquilidad.',
      'isExpanded': false,
    },
    {
      'question': '¿Puedo extender mi reserva activa?',
      'answer': 'Sí, puedes extender tu reserva desde la sección "Mis Reservas" siempre que el vehículo esté disponible para las fechas adicionales.',
      'isExpanded': false,
    },
    {
      'question': '¿Qué hago si el vehículo tiene algún daño?',
      'answer': 'Documenta el daño con fotos antes de usar el vehículo y repórtalo de inmediato a través de la app o llamando a nuestro soporte 24/7.',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = ResponsiveUtils.isSmallPhone(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Main page ──────────────────────────────────────────────
          Column(
            children: [
              _buildGradientHeader(isSmallPhone),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 16 : 20,
                    vertical: isSmallPhone ? 16 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactOptionsSection(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 20 : 24),
                      _buildFAQSection(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 16 : 20),
                      _buildChatWithAgentButton(isSmallPhone),
                      SizedBox(height: isSmallPhone ? 24 : 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Dim backdrop ───────────────────────────────────────────
          if (_isChatOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeChat,
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),

          // ── Chat bottom-sheet overlay ──────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            bottom: _isChatOpen ? 0 : -(MediaQuery.of(context).size.height * 0.72),
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.72,
            child: _buildChatOverlay(isSmallPhone),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // GRADIENT HEADER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildGradientHeader(bool isSmallPhone) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 8 : 12,
                isSmallPhone ? 16 : 20,
                isSmallPhone ? 20 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: isSmallPhone ? 36 : 40,
                          height: isSmallPhone ? 36 : 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: isSmallPhone ? 16 : 18,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallPhone ? 12 : 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Centro de Ayuda',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isSmallPhone ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Soporte 24/7 · Respuesta en < 5 min',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isSmallPhone ? 12 : 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallPhone ? 16 : 20),
                  // Search bar
                  Container(
                    height: isSmallPhone ? 44 : 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar en preguntas frecuentes...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: isSmallPhone ? 13 : 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          size: isSmallPhone ? 20 : 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallPhone ? 12 : 14,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 13 : 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CONTACT OPTIONS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildContactOptionsSection(bool isSmallPhone) {
    return Row(
      children: _contactOptions.asMap().entries.map((entry) {
        final isLast = entry.key == _contactOptions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : (isSmallPhone ? 8 : 10)),
            child: _buildContactCard(entry.value, isSmallPhone),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> option, bool isSmallPhone) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _handleContactOption(option['title']),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 6 : 8,
          vertical: isSmallPhone ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmallPhone ? 40 : 44,
              height: isSmallPhone ? 40 : 44,
              decoration: BoxDecoration(
                color: option['bgColor'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: option['color'] as Color,
                size: isSmallPhone ? 20 : 22,
              ),
            ),
            SizedBox(height: isSmallPhone ? 8 : 10),
            Text(
              option['title'],
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              option['subtitle'],
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 9 : 10,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // FAQ
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFAQSection(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREGUNTAS FRECUENTES',
          style: GoogleFonts.inter(
            fontSize: isSmallPhone ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: isSmallPhone ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              final isLast = index == _faqs.length - 1;
              return _buildFAQItem(faq, isSmallPhone, isLast, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(
      Map<String, dynamic> faq, bool isSmallPhone, bool isLast, int index) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: () => _toggleFAQ(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallPhone ? 16 : 20,
              vertical: isSmallPhone ? 14 : 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    faq['question'],
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 13 : 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  faq['isExpanded']
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: isSmallPhone ? 22 : 24,
                ),
              ],
            ),
          ),
        ),
        if (faq['isExpanded'])
          Padding(
            padding: EdgeInsets.fromLTRB(
              isSmallPhone ? 16 : 20,
              0,
              isSmallPhone ? 16 : 20,
              isSmallPhone ? 14 : 16,
            ),
            child: Text(
              faq['answer'],
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 12 : 13,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        if (!isLast)
          Divider(
            height: 1,
            indent: isSmallPhone ? 16 : 20,
            endIndent: isSmallPhone ? 16 : 20,
            color: theme.dividerTheme.color,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CHAT WITH AGENT BUTTON
  // ─────────────────────────────────────────────────────────────────
  Widget _buildChatWithAgentButton(bool isSmallPhone) {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 20 : 24,
          vertical: isSmallPhone ? 16 : 18,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmallPhone ? 40 : 44,
              height: isSmallPhone ? 40 : 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: isSmallPhone ? 20 : 22,
              ),
            ),
            SizedBox(width: isSmallPhone ? 14 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chatear con un agente',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Disponible ahora · Espera < 1 min',
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 11 : 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: isSmallPhone ? 10 : 12,
              height: isSmallPhone ? 10 : 12,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CHAT OVERLAY
  // ─────────────────────────────────────────────────────────────────
  Widget _buildChatOverlay(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Column(
          children: [
            _buildChatHeader(isSmallPhone),
            _buildChatMessages(isSmallPhone),
            _buildChatInput(isSmallPhone),
          ],
        ),
      ),
    );
  }

  /// White header as seen in the prototype:
  /// - Purple rounded-square avatar with robot icon + green dot badge
  /// - "Ana · Soporte FlexiDrive" in dark bold
  /// - "● En línea ahora" in green
  /// - Grey X close button on the right
  Widget _buildChatHeader(bool isSmallPhone) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 16 : 20,
        vertical: isSmallPhone ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with online dot badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isSmallPhone ? 46 : 50,
                height: isSmallPhone ? 46 : 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: isSmallPhone ? 26 : 28,
                ),
              ),
              // Green online dot badge
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: isSmallPhone ? 14 : 15,
                  height: isSmallPhone ? 14 : 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: isSmallPhone ? 12 : 14),
          // Name + status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ana · Soporte FlexiDrive',
                  style: GoogleFonts.inter(
                    fontSize: isSmallPhone ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'En línea ahora',
                      style: GoogleFonts.inter(
                        fontSize: isSmallPhone ? 12 : 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close (X) button
          GestureDetector(
            onTap: _closeChat,
            child: Container(
              width: isSmallPhone ? 34 : 38,
              height: isSmallPhone ? 34 : 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E3355) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark ? const Color(0xFF8B93B8) : Colors.grey.shade500,
                size: isSmallPhone ? 18 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(bool isSmallPhone) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
          itemCount: _chatMessages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(_chatMessages[index], isSmallPhone);
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSmallPhone) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = message['isUser'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          if (!isUser) ...[
            Container(
              width: isSmallPhone ? 32 : 36,
              height: isSmallPhone ? 32 : 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: isSmallPhone ? 17 : 19,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallPhone ? 14 : 16,
                vertical: isSmallPhone ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF4F46E5) 
                    : isDark 
                        ? const Color(0xFF1F2235)  // dark surface elevated
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'],
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 13 : 14,
                      fontWeight: FontWeight.w400,
                      color: isUser 
                          ? Colors.white 
                          : isDark 
                              ? const Color(0xFFF1F3FF)  // dark text primary
                              : const Color(0xFF1A1A1A),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: GoogleFonts.inter(
                      fontSize: isSmallPhone ? 10 : 11,
                      fontWeight: FontWeight.w400,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.65)
                          : isDark 
                              ? const Color(0xFF8B93B8)  // dark text secondary
                              : Colors.grey.shade500,
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

  Widget _buildChatInput(bool isSmallPhone) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.fromLTRB(
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 10 : 12,
        isSmallPhone ? 16 : 20,
        isSmallPhone ? 16 : 24,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                hintStyle: GoogleFonts.inter(
                  fontSize: isSmallPhone ? 14 : 15,
                  color: isDark ? const Color(0xFF8B93B8) : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF2E3355) : Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: isDark ? const Color(0xFF2E3355) : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Color(0xFF4F46E5), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: isSmallPhone ? 14 : 15,
                color: theme.colorScheme.onSurface,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: isSmallPhone ? 10 : 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: isSmallPhone ? 48 : 52,
              height: isSmallPhone ? 48 : 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: isSmallPhone ? 20 : 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────
  void _openChat() {
    setState(() {
      _isChatOpen = true;
      if (_chatMessages.isEmpty) {
        _chatMessages.add({
          'isUser': false,
          'message': '¡Hola! Soy Ana, tu asistente FlexiDrive 👋 ¿En qué puedo ayudarte hoy?',
          'time': _getCurrentTime(),
        });
      }
    });
  }

  void _closeChat() => setState(() => _isChatOpen = false);

  void _sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add({
        'isUser': true,
        'message': message,
        'time': _getCurrentTime(),
      });
      _chatController.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateBotResponse(message);
      setState(() {
        _chatMessages.add({
          'isUser': false,
          'message': response,
          'time': _getCurrentTime(),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final entry in _botResponses.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'Entiendo tu consulta. Para ayudarte mejor, puedes:\n\n'
        '1️⃣ Revisar nuestras preguntas frecuentes\n'
        '2️⃣ Llamar al 01 8000 123 456\n'
        '3️⃣ Escribir a soporte@flexidrive.co\n\n'
        '¿Hay algo más en lo que pueda ayudarte?';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _toggleFAQ(int index) {
    setState(() => _faqs[index]['isExpanded'] = !_faqs[index]['isExpanded']);
  }

  void _handleContactOption(String title) {
    if (title == 'Chat') {
      _openChat();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Abriendo $title...',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
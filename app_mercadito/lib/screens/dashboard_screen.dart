import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State for interactivity
  String _selectedMetric = 'negociaciones'; // 'negociaciones', 'visitas', 'ingresos'
  String _filterType = 'mes'; // 'dia', 'mes', 'rango'
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF00462f),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _filterType = 'rango';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181d1a) : const Color(0xFFf7faf5);
    final surfaceLowest = isDark ? const Color(0xFF2d312e) : Colors.white;
    final primary = const Color(0xFF00462f);
    final primaryContainer = const Color(0xFF036042);
    final outlineVariant = isDark ? Colors.grey[800]! : const Color(0xFFbec9c1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFf7faf5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mercadito',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? const Color(0xFF10b981) : primary,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, primary),
                  const SizedBox(height: 24),
                  _buildKPIGrid(isDark, surfaceLowest, outlineVariant, primary, primaryContainer),
                  const SizedBox(height: 24),
                  _buildChartSection(isDark, surfaceLowest, outlineVariant, primary, primaryContainer),
                  const SizedBox(height: 24),
                  _buildRecentActivity(isDark, surfaceLowest, outlineVariant, primary),
                  const SizedBox(height: 48), // Padding en el fondo
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Resumen de actividad y métricas clave.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : const Color(0xFF3f4943),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid(bool isDark, Color surfaceLowest, Color outlineVariant, Color primary, Color primaryContainer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildKPICard(isDark, surfaceLowest, outlineVariant, 'Total Negociaciones', '48', '+12%', Icons.handshake, const Color(0xFF486456), 'negociaciones')),
                const SizedBox(width: 16),
                Expanded(child: _buildKPICard(isDark, surfaceLowest, outlineVariant, 'Visitas al Perfil', '1,204', '+5%', Icons.visibility, const Color(0xFF486456), 'visitas')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildKPICard(isDark, surfaceLowest, outlineVariant, 'En Tránsito', '12', '-2%', Icons.local_shipping, const Color(0xFFFF8A5B), 'transito')),
                const SizedBox(width: 16),
                Expanded(child: _buildIncomeCard(primaryContainer, primary)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard(bool isDark, Color surfaceLowest, Color outlineVariant, String title, String value, String badgeText, IconData icon, Color iconColor, String metricKey) {
    final bool isSelected = _selectedMetric == metricKey;
    final primary = const Color(0xFF00462f);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = metricKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : outlineVariant.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            else
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? primary : iconColor, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isSelected ? primary : iconColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? primary : iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF181d1a),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : const Color(0xFF3f4943),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(Color primaryContainer, Color primary) {
    final bool isSelected = _selectedMetric == 'ingresos';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = 'ingresos';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            if (isSelected)
              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
            const SizedBox(height: 16),
            Text(
              'Ingresos del Mes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$14,500',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(bool isDark, Color surfaceLowest, Color outlineVariant, Color primary, Color primaryContainer) {
    String chartTitle = 'Crecimiento de Negociaciones';
    if (_selectedMetric == 'visitas') chartTitle = 'Visitas al Perfil';
    if (_selectedMetric == 'ingresos') chartTitle = 'Evolución de Ingresos';
    if (_selectedMetric == 'transito') chartTitle = 'Pedidos en Tránsito';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
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
                      chartTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF181d1a),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_filterType == 'rango' && _selectedDateRange != null)
                      Text(
                        '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: primary,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildFilterToggle('Día', 'dia', primary, isDark),
                  const SizedBox(width: 8),
                  _buildFilterToggle('Mes', 'mes', primary, isDark),
                  const SizedBox(width: 8),
                  _buildFilterToggle('Rango', 'rango', primary, isDark, onTap: _selectDateRange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomAnimatedChart(
              key: ValueKey('${_selectedMetric}_${_filterType}'),
              primary: primary,
              primaryContainer: primaryContainer,
              isDark: isDark,
              metric: _selectedMetric,
              filterType: _filterType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(String label, String value, Color primary, bool isDark, {VoidCallback? onTap}) {
    final bool isSelected = _filterType == value;
    return GestureDetector(
      onTap: onTap ?? () {
        setState(() {
          _filterType = value;
          if (value != 'rango') _selectedDateRange = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primary : (isDark ? Colors.grey[800] : const Color(0xFFebefea)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : primary),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark, Color surfaceLowest, Color outlineVariant, Color primary) {
    final textColor = isDark ? Colors.white : const Color(0xFF181d1a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Actividad Reciente',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'Ver Todo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          isDark: isDark,
          surfaceLowest: surfaceLowest,
          outlineVariant: outlineVariant,
          title: 'Tomate Cherry Orgánico',
          subtitle: 'Nueva oferta recibida: \$450 por 100kg',
          time: 'Hace 2h',
          icon: Icons.forum,
          iconColor: primary,
          imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDo0_M3uCb5LEocAN3TJ4sUxNFfP-ZakeuGrbRWaLCSFd9VnkxeGCAEQd6umAiwoHrryYk2oh2F42UI63Ziny8FG_BnK8XDabhSUR6gwdqunGKXbvVyRH955bUM1UvsGNHluKTMzZDh2pIaleJlBz1MusmeDlrfYDQ7N1enT3a9vk9C7lk6wSvIbly3160L9BOKVIba9zK9-T4FKCE0-AAilh4MEuuIrtQPW4mAMkpNteKSQHKvMx68qOv8wNrYh7X4cyapU87P-oc',
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          isDark: isDark,
          surfaceLowest: surfaceLowest,
          outlineVariant: outlineVariant,
          title: 'Aguacate Hass Premium',
          subtitle: 'Pago retrasado detectado',
          time: 'Ayer',
          icon: Icons.warning,
          iconColor: const Color(0xFF682826),
          imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVv30dYBRpc7YO6gURA5YQBgDZkkgkuuAKrlS3gykX1zNXUFCLOPo_aXcWEA67UmoDDFtlTptbH5LrpokmJaj1gSuMViBU8hxZ2m4zarpZUG9yFYXMwgQeKYvBpvhj9da9XfPzFo6Xp0kLh5LSDGJcdDNE2lTatHI-JGCHosgQdnd-6e1YBZD7onHmUo1vHze_mQE6LZ9ysdGTQZutk4nXCM4pVsNJfqFOUTPFmU6NtTYaSkEGnQbpIA2rFr9ryO13LImRI5Qfkr0',
          leftBorderColor: const Color(0xFF682826),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          isDark: isDark,
          surfaceLowest: surfaceLowest,
          outlineVariant: outlineVariant,
          title: 'Maíz Amarillo Dulce',
          subtitle: 'Negociación cerrada con éxito',
          time: 'Hace 2 días',
          icon: Icons.check_circle,
          iconColor: primary,
          imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDSrw6pLp__VdQSh0E79utFM-JXhQg4vM159Jo4PnKkzQqCsuOvs_iBIhJYczoHaF9QWi9e_foS3lMSUmlyicGZtLAvgn7JZw6__7FEj4b9-4zuAIoWbxkyVLHajfOZto6lSDRWkczu9AmnJcDH_89C-_GSobXyYPt2U8G6MeDYs9u2DOSHS8keNaMndk3JDKoXIsPqg6mp4qBCoTSxn064JEc-Je2anAxEuXqC5V9Nve550M06CNTAaHLApgmQtyFTSJk7hT9aaO4',
          leftBorderColor: primary,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required bool isDark,
    required Color surfaceLowest,
    required Color outlineVariant,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required String imgUrl,
    Color? leftBorderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (leftBorderColor != null)
                Container(width: 4, color: leftBorderColor),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? Colors.grey[800] : const Color(0xFFebefea),
                        image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF181d1a),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 200,
                          child: Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: iconColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : const Color(0xFF3f4943),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 16, color: iconColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAnimatedChart extends StatefulWidget {
  final Color primary;
  final Color primaryContainer;
  final bool isDark;
  final String metric;
  final String filterType;

  const CustomAnimatedChart({
    super.key,
    required this.primary,
    required this.primaryContainer,
    required this.isDark,
    required this.metric,
    required this.filterType,
  });

  @override
  State<CustomAnimatedChart> createState() => _CustomAnimatedChartState();
}

class _CustomAnimatedChartState extends State<CustomAnimatedChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  late List<Map<String, dynamic>> _currentData;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _heightAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    
    _generateData();
    _controller.forward();
  }

  void _generateData() {
    // Generate dummy data based on metric and filterType
    if (widget.filterType == 'mes') {
      if (widget.metric == 'negociaciones') {
        _currentData = [
          {'month': 'Ene', 'value': 0.4, 'label': '24 Neg.'},
          {'month': 'Feb', 'value': 0.55, 'label': '32 Neg.'},
          {'month': 'Mar', 'value': 0.45, 'label': '28 Neg.'},
          {'month': 'Abr', 'value': 0.7, 'label': '42 Neg.'},
          {'month': 'May', 'value': 0.85, 'label': '51 Neg.', 'isHighlighted': true},
          {'month': 'Jun', 'value': 0.8, 'label': '48 Neg.'},
        ];
      } else if (widget.metric == 'visitas') {
        _currentData = [
          {'month': 'Ene', 'value': 0.6, 'label': '800 Vis.'},
          {'month': 'Feb', 'value': 0.4, 'label': '550 Vis.'},
          {'month': 'Mar', 'value': 0.8, 'label': '1.1k Vis.'},
          {'month': 'Abr', 'value': 0.9, 'label': '1.3k Vis.', 'isHighlighted': true},
          {'month': 'May', 'value': 0.7, 'label': '950 Vis.'},
          {'month': 'Jun', 'value': 0.85, 'label': '1.2k Vis.'},
        ];
      } else if (widget.metric == 'ingresos') {
        _currentData = [
          {'month': 'Ene', 'value': 0.5, 'label': '\$10k'},
          {'month': 'Feb', 'value': 0.7, 'label': '\$14k'},
          {'month': 'Mar', 'value': 0.6, 'label': '\$12k'},
          {'month': 'Abr', 'value': 0.8, 'label': '\$16k', 'isHighlighted': true},
          {'month': 'May', 'value': 0.75, 'label': '\$15k'},
          {'month': 'Jun', 'value': 0.9, 'label': '\$18k'},
        ];
      } else {
        _currentData = [
          {'month': 'Ene', 'value': 0.3, 'label': '5 Env.'},
          {'month': 'Feb', 'value': 0.5, 'label': '8 Env.'},
          {'month': 'Mar', 'value': 0.4, 'label': '6 Env.'},
          {'month': 'Abr', 'value': 0.6, 'label': '10 Env.'},
          {'month': 'May', 'value': 0.8, 'label': '15 Env.', 'isHighlighted': true},
          {'month': 'Jun', 'value': 0.7, 'label': '12 Env.'},
        ];
      }
    } else if (widget.filterType == 'dia') {
      // Día filter (last 7 days)
      if (widget.metric == 'negociaciones') {
        _currentData = [
          {'month': 'Lun', 'value': 0.2, 'label': '2 Neg.'},
          {'month': 'Mar', 'value': 0.4, 'label': '5 Neg.'},
          {'month': 'Mié', 'value': 0.3, 'label': '4 Neg.'},
          {'month': 'Jue', 'value': 0.6, 'label': '8 Neg.'},
          {'month': 'Vie', 'value': 0.9, 'label': '12 Neg.', 'isHighlighted': true},
          {'month': 'Sáb', 'value': 0.5, 'label': '7 Neg.'},
          {'month': 'Dom', 'value': 0.3, 'label': '3 Neg.'},
        ];
      } else if (widget.metric == 'visitas') {
        _currentData = [
          {'month': 'Lun', 'value': 0.5, 'label': '45 Vis.'},
          {'month': 'Mar', 'value': 0.6, 'label': '52 Vis.'},
          {'month': 'Mié', 'value': 0.4, 'label': '38 Vis.'},
          {'month': 'Jue', 'value': 0.8, 'label': '75 Vis.'},
          {'month': 'Vie', 'value': 0.95, 'label': '92 Vis.', 'isHighlighted': true},
          {'month': 'Sáb', 'value': 0.7, 'label': '65 Vis.'},
          {'month': 'Dom', 'value': 0.4, 'label': '35 Vis.'},
        ];
      } else {
        _currentData = [
          {'month': 'Lun', 'value': 0.4, 'label': '\$800'},
          {'month': 'Mar', 'value': 0.5, 'label': '\$1k'},
          {'month': 'Mié', 'value': 0.3, 'label': '\$650'},
          {'month': 'Jue', 'value': 0.7, 'label': '\$1.5k'},
          {'month': 'Vie', 'value': 0.9, 'label': '\$2k', 'isHighlighted': true},
          {'month': 'Sáb', 'value': 0.6, 'label': '\$1.2k'},
          {'month': 'Dom', 'value': 0.4, 'label': '\$850'},
        ];
      }
    } else {
      // Rango filter (custom periods)
      if (widget.metric == 'negociaciones') {
        _currentData = [
          {'month': 'Sem 1', 'value': 0.3, 'label': '15 Neg.'},
          {'month': 'Sem 2', 'value': 0.6, 'label': '28 Neg.'},
          {'month': 'Sem 3', 'value': 0.5, 'label': '22 Neg.'},
          {'month': 'Sem 4', 'value': 0.8, 'label': '40 Neg.', 'isHighlighted': true},
        ];
      } else if (widget.metric == 'visitas') {
        _currentData = [
          {'month': 'Sem 1', 'value': 0.4, 'label': '300 Vis.'},
          {'month': 'Sem 2', 'value': 0.7, 'label': '500 Vis.', 'isHighlighted': true},
          {'month': 'Sem 3', 'value': 0.5, 'label': '380 Vis.'},
          {'month': 'Sem 4', 'value': 0.6, 'label': '420 Vis.'},
        ];
      } else {
        _currentData = [
          {'month': 'Sem 1', 'value': 0.5, 'label': '\$4k'},
          {'month': 'Sem 2', 'value': 0.8, 'label': '\$7k', 'isHighlighted': true},
          {'month': 'Sem 3', 'value': 0.6, 'label': '\$5k'},
          {'month': 'Sem 4', 'value': 0.7, 'label': '\$6k'},
        ];
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryContainer = const Color(0xFFcaead7);
    final secondaryContainerDark = const Color(0xFF314c3f);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final barWidth = constraints.maxWidth / (_currentData.length * 1.5);

        return Stack(
          children: [
            // Grid lines
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => 
                Container(
                  height: 1,
                  color: widget.isDark ? Colors.grey[800] : const Color(0xFFbec9c1).withOpacity(0.2),
                )
              ),
            ),
            
            // Bars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_currentData.length, (index) {
                final d = _currentData[index];
                final isHighlighted = d['isHighlighted'] == true;
                
                Color barColor;
                if (isHighlighted) {
                  barColor = widget.primary;
                } else if (d['value'] >= 0.7) {
                  barColor = widget.primaryContainer.withOpacity(0.8);
                } else if (d['value'] >= 0.6) {
                  barColor = const Color(0xFFa5f3cb);
                } else {
                  barColor = widget.isDark ? secondaryContainerDark.withOpacity(0.5) : secondaryContainer.withOpacity(0.5);
                }

                return GestureDetector(
                  onTapDown: (_) => setState(() => _hoveredIndex = index),
                  onTapUp: (_) => setState(() => _hoveredIndex = null),
                  onTapCancel: () => setState(() => _hoveredIndex = null),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tooltip
                      AnimatedOpacity(
                        opacity: _hoveredIndex == index ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isDark ? Colors.white : const Color(0xFF2d312e),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            d['label'],
                            style: GoogleFonts.plusJakartaSans(
                              color: widget.isDark ? Colors.black : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Bar
                      AnimatedBuilder(
                        animation: _heightAnimation,
                        builder: (context, child) {
                          return Container(
                            width: barWidth,
                            height: (height - 60) * d['value'] * _heightAnimation.value,
                            decoration: BoxDecoration(
                              color: _hoveredIndex == index ? widget.primaryContainer : barColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              boxShadow: isHighlighted ? [
                                BoxShadow(color: widget.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -4))
                              ] : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        d['month'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.bold,
                          color: isHighlighted ? widget.primary : (widget.isDark ? Colors.grey[400] : const Color(0xFF3f4943)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

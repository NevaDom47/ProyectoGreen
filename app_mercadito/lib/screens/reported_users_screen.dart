import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode global variable

class ReportedUser {
  final String name;
  final String username;
  final String? avatarUrl;
  final String? initials;
  final DateTime reportedAt;

  ReportedUser({
    required this.name,
    required this.username,
    required this.reportedAt,
    this.avatarUrl,
    this.initials,
  });
}

class ReportedUsersScreen extends StatefulWidget {
  const ReportedUsersScreen({super.key});

  @override
  State<ReportedUsersScreen> createState() => _ReportedUsersScreenState();
}

class _ReportedUsersScreenState extends State<ReportedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedFilterDate;

  final List<ReportedUser> _allUsers = [
    ReportedUser(
      name: 'Carlos Rodríguez',
      username: '@carlos_rod89',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjICzybPKvS5Xqs5EgqqAa5omMklKIYUcyKDaRL_07LUHApmJPULuU_BJ1BSfuxjDNuOJN4_BUJ78BS5ynmTkM1oYFgbZ6NpSZmRSNZ8eBgQybBhxe1cfxRN2suyyZ71WQq-Oodoe2-TigzReePlYj8obUTsbIptPvEXrgcyCW0lwCNDwVDjN3iDhSNbGWZ2ogRZYyPAvoOhZG-PRqCeIecaAhdGT_irbaIDi_hGq2eLMhZurCKAf8wh4KNUDW7KrBSGkxU582zB4',
      reportedAt: DateTime(2026, 3, 28, 14, 30),
    ),
    ReportedUser(
      name: 'Ana María López',
      username: '@ana_mx_7',
      initials: 'A',
      reportedAt: DateTime(2026, 3, 29, 9, 15),
    ),
    ReportedUser(
      name: 'Spam Bot 2024',
      username: '@crypto_king_bot',
      initials: 'S',
      reportedAt: DateTime(2026, 4, 1, 8, 45),
    ),
    ReportedUser(
      name: 'Juan Pérez',
      username: '@juanperez',
      initials: 'J',
      reportedAt: DateTime(2026, 4, 1, 11, 20),
    ),
  ];

  String _formatDate(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year} a las ${pad(date.hour)}:${pad(date.minute)}';
  }

  String _formatDateOnly(DateTime date) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(date.day)}/${pad(date.month)}/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFf20d0d),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0f172a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final isDark = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && platformBrightness == Brightness.dark);
        
        final bgColor = isDark ? const Color(0xFF1c0d0d) : const Color(0xFFf8f5f5);
        final primaryColor = const Color(0xFFf20d0d); // Danger red tone
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final subtextColor = isDark ? const Color(0xFF94a3b8) : const Color(0xFF475569);
        final borderColor = isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1);

        final filteredUsers = _allUsers.where((user) {
          final query = _searchQuery.toLowerCase();
          final matchesText = user.name.toLowerCase().contains(query) ||
                 user.username.toLowerCase().contains(query);
          
          if (_selectedFilterDate != null) {
            final isSameDate = user.reportedAt.year == _selectedFilterDate!.year &&
                               user.reportedAt.month == _selectedFilterDate!.month &&
                               user.reportedAt.day == _selectedFilterDate!.day;
            return matchesText && isSameDate;
          }
          
          return matchesText;
        }).toList();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Usuarios Reportados',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? primaryColor.withOpacity(0.1) : primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Icon(Icons.search, color: primaryColor.withOpacity(0.7)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: textColor),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Buscar usuarios...',
                            hintStyle: TextStyle(color: subtextColor),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month, color: primaryColor.withOpacity(0.7)),
                        onPressed: _pickDate,
                        tooltip: 'Filtrar por fecha',
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),

              // Active Date Filter Chip
              if (_selectedFilterDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event, size: 14, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              'Fecha: ${_formatDateOnly(_selectedFilterDate!)}',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => setState(() => _selectedFilterDate = null),
                              child: Icon(Icons.close, size: 16, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Info Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  'Aquí podrás visualizar los usuarios que han sido reportados por algún comportamiento inusual por los demás proveedores y compradores.',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Users List
              Expanded(
                child: ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return InkWell(
                      onTap: () {},
                      hoverColor: primaryColor.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF2d1a1a) : const Color(0xFFe2e8f0),
                                image: user.avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(user.avatarUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: user.avatarUrl == null && user.initials != null
                                  ? Center(
                                      child: Text(
                                        user.initials!,
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.username,
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 12, color: primaryColor.withOpacity(0.8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Reportado el ${_formatDate(user.reportedAt)}',
                                        style: TextStyle(
                                          color: primaryColor.withOpacity(0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Visualizando reporte de ${user.name}')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Ver Reporte',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_session.dart';

class BusinessHoursScreen extends StatefulWidget {
  const BusinessHoursScreen({super.key});

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  late List<DaySchedule> _weeklySchedule;

  @override
  void initState() {
    super.initState();
    _weeklySchedule = UserSession.currentWeeklySchedule.map((d) => d.copyWith()).toList();
  }

  void _applySameScheduleToAll(Color primaryColor) {
    if (_weeklySchedule.isEmpty) return;
    final monday = _weeklySchedule.first;
    setState(() {
      for (int i = 1; i < _weeklySchedule.length; i++) {
        _weeklySchedule[i].isActive = monday.isActive;
        _weeklySchedule[i].openTime = monday.openTime;
        _weeklySchedule[i].closeTime = monday.closeTime;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Horario de Lunes aplicado a todos los días.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, DaySchedule day, bool isOpen, Color primaryColor) async {
    final initialTime = isOpen ? day.openTime : day.closeTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpen) {
          day.openTime = picked;
        } else {
          day.closeTime = picked;
        }
      });
    }
  }

  void _saveSchedule(Color primaryColor) {
    UserSession.saveWeeklySchedule(_weeklySchedule);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Horario de atención actualizado exitosamente',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F231D) : const Color(0xFFF7FAF5);
    final cardBg = isDark ? const Color(0xFF13281E) : Colors.white;
    final primary = isDark ? const Color(0xFF89D6B0) : const Color(0xFF016042);
    final onSurface = isDark ? Colors.white : const Color(0xFF181D1A);
    final textVariant = isDark ? const Color(0xFFBEC9C1) : const Color(0xFF5F6368);
    final outlineVariant = isDark ? const Color(0xFF2C3E35) : const Color(0xFFD6DDD8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Horario de Atención',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Horario',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: primary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Configura los días y horarios en los que tu negocio estará disponible.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Quick Action Copy
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _applySameScheduleToAll(primary),
                        icon: Icon(Icons.content_copy, size: 18, color: primary),
                        label: Text(
                          'Aplicar mismo horario a todos los días',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF1E2621) : const Color(0xFFF1F4F0),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Weekly schedule list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _weeklySchedule.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final day = _weeklySchedule[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: day.isActive
                                ? cardBg
                                : (isDark ? const Color(0xFF161C19) : const Color(0xFFECEFEA)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: day.isActive
                                  ? (isDark ? const Color(0xFF2C3530) : outlineVariant.withValues(alpha: 0.5))
                                  : Colors.transparent,
                            ),
                            boxShadow: day.isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day.dayName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: day.isActive
                                          ? onSurface
                                          : (isDark ? Colors.grey[600] : Colors.grey[500]),
                                      decoration: day.isActive ? null : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Switch(
                                    value: day.isActive,
                                    onChanged: (val) {
                                      setState(() {
                                        day.isActive = val;
                                      });
                                    },
                                    activeThumbColor: primary,
                                    activeTrackColor: primary.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                child: day.isActive
                                    ? Column(
                                        children: [
                                          const SizedBox(height: 12),
                                          Divider(
                                            height: 1,
                                            color: outlineVariant.withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Apertura',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w900,
                                                        color: textVariant,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    InkWell(
                                                      onTap: () => _selectTime(context, day, true, primary),
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: isDark ? const Color(0xFF171D1A) : const Color(0xFFF1F4F0),
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(
                                                            color: outlineVariant.withValues(alpha: 0.3),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              day.formatTime(context, day.openTime),
                                                              style: GoogleFonts.plusJakartaSans(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: onSurface,
                                                              ),
                                                            ),
                                                            Icon(Icons.schedule, size: 15, color: textVariant),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Icon(Icons.arrow_right_alt, color: outlineVariant),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Cierre',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w900,
                                                        color: textVariant,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    InkWell(
                                                      onTap: () => _selectTime(context, day, false, primary),
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: isDark ? const Color(0xFF171D1A) : const Color(0xFFF1F4F0),
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(
                                                            color: outlineVariant.withValues(alpha: 0.3),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              day.formatTime(context, day.closeTime),
                                                              style: GoogleFonts.plusJakartaSans(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: onSurface,
                                                              ),
                                                            ),
                                                            Icon(Icons.schedule, size: 15, color: textVariant),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom action container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _saveSchedule(primary),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                  label: Text(
                    'GUARDAR HORARIO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF016042),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

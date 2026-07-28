import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // import appThemeMode and appLanguage global variables

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _languages = [
    'Spanish',
    'English',
    'French',
    'German',
    'Italian',
    'Portuguese',
  ];

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
        
        final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFf7faf5);
        final primaryColor = const Color(0xFF00462f);
        final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0f172a);
        final subtextColor = isDark ? const Color(0xFF64748b) : const Color(0xFF64748b);
        final borderColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);
        final vividGreen = const Color(0xFF10B981);

        final filteredLanguages = _languages.where((lang) {
          return lang.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Cambiar Idioma',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            centerTitle: true,
          ),
          body: ValueListenableBuilder<String>(
            valueListenable: appLanguage,
            builder: (context, currentLang, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? vividGreen.withOpacity(0.1) : vividGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(Icons.search, color: primaryColor),
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
                                hintText: 'Buscar idioma',
                                hintStyle: TextStyle(color: primaryColor.withOpacity(0.6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'SELECCIONA TU IDIOMA PREFERIDO',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredLanguages.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: borderColor,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final lang = filteredLanguages[index];
                        final isSelected = currentLang == lang;

                        return InkWell(
                          onTap: () {
                            appLanguage.value = lang;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            color: isSelected ? (isDark ? vividGreen.withOpacity(0.05) : vividGreen.withOpacity(0.05)) : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? vividGreen.withOpacity(0.2)
                                        : (isDark ? vividGreen.withOpacity(0.1) : vividGreen.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.flag,
                                    color: isSelected ? primaryColor : subtextColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      color: isSelected ? primaryColor : textColor,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check, color: primaryColor),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          ),
        );
      }
    );
  }
}

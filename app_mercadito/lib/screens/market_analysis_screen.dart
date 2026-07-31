import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MarketAnalysisScreen extends StatefulWidget {
  const MarketAnalysisScreen({super.key});

  @override
  State<MarketAnalysisScreen> createState() => _MarketAnalysisScreenState();
}

class _MarketAnalysisScreenState extends State<MarketAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    final surfaceColor = isDark ? const Color(0xFF1f2937) : Colors.white;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Análisis de Mercado',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryColor),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorWeight: 2,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(text: 'Precios'),
                  Tab(text: 'Noticias'),
                  Tab(text: 'Tendencias'),
                ],
              ),
              Divider(height: 1, color: primaryColor.withValues(alpha: 0.1)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPricesTab(theme, surfaceColor, primaryColor, isDark),
          const Center(child: Text('Noticias')),
          const Center(child: Text('Tendencias')),
        ],
      ),
    );
  }

  Widget _buildPricesTab(ThemeData theme, Color surfaceColor, Color primaryColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketPricesSection(theme, surfaceColor, primaryColor, isDark),
          _buildNewsSection(theme, surfaceColor, primaryColor, isDark),
        ],
      ),
    );
  }

  Widget _buildMarketPricesSection(ThemeData theme, Color surfaceColor, Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precios Certificados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'HOY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceCard(
            surfaceColor: surfaceColor,
            primaryColor: primaryColor,
            isDark: isDark,
            name: 'Tomate Bola',
            subtitle: 'Sinaloa • Mayorista',
            price: '\$24.50/kg',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCMuT9JbRfKYPLoclSGVVLM4CnSbvblT3pl5k0UaSJS3W2GXOi5gnU_hkSlAVtsPw9XMvqynGv8Gwbsl6Ayb7D4o2TGcm9lJ02q7AQWs0WgaqOtpHUeIBnuBuxIt5GBogGhhiVlVEFvmqxXYhWclUtiZZGPMz7XIrdUIfY7yjr703fZfwsHQscpOCL9J-nfr3n4dRRY0-gX3X-t8Yz4sYaxN2u7yEH9mNMq7OQ0_ZRjyPRDJ8tFyQ-MzTEcb3rZvKcMLBprSZxQU0A',
            trend: 2.4,
          ),
          const SizedBox(height: 12),
          _buildPriceCard(
            surfaceColor: surfaceColor,
            primaryColor: primaryColor,
            isDark: isDark,
            name: 'Papa Blanca',
            subtitle: 'Estado de México • Local',
            price: '\$18.20/kg',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAHugHRh1lohx6ZR5a0klWtzvQEy7rkrX7RpSRA9tBYa0OHdzIIDPePD9W77HknCW8wwzOFMp5XQnHqRGH2Ag4pGwPg6L91faJLNpam3AoHHZik91qLUSIt1X1PPSvZv6vLzTBRdDYLpI1CZRJn9BHJWeSN_dRFdt224TpWaIkKlWqH7SF0zPzNgKiwtKYNrKEBvjP2D-LFYrROXJn_yR0bCvMUeI_qLj7CDnwl7TrYhRqSYjmH401ZfJZ99e9gw33gZlUjnqLnG98',
            trend: -1.1,
          ),
          const SizedBox(height: 12),
          _buildPriceCard(
            surfaceColor: surfaceColor,
            primaryColor: primaryColor,
            isDark: isDark,
            name: 'Aguacate Hass',
            subtitle: 'Michoacán • Exportación',
            price: '\$72.00/kg',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDsRs95R78bB5ICVDibRfGwPp9vQ_V_O5yJ39oDALclMvCboaQ8T48-aAfaJ7vtI24prD9nBW2VPlTVuc9pJ0mB892zemHzjw0fq4l4oZjCQkJ93vw2rKYJg7STLJ8fJJ0MY9I6NHqf5-RzMvYk3NDvF75kWTBphxXjwuIJnVMmRVGiFi8yob-ACvS6shhzI7n5DnbK3aGsvc-KecDvz6bPBDAKnDNCE6rYGts82ELPkqaLVDRo2UKgJ8-3mHMxH4QEzuTv5ABUi6M',
            trend: 0.0,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required Color surfaceColor,
    required Color primaryColor,
    required bool isDark,
    required String name,
    required String subtitle,
    required String price,
    required String imageUrl,
    required double trend,
  }) {
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.horizontal_rule;
    String trendText = '0.0%';

    if (trend > 0) {
      trendColor = const Color(0xFF059669); // emerald-600
      trendIcon = Icons.trending_up;
      trendText = '+\${trend.toStringAsFixed(1)}%';
    } else if (trend < 0) {
      trendColor = const Color(0xFFE11D48); // rose-600
      trendIcon = Icons.trending_down;
      trendText = '\${trend.toStringAsFixed(1)}%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? primaryColor.withValues(alpha: 0.05) : surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
              Row(
                children: [
                  Icon(trendIcon, size: 14, color: trendColor),
                  const SizedBox(width: 2),
                  Text(
                    trendText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection(ThemeData theme, Color surfaceColor, Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Noticias Relevantes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // News Card 1
          Container(
            decoration: BoxDecoration(
              color: isDark ? primaryColor.withValues(alpha: 0.05) : surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 128,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBwuYgLQ8edJ0Kfw0ZvY4h3pff_cnhzA1OPEHDbpe_dXOyOpcO_i-LOr0oEGw96rCOWGRsJcGN9M8h5F3sUBsbYGgBg-_9zUxPyFHL_h-6POwEZpxTaiz5m6mqHdOxRRTPwuBRQK4Nc9SEmaR9eg-8EtCsByvY5If6sMSeDNRHF3fWeqDZXYnt3NO7uZamMkx52XjD1sXAP2oB3_swAUd2zxQ64s4H8-XQkCeQ_VWTUAsYMY7V5imxZ18gJ3X2Mmqrn32OHcL6TRRc',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'COSECHA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Hace 3h',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Inicia temporada de cosecha en el Bajío',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Productores reportan un incremento del 15% en la calidad del grano comparado con el año anterior debido a las lluvias tardías...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // News Card 2
          Container(
            height: 112, // approx h-28
            decoration: BoxDecoration(
              color: isDark ? primaryColor.withValues(alpha: 0.05) : surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withValues(alpha: 0.05)),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  height: double.infinity,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBsTiibrGGC4GRLVGi5IY_hvojJbff1rye5Kf-x7pxFHDcMmkG6gF10Km4uZDtnGw0DlOo3BzkpQ__l5Hop3FmEBrZALzLeX_Fv9z3JPUw4z--JZRWV626bSi4-UClL3LJ7cOw8C3fxjzimMeQQrvORUbwUTIaIVcjPinMq7epenaOJpLkEZK-MoacE58FhVd7szZFo1zA-9lWRySVHkm1MXnui5jrbeX1oV49c2ZBTqtMRefNel2pGMezoG4zH3aC3Y7A14bIOn48',
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'MERCADOS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange, // amber-600 approx
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Hace 6h',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cambios en aranceles afectan exportación',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Nuevas regulaciones entran en vigor este lunes para productos perecederos.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}

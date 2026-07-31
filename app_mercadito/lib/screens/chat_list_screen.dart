import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/skeleton_loading.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Don Pedro - Frutas frescas',
      'time': '10:24 AM',
      'message': '¿A qué hora pasas por los tomates, joven? Ya los tengo listos.',
      'unread': 2,
      'isOnline': true,
      'hasPendingNegotiation': true,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCGuFo9_dIrTJvjBz1GYvz2Wpxc521_2X88Rtn2m1l_qmdhc3Z9Sb-q4M3RNuqHnWe4IdWIHbivhrpD59rc4RD7sGh7tBebS9LdzzpdKCBNmhHraRQbYrOz52Clp8znVUxpgC4lVwLn9RbZLd1Uky7h633hiqMs8Oq_zMmfOXITUtR_M9vbkzLm01bUK1XUPeBvBn_LD-VeSNKn_kYh5KT56Cc9QOz89hTKtcnnldxupg7u_8ChyacxxldqlzZxbyElxJflDdR4WSQ',
    },
    {
      'name': 'María García',
      'time': '9:45 AM',
      'message': '¡Gracias! Los aguacates estaban deliciosos.',
      'unread': 0,
      'isOnline': false,
      'isRead': true,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCX5G1nhnoXAU7aQGOBig4iwQHlfeJWyRWRmY64OlcG2pIE16BQY1y8kBx6WCJ_zFhjv1bsf9a_oesznF20DowvOdFbCOsuGXXYw1mizU_s2G9Dtu4qaFBNzBfIysdPFDcgKJSYnazbAJjQ30K5ddsz5h-YCDpwShhKfulA2Tja_mfOSRN2vq8gA2Upjc4Gb4irlxNPiaHpF6947RvPvOmX2E4M7WOTMYc5da_-x8u4toHqmkSCWSYcxBBfTOr3uTvXDzC2dj1VoUc',
    },
    {
      'name': 'Cooperativa El Sol',
      'time': 'Ayer',
      'message': 'Nueva cosecha de fresas orgánicas disponible hoy.',
      'unread': 0,
      'isOnline': false,
      'isRead': false,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAgz5g6cO60H4oV7mpZ_kDdiq1sWud0kJlOTvurvjZUMPjaPfCU5PWeYS-jXQ3i31jCW_j5UAC70BeI-lcvS3B1npugnrVSt-_wjHtSPEhpNXKxcQ9JsiI9jZOjO6aHUYL0KEulc3_2i_ldERJz4pCIvwekdzWZl5Vl8_KvLmoE6yd4mSLD0qeWg1EMnJtAMzfPOHBWQMpSlU56GwkObZSWOptrUdPZsJwfePE5p6NmyATlHXslUl--tQyj0UG68ldIEKpBniIH0CQ',
    },
    {
      'name': 'Carlos Chef',
      'time': 'Ayer',
      'message': '¿Tienes disponibilidad de hierbabuena para el viernes?',
      'unread': 0,
      'isOnline': false,
      'isRead': false,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBrX6HakXsPO-387Kg_WLgXG1gen-45o4vNRSJpV3juD_RpOzCWX7bZjACszvHIkuNtOoUIIDPJVU93qzDksablZhBStoy1CuIMusKoQsZWKB0Z3GfPnSenvecIqLTR1HlRpeea_31VmdDVByM5HBPrc_h66Bm-ADLxxS_KZXRlqtn1ixhTFb3lq43mWEs67RS7ygForRYG4htdfsq7vAvumaMu8EUoZhh4I3OUMhGpcGlhK83OU2ukt1ydZzfykXOXcikqNgf7cR0',
    },
    {
      'name': 'Ricardo V.',
      'time': 'Lunes',
      'message': 'Entregado en la dirección acordada.',
      'unread': 0,
      'isOnline': false,
      'isRead': true,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBr6lsQBpyGkmrOmibFxdtreYR_N1QBny2eq8ARD28jriKMKKbKMmd6BSKnlwwnjBtfKPEdUTIpL0VPCykBnM3eZI-zUMLXQm2sbDy1_uvTkggBaXUm5xn44TDpXA8cvkGqlN6HueRmJxg4Bw9lCxGljwCYps74DgKWFJRL-Zx5xt5dIkrXned66b-FRlZ4MQLEqZBU1KlI4ZD59QMG1_VM9jC2S2IgpRCfSv4AA-KvgHoUEa8HbU_xOg2bx4-jJiEo76NK_9vXMaE',
    },
    {
      'name': 'Lucía M.',
      'time': 'Lunes',
      'message': 'Envié el comprobante de pago por correo.',
      'unread': 0,
      'isOnline': false,
      'isRead': false,
      'photoUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBti6amJ4eJfxhCDQe77P0YaNXur4W2gruKKOSf4-SJJM2E-XqPQBbHR6BnqHk1J0HNz0EXDSE6mtAZTjnylh6TR7aMypdVu0imNbiwdL72pi0GBzS5CNGL6Hl_XJBDarIr4JIEnEopmC-6pDP2SI_xzfrm5VeOTdduZwwj4z9k3QSLEGkYIhtlsjc0j3gKoc_fSVVdPNX1Wh87qr6NeqfjtHt7gu17R2ZgRFSCV4jHUgAX5rwmk8ZcddZevRis9st7cL8jWQVYOBA',
    },
  ];

  String _searchQuery = '';

  List<Map<String, dynamic>> _getFilteredChats(String filterType) {
    final q = _searchQuery.toLowerCase().trim();
    return _chats.where((c) {
      bool matchesSearch = true;
      if (q.isNotEmpty) {
        final name = c['name'].toString().toLowerCase();
        final msg = c['message'].toString().toLowerCase();
        matchesSearch = name.contains(q) || msg.contains(q);
      }
      
      bool matchesFilter = true;
      if (filterType == 'No leídos') {
        matchesFilter = (c['unread'] ?? 0) > 0;
      } else if (filterType == 'Negociaciones') {
        matchesFilter = c['hasPendingNegotiation'] == true;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7);
    // The design shows the main container as white in light mode. Let's adapt that.
    final cardColor = isDark ? const Color(0xFF0f231d) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Container(
            color: cardColor,
            child: Column(
              children: [
                _buildHeader(theme, isDark, cardColor),
                _buildSearchBar(theme, isDark),
                TabBar(
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  tabs: const [
                    Tab(text: 'Chats'),
                    Tab(text: 'No leídos'),
                    Tab(text: 'Negociaciones'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildChatListContent(_getFilteredChats('Chats'), theme, isDark),
                      _buildChatListContent(_getFilteredChats('No leídos'), theme, isDark),
                      _buildChatListContent(_getFilteredChats('Negociaciones'), theme, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, Color bgColor) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
          Text(
            'Mensajes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    final searchBgColor = isDark ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: searchBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Buscar conversaciones...',
            hintStyle: TextStyle(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildChatListContent(List<Map<String, dynamic>> chats, ThemeData theme, bool isDark) {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        itemBuilder: (context, index) {
          return const SkeletonListTile();
        },
      );
    }

    if (chats.isEmpty) {
      return Center(
        child: Text(
          'No hay coincidencias',
          style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
        ),
      );
    }
    return ListView.builder(
      itemCount: chats.length,
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      itemBuilder: (context, index) {
        return _buildChatItem(chats[index], theme, isDark);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/chat-detail'),
        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(chat['photoUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (chat['isOnline'] == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0f231d) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Chat Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            chat['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          chat['time'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                            color: chat['unread'] > 0 ? theme.colorScheme.primary : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat['message'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: chat['unread'] > 0 ? FontWeight.w500 : FontWeight.normal,
                                  color: chat['unread'] > 0 
                                      ? (isDark ? Colors.grey[300] : Colors.grey[600])
                                      : (isDark ? Colors.grey[400] : Colors.grey[500]),
                                ),
                              ),
                              if (chat['hasPendingNegotiation'] == true) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.handshake, size: 12, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Negociación pendiente',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (chat['unread'] > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 20),
                            child: Text(
                              chat['unread'].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (chat['isRead'] == true)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.done_all,
                              size: 16,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
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

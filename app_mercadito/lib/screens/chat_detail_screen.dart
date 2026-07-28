import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/image_verification_service.dart';
import '../widgets/typing_indicator.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? provider;
  const ChatDetailScreen({super.key, this.provider});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with SingleTickerProviderStateMixin {
  String get providerName => widget.provider?['name'] ?? 'Finca La Esperanza';
  String get providerAvatar => widget.provider?['img'] ?? widget.provider?['image'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1-y62nOYyFJ87wJ8XFk4QalbfUVPOWB0Eo3ft82Kz8cCrvoW2OKvmm0tWikghVu0SiZD63IGVwe1Z68hWKVgLfFCGLZSj4q1G4kJNdQ9eJ1mer0RAA-8wAKGb3FWW_R7mvTRDQnxAA9aPbrnIQYDKHs5gpb17cjjifu7lwpgh6r1i6VUk5RsfzbkFVMhQJFSf5Vg8Exy7zAuGqJETv1ccQWXdu_oyrUnSiDBFvoiyr1MOCaJo6XJitj7IyKcK7pcjdxKJ_jbn9VE';
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _msgFocusNode = FocusNode();
  final FocusNode _globalFocusNode = FocusNode();
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  bool _isChatLocked = false;
  String? _cancellationReason;

  final ValueNotifier<Set<String>> _typingUsersNotifier = ValueNotifier({});
  Timer? _typingTimeoutTimer;
  Timer? _localTypingDebounceTimer;
  bool _isLocalUserTyping = false;

  final List<String> _simulatedReplies = [
    'Excelente, ya estamos alistando los sacos de papas andinas de primera calidad.',
    'De acuerdo, te confirmo que la entrega se realizará mañana por la mañana en el punto de encuentro.',
    'Perfecto, si deseas puedo ofrecerte también un lote de zanahorias frescas cosechadas hoy.',
    'Entendido. Por favor verifícalo y me avisas si necesitas algún ajuste adicional en el pedido.',
  ];
  int _replyCounter = 0;

  final ImagePicker _picker = ImagePicker();

  bool _isProductCardVisible = true;
  Timer? _hideTimer;

  void _showProductCard() {
    setState(() {
      _isProductCardVisible = true;
    });
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isProductCardVisible = false;
        });
      }
    });
  }
  Map<String, dynamic>? _replyingMessage;

  final String buyerAvatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBEQ2ncSmK-un9cbsUJEZ52pAPBKVaHAqBxuhb_Ush3pPrUi89-Ee3bTVaR_gnw_31BqzHFwdHhOwh7MIOBEPPlsdjYbJPdbuwGJm5VQboZUJzoPwcV3Z1FhXfM9MaUGr_2E1_-uPJ37qjitJO4bz8nsMjV6KNRyGDg7eUrdJPyWDC53DAiDkdhTilBDb6iR5dDGxJdFDr-JCN5wFn6q23mD2NxIYqM47hXYM1GSdA8BifA_C7979xmHHbcP5Wu-wYZtjedm1SbtPg';
  final String sellerAvatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1-y62nOYyFJ87wJ8XFk4QalbfUVPOWB0Eo3ft82Kz8cCrvoW2OKvmm0tWikghVu0SiZD63IGVwe1Z68hWKVgLfFCGLZSj4q1G4kJNdQ9eJ1mer0RAA-8wAKGb3FWW_R7mvTRDQnxAA9aPbrnIQYDKHs5gpb17cjjifu7lwpgh6r1i6VUk5RsfzbkFVMhQJFSf5Vg8Exy7zAuGqJETv1ccQWXdu_oyrUnSiDBFvoiyr1MOCaJo6XJitj7IyKcK7pcjdxKJ_jbn9VE';

  double _productCurrentPrice = 2.00;
  int _productCurrentQuantity = 20;
  final double _productOriginalPrice = 2.00;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'msg_1',
      'isMe': false,
      'message': '¡Hola! Me interesan los sacos de papas. ¿Tienen disponibilidad?',
      'time': '10:30 AM',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBEQ2ncSmK-un9cbsUJEZ52pAPBKVaHAqBxuhb_Ush3pPrUi89-Ee3bTVaR_gnw_31BqzHFwdHhOwh7MIOBEPPlsdjYbJPdbuwGJm5VQboZUJzoPwcV3Z1FhXfM9MaUGr_2E1_-uPJ37qjitJO4bz8nsMjV6KNRyGDg7eUrdJPyWDC53DAiDkdhTilBDb6iR5dDGxJdFDr-JCN5wFn6q23mD2NxIYqM47hXYM1GSdA8BifA_C7979xmHHbcP5Wu-wYZtjedm1SbtPg',
    },
    {
      'id': 'msg_2',
      'isMe': true,
      'message': '¡Hola Juan! Sí, tenemos disponibilidad inmediata. ¿Cuántos necesitas?',
      'time': '10:32 AM',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB1-y62nOYyFJ87wJ8XFk4QalbfUVPOWB0Eo3ft82Kz8cCrvoW2OKvmm0tWikghVu0SiZD63IGVwe1Z68hWKVgLfFCGLZSj4q1G4kJNdQ9eJ1mer0RAA-8wAKGb3FWW_R7mvTRDQnxAA9aPbrnIQYDKHs5gpb17cjjifu7lwpgh6r1i6VUk5RsfzbkFVMhQJFSf5Vg8Exy7zAuGqJETv1ccQWXdu_oyrUnSiDBFvoiyr1MOCaJo6XJitj7IyKcK7pcjdxKJ_jbn9VE',
    },
    {
      'id': 'msg_3',
      'isMe': false,
      'type': 'proposal',
      'proposalDetails': {
        'proposedPrice': 1.80,
        'originalPrice': 2.00,
        'quantity': 10,
        'total': 18.00,
        'discount': 10.0,
        'message': 'Hola. Me interesa la oferta, pero el precio está un poco alto para la cantidad que necesito. ¿Podemos ajustarlo?',
        'status': 'pending',
      },
      'time': '10:42 AM',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBEQ2ncSmK-un9cbsUJEZ52pAPBKVaHAqBxuhb_Ush3pPrUi89-Ee3bTVaR_gnw_31BqzHFwdHhOwh7MIOBEPPlsdjYbJPdbuwGJm5VQboZUJzoPwcV3Z1FhXfM9MaUGr_2E1_-uPJ37qjitJO4bz8nsMjV6KNRyGDg7eUrdJPyWDC53DAiDkdhTilBDb6iR5dDGxJdFDr-JCN5wFn6q23mD2NxIYqM47hXYM1GSdA8BifA_C7979xmHHbcP5Wu-wYZtjedm1SbtPg',
    }
  ];

  final Map<String, Map<String, dynamic>> _messageMap = {};
  final Map<String, int> _visibleIndexMap = {};
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final ValueNotifier<String?> _highlightedMessageId = ValueNotifier(null);
  bool _isScrollingToReply = false;

  void _rebuildMaps() {
    _messageMap.clear();
    _visibleIndexMap.clear();
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final id = msg['id'] as String;
      _messageMap[id] = msg;
      _visibleIndexMap[id] = i;
    }
  }

  Future<bool> _ensureMessageLoaded(String messageId) async {
    if (_messageMap.containsKey(messageId)) return true;
    // fetch de página anterior
    return false;
  }

  Future<void> _scrollToMessage(String messageId) async {
    if (_isScrollingToReply) return;

    bool loaded = await _ensureMessageLoaded(messageId);
    if (!loaded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El mensaje original no está disponible.')),
        );
      }
      return;
    }

    setState(() {
      _isScrollingToReply = true;
    });

    try {
      final index = _visibleIndexMap[messageId];
      if (index != null && _itemScrollController.isAttached) {
        await _itemScrollController.scrollTo(
          index: index + 1, // +1 por el header
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
        _highlightedMessageId.value = messageId;
        
        await Future.delayed(const Duration(milliseconds: 1500));
        if (_highlightedMessageId.value == messageId) {
          _highlightedMessageId.value = null;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScrollingToReply = false;
        });
      }
    }
  }

  String _generateId() => UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _rebuildMaps();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _startHideTimer();
    
    _msgController.addListener(_onTextChanged);
    _typingUsersNotifier.addListener(_onTypingUsersChanged);
  }

  @override
  void dispose() {
    _msgController.removeListener(_onTextChanged);
    _typingUsersNotifier.removeListener(_onTypingUsersChanged);
    _hideTimer?.cancel();
    _typingTimeoutTimer?.cancel();
    _localTypingDebounceTimer?.cancel();
    _floatController.dispose();
    _msgController.dispose();
    _msgFocusNode.dispose();
    _globalFocusNode.dispose();
    _highlightedMessageId.dispose();
    _typingUsersNotifier.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty && !_isLocalUserTyping) {
      _isLocalUserTyping = true;
      debugPrint("Local user typing: STARTED");
    }

    _localTypingDebounceTimer?.cancel();
    _localTypingDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isLocalUserTyping) {
        _isLocalUserTyping = false;
        debugPrint("Local user typing: STOPPED (Debounce active)");
      }
    });
  }

  void _onTypingUsersChanged() {
    if (_typingUsersNotifier.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isUserNearBottom() && _itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: _messages.length + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool _isUserNearBottom() {
    if (!_itemPositionsListener.itemPositions.value.isNotEmpty) return true;
    final positions = _itemPositionsListener.itemPositions.value;
    int maxIndex = -1;
    for (final position in positions) {
      if (position.index > maxIndex) {
        maxIndex = position.index;
      }
    }
    return maxIndex >= _messages.length - 1;
  }

  String _getReplyForMessage(String userMsg) {
    final msg = userMsg.toLowerCase();
    if (msg.contains('aceptado') || msg.contains('aceptar la oferta') || msg.contains('he aceptado la contraoferta')) {
      return '¡Excelente decisión! Ya he registrado tu confirmación de compra y comenzaremos a preparar el despacho de los sacos de papas de inmediato.';
    }
    if (msg.contains('envivo') || msg.contains('en vivo') || msg.contains('transmisión')) {
      return 'Claro que sí, con mucho gusto. Ya me encuentro en el campo de cultivo listo para mostrarte la calidad de las papas. ¡Inicio la transmisión ahora mismo!';
    }
    if (msg.contains('propuesta') || msg.contains('contraoferta') || msg.contains('ofrezco')) {
      return 'He recibido tu propuesta de precio. Déjame revisar el inventario con el equipo y te confirmo si podemos cerrar el trato con esos números.';
    }
    final reply = _simulatedReplies[_replyCounter % _simulatedReplies.length];
    _replyCounter++;
    return reply;
  }

  void _triggerSimulatedResponse(String userMsg) {
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final responseText = _getReplyForMessage(userMsg);
      final writerName = providerName;

      final typingDuration = Duration(
        milliseconds: (responseText.length * 30).clamp(1000, 3000),
      );

      _typingUsersNotifier.value = {..._typingUsersNotifier.value}..add(writerName);

      _typingTimeoutTimer?.cancel();
      _typingTimeoutTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _typingUsersNotifier.value.contains(writerName)) {
          _typingUsersNotifier.value = {..._typingUsersNotifier.value}..remove(writerName);
          debugPrint("Typing timeout safety trigger fired.");
        }
      });

      Timer(typingDuration, () {
        if (!mounted) return;

        if (_typingUsersNotifier.value.contains(writerName)) {
          _typingTimeoutTimer?.cancel();

          setState(() {
            _typingUsersNotifier.value = {..._typingUsersNotifier.value}..remove(writerName);

            _messages.add({
              'id': _generateId(),
              'isMe': false,
              'message': responseText,
              'time': _formatCurrentTime(),
              'avatarUrl': buyerAvatar,
            });
            _rebuildMaps();
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isUserNearBottom() && _itemScrollController.isAttached) {
              _itemScrollController.scrollTo(
                index: _messages.length,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingMessage = null;
    });
  }

  void _replyToMessage(Map<String, dynamic> message) {
    setState(() {
      _replyingMessage = message;
    });
    _msgFocusNode.requestFocus();
  }

  void _acceptProposal(int index) {
    final msgText = 'He aceptado la contraoferta de \$${_messages[index]['proposalDetails']['proposedPrice'].toStringAsFixed(2)} por cada saco.';
    setState(() {
      var details = _messages[index]['proposalDetails'];
      details['status'] = 'accepted';
      _productCurrentPrice = details['proposedPrice'];
      _productCurrentQuantity = details['quantity'];

      _messages.add({
        'id': _generateId(),
        'isMe': true,
        'message': msgText,
        'time': _formatCurrentTime(),
        'avatarUrl': sellerAvatar,
      });
      _rebuildMaps();
      _scrollToBottom();
      _showProductCard();
    });
    _triggerSimulatedResponse(msgText);
  }

  void _rejectProposal(int index) {
    const msgText = 'He rechazado la contraoferta propuesta.';
    setState(() {
      var details = _messages[index]['proposalDetails'];
      details['status'] = 'rejected';

      _messages.add({
        'id': _generateId(),
        'isMe': true,
        'message': msgText,
        'time': _formatCurrentTime(),
        'avatarUrl': sellerAvatar,
      });
      _rebuildMaps();
      _scrollToBottom();
      _showProductCard();
    });
    _triggerSimulatedResponse(msgText);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final verification = await ImageVerificationService.analyzeImage(image, source);

        setState(() {
          _messages.add({
            'id': _generateId(),
            'isMe': true,
            'message': '',
            'imagePath': image.path,
            'isLive': verification.isLive,
            'repliedTo': _replyingMessage,
            'time': _formatCurrentTime(),
            'avatarUrl': sellerAvatar,
          });
          _rebuildMaps();
          _replyingMessage = null;
        });
        _scrollToBottom();
        _msgFocusNode.requestFocus();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          'id': _generateId(),
          'isMe': true,
          'message': text,
          'repliedTo': _replyingMessage,
          'time': _formatCurrentTime(),
          'avatarUrl': sellerAvatar,
        });
        _rebuildMaps();
        _replyingMessage = null;
      });
      _msgController.clear();
      _scrollToBottom();
      _msgFocusNode.requestFocus();
      _triggerSimulatedResponse(text);
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _scrollToBottom() {
    if (_itemScrollController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.scrollTo(
          index: _messages.length,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showCounterOfferModal({int? replaceProposalIndex}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    double proposedPrice = _productCurrentPrice;
    int quantity = _productCurrentQuantity;
    TextEditingController messageController = TextEditingController();
    TextEditingController priceController = TextEditingController(text: proposedPrice.toStringAsFixed(2));
    TextEditingController qtyController = TextEditingController(text: quantity.toString());

    String selectedUnit = 'Saco';
    List<String> availableUnits = ['Por Libra', 'Unidad', 'Saco', 'Caja'];

    Map<String, int> getUnitLimits(String unit) {
      if (unit.toLowerCase().contains('unidad')) return {'min': 5, 'max': 20};
      if (unit.toLowerCase().contains('libra')) return {'min': 2, 'max': 50};
      if (unit.toLowerCase().contains('saco')) return {'min': 1, 'max': 10};
      if (unit.toLowerCase().contains('caja')) return {'min': 1, 'max': 15};
      return {'min': 1, 'max': 99};
    }

    void updateQuantity(int newQty, Function setModalState) {
      var limits = getUnitLimits(selectedUnit);
      int min = limits['min']!;
      int max = limits['max']!;

      if (newQty < min || newQty == 0) newQty = min;
      if (newQty > max) newQty = max;

      setModalState(() {
        quantity = newQty;
        qtyController.text = quantity.toString();
        qtyController.selection = TextSelection.fromPosition(TextPosition(offset: qtyController.text.length));
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double currentParsedPrice = double.tryParse(priceController.text) ?? 0.0;
            double total = currentParsedPrice * quantity;
            double originalTotal = _productOriginalPrice * quantity;
            double discount = originalTotal > 0 ? ((_productOriginalPrice - currentParsedPrice) / _productOriginalPrice) * 100 : 0;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1a1c19) : const Color(0xFFf7faf5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nueva Propuesta', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
                          IconButton(
                            icon: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ]
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDF1uvpU6uAS3dZhqbyOQpOyM97bXDSRlzcu4LSbvvoC0K51vi51R8sLZuEKofKA7TrQww6j7GUw4UCjKZ1XEv3aKPBDpNaKui_eV1DUTHBQNNOUaNj4hVBwOHsuFlPdBtPpHmR7ivJz6t62ecm_3M0pwwjh9CCponfDmGIKNPfwIW8KSbLYfihl07t-lhovIOVhlwX4NKWVHv6INsQiNbXqyiPt9IjZv6q5Koq8iYsNVKLM1a7ZX9qhW3gfbIgzRadX4kUC68tmrM',
                                width: 60, height: 60, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Saco de Papas (50kg)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Precio por unidad', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                          ),
                          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w500, fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                          onChanged: (val) {
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Precio Original: \$${_productOriginalPrice.toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                          if (discount > 0)
                            Text('-${discount.toStringAsFixed(0)}%', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: const Color(0xFFF98436), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tipo de Unidad', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                          Text('Mín. ${getUnitLimits(selectedUnit)['min']} | Máx. ${getUnitLimits(selectedUnit)['max']}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: availableUnits.map((unit) {
                            final isSelected = selectedUnit == unit;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedUnit = unit;
                                  updateQuantity(quantity, setModalState);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey[800] : const Color(0xFFe9eceb)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  unit,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : const Color(0xFF88968f)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text('Cantidad ($selectedUnit)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ]
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => updateQuantity(quantity - 1, setModalState),
                            ),
                            Expanded(
                              child: TextField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  if (val.isEmpty) return;
                                  int newQty = int.tryParse(val) ?? getUnitLimits(selectedUnit)['min']!;
                                  setModalState(() {
                                    quantity = newQty;
                                  });
                                },
                                onSubmitted: (val) {
                                  int newQty = int.tryParse(val) ?? getUnitLimits(selectedUnit)['min']!;
                                  updateQuantity(newQty, setModalState);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => updateQuantity(quantity + 1, setModalState),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Mensaje al vendedor (Opcional)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.black26 : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Justifica tu nueva propuesta...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        ),
                        style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal ($quantity x \$${currentParsedPrice.toStringAsFixed(2)})', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total de la Propuesta', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                                Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 24, color: theme.colorScheme.primary)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('ENVIAR PROPUESTA', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          onPressed: () {
                            Navigator.pop(context);
                            _sendCounterOffer(
                              proposedPrice: currentParsedPrice,
                              quantity: quantity,
                              message: messageController.text.trim(),
                              replaceIndex: replaceProposalIndex,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _sendCounterOffer({required double proposedPrice, required int quantity, required String message, int? replaceIndex}) {
    setState(() {
      if (replaceIndex != null && replaceIndex >= 0 && replaceIndex < _messages.length) {
        _messages[replaceIndex]['proposalDetails']['status'] = 'cancelled';
        _messages.add({
          'id': _generateId(),
          'isMe': true,
          'message': 'He cancelado mi propuesta anterior.',
          'time': _formatCurrentTime(),
          'avatarUrl': sellerAvatar,
        });
        _rebuildMaps();
      }

      double originalTotal = _productOriginalPrice * quantity;
      double total = proposedPrice * quantity;
      double discount = originalTotal > 0 ? ((_productOriginalPrice - proposedPrice) / _productOriginalPrice) * 100 : 0;

      _messages.add({
        'id': _generateId(),
        'isMe': true,
        'type': 'proposal',
        'proposalDetails': {
          'proposedPrice': proposedPrice,
          'originalPrice': _productOriginalPrice,
          'quantity': quantity,
          'total': total,
          'discount': discount,
          'message': message,
          'status': 'pending',
        },
        'time': _formatCurrentTime(),
        'avatarUrl': sellerAvatar,
      });
      _rebuildMaps();
      _scrollToBottom();
      _showProductCard();
    });
    _triggerSimulatedResponse(message.isNotEmpty ? message : 'Nueva propuesta de precio de \$${proposedPrice.toStringAsFixed(2)}');
  }

  void _sendLiveRequest() {
    setState(() {
      _messages.add({
        'id': _generateId(),
        'isMe': true,
        'type': 'live_request',
        'time': _formatCurrentTime(),
        'avatarUrl': sellerAvatar,
        'location': 'Valle Central',
        'spectators': '1,240',
      });
      _rebuildMaps();
      _scrollToBottom();
    });
    _triggerSimulatedResponse('Solicitar Producto EnVivo');
  }

  void _showFullScreenImage(BuildContext context, String imagePath, bool? isLive) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: kIsWeb ? Image.network(imagePath) : Image.file(File(imagePath)),
                ),
              ),
              if (isLive != null)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLive ? 'La imagen fue tomada en el momento' : 'La imagen fue tomada de la galería',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF0f231d) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1f2937) : const Color(0xFFf5f8f7);
    final borderColor = theme.colorScheme.primary.withValues(alpha: 0.1);

    return KeyboardListener(
      focusNode: _globalFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_msgFocusNode.hasFocus) {
          final char = event.character;
          if (char != null && char.isNotEmpty) {
            _msgFocusNode.requestFocus();
            // Append character and move cursor to end
            _msgController.text = _msgController.text + char;
            _msgController.selection = TextSelection.fromPosition(
              TextPosition(offset: _msgController.text.length),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(theme, isDark, borderColor),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isProductCardVisible 
                      ? _buildStickyProductCard(theme, isDark, borderColor) 
                      : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: _buildChatList(theme, isDark),
                  ),
                  _buildInputArea(theme, isDark, borderColor),
                ],
              ),
              if (!_isProductCardVisible)
                Positioned(
                  top: 80,
                  right: 16,
                  child: GestureDetector(
                    onTap: _showProductCard,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), 
                            blurRadius: 8, 
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: theme.colorScheme.primary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBdOrqWuBFawImokgw7aX4L0qj7thCEzuBv9_58c_qq_VHRaRgCk6Mdx08Hnv8ygoNk3uBHysg750fc4pl7lLgQlqo9iCjrf-nftrhS_NLlHpyeu1oAdXYgpR-PuGErGXKt28TrVGL2arbyQ-mm3Nq6qJiGc4B4uHS8Yi_iSiT_gwrQIsRr4j2penpybXR1s8ieA7YKs277sSdLmlV4wEwJcnsW0PJz9S2uIL01AqgZsZOBinWZZ4yReKTfrU6jCpFNlqS_VnSceaY'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.touch_app, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: _typingUsersNotifier,
                    builder: (context, typingUsers, child) {
                      final isTyping = typingUsers.isNotEmpty;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: isTyping
                            ? Row(
                                key: const ValueKey('status_typing'),
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'ESCRIBIENDO...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2E7D32),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                key: const ValueKey('status_online'),
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'EN LÍNEA',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.call, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyProductCard(ThemeData theme, bool isDark, Color borderColor) {
    final cardBg = isDark ? const Color(0xFF1a1c19) : Colors.white;

    return Container(
      color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {
            context.push('/product_detail', extra: {
              'id': 'papas_andinas',
              'name': 'Saco de Papas (50kg)',
              'price': '\$${_productCurrentPrice.toStringAsFixed(2)}',
              'originalPrice': '\$25.00',
              'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBdOrqWuBFawImokgw7aX4L0qj7thCEzuBv9_58c_qq_VHRaRgCk6Mdx08Hnv8ygoNk3uBHysg750fc4pl7lLgQlqo9iCjrf-nftrhS_NLlHpyeu1oAdXYgpR-PuGErGXKt28TrVGL2arbyQ-mm3Nq6qJiGc4B4uHS8Yi_iSiT_gwrQIsRr4j2penpybXR1s8ieA7YKs277sSdLmlV4wEwJcnsW0PJz9S2uIL01AqgZsZOBinWZZ4yReKTfrU6jCpFNlqS_VnSceaY',
              'supplier': 'Finca El Sol',
              'rating': '4.8',
              'reviews': '124',
              'isFavorite': false,
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saco de Papas (50kg)',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'PRECIO DE COMPRA:',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '\$${_productCurrentPrice.toStringAsFixed(2)} / saco',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'CANTIDAD:',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_productCurrentQuantity sacos',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBdOrqWuBFawImokgw7aX4L0qj7thCEzuBv9_58c_qq_VHRaRgCk6Mdx08Hnv8ygoNk3uBHysg750fc4pl7lLgQlqo9iCjrf-nftrhS_NLlHpyeu1oAdXYgpR-PuGErGXKt28TrVGL2arbyQ-mm3Nq6qJiGc4B4uHS8Yi_iSiT_gwrQIsRr4j2penpybXR1s8ieA7YKs277sSdLmlV4wEwJcnsW0PJz9S2uIL01AqgZsZOBinWZZ4yReKTfrU6jCpFNlqS_VnSceaY'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.symmetric(
                      horizontal: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '\$${(_productCurrentPrice * _productCurrentQuantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _isChatLocked
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2c1c1c) : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF8A3A3A) : Colors.red[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel, color: isDark ? const Color(0xFFFF8B8B) : Colors.red[700], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'NEGOCIACIÓN CANCELADA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  color: isDark ? const Color(0xFFFF8B8B) : Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showCancelNegotiationBottomSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[50], 
                                  foregroundColor: Colors.red[700], 
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: const Text('Cancelar', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15), 
                                  foregroundColor: theme.colorScheme.primary, 
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: const Text('Finalizar', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
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

  void _showCancelNegotiationBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    String selectedReason = 'Encontré un mejor precio';
    final TextEditingController commentsController = TextEditingController(text: _msgController.text);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181d1a) : const Color(0xFFf7faf5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cancelar Negociación',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFffdad6) : const Color(0xFF93000a),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lamentamos que la negociación no haya concluido. Por favor, ayúdanos a entender el motivo.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Product Preview Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0f1613) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBdOrqWuBFawImokgw7aX4L0qj7thCEzuBv9_58c_qq_VHRaRgCk6Mdx08Hnv8ygoNk3uBHysg750fc4pl7lLgQlqo9iCjrf-nftrhS_NLlHpyeu1oAdXYgpR-PuGErGXKt28TrVGL2arbyQ-mm3Nq6qJiGc4B4uHS8Yi_iSiT_gwrQIsRr4j2penpybXR1s8ieA7YKs277sSdLmlV4wEwJcnsW0PJz9S2uIL01AqgZsZOBinWZZ4yReKTfrU6jCpFNlqS_VnSceaY'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRODUCTO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Saco de Papas (50kg)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(_productCurrentPrice * _productCurrentQuantity).toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Reasons List
                  ...[
                    'Encontré un mejor precio',
                    'El producto ya no está disponible',
                    'Cambio de planes',
                    'Problemas con el proveedor',
                    'Otro (especificar)',
                  ].map((reason) {
                    final isSelected = selectedReason == reason;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedReason = reason;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? (isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f))
                                      : (isDark ? Colors.white30 : Colors.black26),
                                  width: isSelected ? 6 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reason,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? (isDark ? const Color(0xFF89d6b0) : const Color(0xFF00462f))
                                    : (isDark ? Colors.grey[300] : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // Comments area header with character counter and mandatory label
                  Builder(
                    builder: (context) {
                      final bool isCommentRequired = selectedReason == 'Problemas con el proveedor' || selectedReason == 'Otro (especificar)';
                      final int currentLength = commentsController.text.trim().length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isCommentRequired ? 'Cuéntanos más (Obligatorio)*' : 'Cuéntanos más (Opcional)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCommentRequired 
                                      ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A))
                                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                ),
                              ),
                              Text(
                                '$currentLength/500',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0f1613) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCommentRequired && currentLength < 28
                                    ? (isDark ? const Color(0xFFBA1A1A) : const Color(0xFFFFDAD6))
                                    : (isDark ? Colors.white12 : Colors.grey[200]!),
                                width: isCommentRequired && currentLength < 28 ? 1.5 : 1.0,
                              ),
                            ),
                            child: TextField(
                              controller: commentsController,
                              maxLines: 3,
                              maxLength: 500,
                              onChanged: (text) {
                                setModalState(() {});
                              },
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: isCommentRequired 
                                    ? 'Por favor, detalle el motivo (mínimo 28 caracteres)...' 
                                    : 'Cuéntanos más...',
                                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 13),
                                contentPadding: const EdgeInsets.all(12),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                          if (isCommentRequired && currentLength < 28) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded, 
                                  color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A), 
                                  size: 14
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Por favor brinde más detalles (faltan ${28 - currentLength} caracteres).',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons
                  Builder(
                    builder: (context) {
                      final bool isCommentRequired = selectedReason == 'Problemas con el proveedor' || selectedReason == 'Otro (especificar)';
                      final int currentLength = commentsController.text.trim().length;
                      final bool isButtonEnabled = !isCommentRequired || (currentLength >= 28 && currentLength <= 500);
                      
                      return ElevatedButton(
                        onPressed: isButtonEnabled ? () {
                          final finalReason = selectedReason == 'Otro (especificar)' 
                              ? (commentsController.text.isNotEmpty ? commentsController.text : 'Otro motivo')
                              : selectedReason;
                          
                          Navigator.pop(context);
                          
                          _confirmCancellation(finalReason, commentsController.text);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled ? const Color(0xFFba1a1a) : (isDark ? Colors.white12 : Colors.black12),
                          foregroundColor: isButtonEnabled ? Colors.white : (isDark ? Colors.white30 : Colors.black38),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmar Cancelación',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Volver',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCancellation(String reason, String comments) {
    setState(() {
      _isChatLocked = true;
      _cancellationReason = reason;
      
      // Update proposal status of the last proposal message to 'cancelled' if any
      for (int i = _messages.length - 1; i >= 0; i--) {
        if (_messages[i]['type'] == 'proposal') {
          _messages[i]['proposalDetails']['status'] = 'cancelled';
          break;
        }
      }
      
      // Add the system cancellation message to the list
      _messages.add({
        'id': 'msg_cancelled_system_${DateTime.now().millisecondsSinceEpoch}',
        'isMe': false,
        'type': 'system_cancelled',
        'message': reason,
        'comments': comments,
        'time': 'Justo ahora',
        'avatarUrl': sellerAvatar,
      });
    });
    
    // Auto-scroll to the bottom to show the system card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: _messages.length,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatList(ThemeData theme, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0f231d) : const Color(0xFFf5f8f7),
      child: ValueListenableBuilder<Set<String>>(
        valueListenable: _typingUsersNotifier,
        builder: (context, typingUsers, child) {
          final hasTyping = typingUsers.isNotEmpty;
          return ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + 1 + (hasTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'HOY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }

              // Typing Indicator item at bottom of list
              if (index == _messages.length + 1) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasTyping ? 1.0 : 0.0,
                    child: hasTyping
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TypingIndicator(
                              userName: typingUsers.first,
                              avatarUrl: buyerAvatar,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              }

              final msg = _messages[index - 1];
              return Padding(
                key: ValueKey(msg['id']),
                padding: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: ValueKey(index),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (direction) async {
                    _replyToMessage(msg);
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: Icon(Icons.reply, color: theme.colorScheme.primary),
                  ),
                  child: _buildMessageRow(
                    context,
                    index: index - 1,
                    id: msg['id'],
                    isMe: msg['isMe'],
                    message: msg['message'],
                    type: msg['type'],
                    proposalDetails: msg['proposalDetails'],
                    imagePath: msg['imagePath'],
                    isLive: msg['isLive'],
                    repliedTo: msg['repliedTo'],
                    time: msg['time'],
                    avatarUrl: msg['avatarUrl'],
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageRow(
    BuildContext context, {
    required int index,
    required String id,
    required bool isMe,
    String? message,
    String? type,
    Map<String, dynamic>? proposalDetails,
    String? imagePath,
    bool? isLive,
    Map<String, dynamic>? repliedTo,
    required String time,
    required String avatarUrl,
    required ThemeData theme,
    required bool isDark,
  }) {
    if (type == 'system_cancelled') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2c1c1c) : const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF8A3A3A) : const Color(0xFFFFC1C1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF4A1F1F) : const Color(0xFFFFD6D6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel, color: isDark ? const Color(0xFFFF8B8B) : const Color(0xFFD32F2F), size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'Negociación Cancelada',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? const Color(0xFFFFE0E0) : const Color(0xFFC2185B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1212) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOTIVO DE CANCELACIÓN',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message ?? 'No especificado',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    if (_messages[index]['comments'] != null && _messages[index]['comments'].toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF171a18) : const Color(0xFFF6F8F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'NOTA DEL COMPRADOR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _messages[index]['comments'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.grey[300] : Colors.grey[750],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Los fondos retenidos (si los hubo) han sido liberados.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (type == 'proposal' && proposalDetails != null) {
      String status = proposalDetails['status'];
      bool isPending = status == 'pending';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 20),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(isMe ? 'Tú' : 'Juan Pérez', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 4),
                  
                  if (proposalDetails['message'] != null && proposalDetails['message'].isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? theme.colorScheme.primary : (isDark ? const Color(0xFF1f2937) : Colors.white),
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                          bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          if (!isDark && !isMe)
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Text(
                        proposalDetails['message'],
                        style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87)),
                      ),
                    ),

                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1a1c19) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : theme.colorScheme.outline.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isPending ? theme.colorScheme.primary : (status == 'accepted' ? Colors.green[700] : Colors.grey[600]),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          ),
                          child: Row(
                            children: [
                              Icon(isPending ? Icons.handshake : (status == 'accepted' ? Icons.check_circle : Icons.cancel), color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isPending ? (isMe ? 'CONTRAOFERTA ENVIADA' : 'CONTRAOFERTA RECIBIDA') : (status == 'accepted' ? 'PROPUESTA ACEPTADA' : (status == 'rejected' ? 'PROPUESTA RECHAZADA' : 'PROPUESTA CANCELADA')),
                                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white, letterSpacing: 1.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Precio Propuesto', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w900, fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600], letterSpacing: 1.0)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('\$${proposalDetails['proposedPrice'].toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 20, color: theme.colorScheme.primary)),
                                          const SizedBox(width: 4),
                                          Text('/ saco', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                        ],
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Original', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w900, fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600], letterSpacing: 1.0)),
                                      Text('\$${proposalDetails['originalPrice'].toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[400], decoration: TextDecoration.lineThrough)),
                                    ],
                                  )
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cantidad', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w900, fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600], letterSpacing: 1.0)),
                                      Text('${proposalDetails['quantity']} sacos', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info, size: 14, color: theme.colorScheme.onSecondaryContainer),
                                        const SizedBox(width: 4),
                                        Text('Total: \$${proposalDetails['total'].toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 10, color: theme.colorScheme.onSecondaryContainer, letterSpacing: 0.5)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if (proposalDetails['discount'] > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2d312e) : const Color(0xFFf7faf5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: const Border(left: BorderSide(color: Color(0xFFF98436), width: 4)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.analytics, size: 18, color: Color(0xFFF98436)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isMe ? 'Has solicitado un descuento del ${proposalDetails['discount'].toStringAsFixed(0)}% sobre el precio original.' : 'Juan solicita un descuento del ${proposalDetails['discount'].toStringAsFixed(0)}% sobre el precio original.',
                                            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isPending)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                if (!isMe)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    label: const Text('ACEPTAR CONTRAOFERTA', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                                    onPressed: () => _acceptProposal(index),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (!isMe)
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                                            foregroundColor: isDark ? Colors.white : Colors.black87,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => _rejectProposal(index),
                                          child: const Text('RECHAZAR', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
                                        ),
                                      ),
                                    if (!isMe)
                                      const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: theme.colorScheme.primary),
                                          foregroundColor: theme.colorScheme.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _showCounterOfferModal(replaceProposalIndex: index),
                                        child: const Text('NUEVA PROPUESTA', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[400])),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all, size: 14, color: theme.colorScheme.primary),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (type == 'live_request') {
      return _buildLiveRequestBubble(
        context,
        isMe: isMe,
        time: time,
        avatarUrl: avatarUrl,
        theme: theme,
        isDark: isDark,
        location: proposalDetails?['location'] ?? 'Valle Central',
        spectators: proposalDetails?['spectators'] ?? '1,240',
      );
    }
    
    final bubbleColor = isMe 
      ? theme.colorScheme.primary 
      : (isDark ? const Color(0xFF1f2937) : Colors.white);
      
    final textColor = isMe 
      ? Colors.white 
      : (isDark ? Colors.grey[200] : Colors.black87);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: ValueListenableBuilder<String?>(
            valueListenable: _highlightedMessageId,
            builder: (context, highlightedId, child) {
              final isHighlighted = highlightedId == id;
              return TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 300),
                tween: ColorTween(
                  begin: bubbleColor,
                  end: isHighlighted ? theme.colorScheme.tertiaryContainer : bubbleColor,
                ),
                builder: (context, animatedColor, child) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: animatedColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (repliedTo != null)
                  GestureDetector(
                    onTap: () {
                      final targetId = repliedTo['id'] as String?;
                      if (targetId != null) {
                        _scrollToMessage(targetId);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E9E4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repliedTo['isMe'] == true ? 'Tú' : 'Finca La Esperanza',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (repliedTo['imagePath'] != null)
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo, size: 12, color: Colors.black87),
                                SizedBox(width: 4),
                                Text('Foto', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            )
                          else
                            Text(
                              repliedTo['message'] ?? '',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, imagePath, isLive),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(
                                    imagePath,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(imagePath),
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        if (isLive != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLive ? Icons.camera_alt : Icons.photo_library,
                                  size: 12,
                                  color: isLive ? Colors.green[400] : Colors.red[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLive ? 'En Vivo' : 'De galería',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isLive ? Colors.green[400] : Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (message != null && message.isNotEmpty)
                  Text(message, style: TextStyle(color: textColor, fontSize: 14, height: 1.4)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.grey[400],
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: Colors.white),
                    ]
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
    if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ]
      ],
    );
  }

  Widget _buildLiveRequestBubble(
    BuildContext context, {
    required bool isMe,
    required String time,
    required String avatarUrl,
    required ThemeData theme,
    required bool isDark,
    required String location,
    required String spectators,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 20),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? 'Tú' : 'Juan Pérez',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 320),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.05) 
                                : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFba1a1a),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFba1a1a).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _PulseDot(),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Solicitud de Cosecha envivo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  height: 1.2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'El comprador Juan Pérez Solicita ver la cosecha envivo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: const Color(0xFF3E7F67),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Pide una transmisión en directo para verificar la calidad del producto.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 8,
                                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                ),
                                onPressed: () {},
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'En espera de respuesta',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 20),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFba1a1a),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                child: const Text(
                                  'cancelar envivo',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 20),
              child: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isDark, Color borderColor) {
    if (_isChatLocked) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0f231d) : Colors.white,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 16 : 16,
        ),
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1f2937) : const Color(0xFFebefea),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: isDark ? Colors.grey[400] : const Color(0xFF6f7a73), size: 18),
              const SizedBox(width: 8),
              Text(
                'ESTE CHAT ESTÁ CERRADO',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey[400] : const Color(0xFF6f7a73),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0f231d) : Colors.white,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9E4),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingMessage!['isMe'] == true ? 'Respondiendo a ti' : 'Respondiendo a Finca La Esperanza',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_replyingMessage!['imagePath'] != null)
                          const Row(
                            children: [
                              Icon(Icons.photo, size: 14, color: Colors.black87),
                              SizedBox(width: 4),
                              Text('Foto', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          )
                        else
                          Text(
                            _replyingMessage!['message'] ?? '',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.black87),
                    onPressed: _cancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.photo_camera, color: theme.colorScheme.primary),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1f2937) : const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _msgController,
                    focusNode: _msgFocusNode,
                    autofocus: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick Options
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickOption('Aceptar oferta', theme, isDark),
                const SizedBox(width: 8),
                _buildQuickOption('Contraoferta', theme, isDark),
                const SizedBox(width: 8),
                _buildQuickOption('Solicitar Producto EnVivo', theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption(String text, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () {
        if (text == 'Contraoferta') {
          _showCounterOfferModal();
        } else if (text == 'Solicitar Producto EnVivo') {
          _sendLiveRequest();
        } else {
          _msgController.text = text;
          _sendMessage();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

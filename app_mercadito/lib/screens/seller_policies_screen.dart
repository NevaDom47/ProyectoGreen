import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_session.dart';

class SellerPoliciesScreen extends StatefulWidget {
  const SellerPoliciesScreen({super.key});

  @override
  State<SellerPoliciesScreen> createState() => _SellerPoliciesScreenState();
}

class _SellerPoliciesScreenState extends State<SellerPoliciesScreen> {
  static const int maxPolicies = 5;
  static const int maxPolicyLength = 80;

  late List<String> _policies;
  final TextEditingController _newPolicyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _policies = List<String>.from(UserSession.currentSellerPolicies);
    if (_policies.length > maxPolicies) {
      _policies = _policies.sublist(0, maxPolicies);
    }
  }

  @override
  void dispose() {
    _newPolicyController.dispose();
    super.dispose();
  }

  void _addPolicy() {
    if (_policies.length >= maxPolicies) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Has alcanzado el límite máximo de 5 políticas'),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final text = _newPolicyController.text.trim();
    if (text.isNotEmpty) {
      final validText = text.length > maxPolicyLength ? text.substring(0, maxPolicyLength) : text;
      setState(() {
        _policies.add(validText);
        _newPolicyController.clear();
      });
    }
  }

  void _removePolicy(int index) {
    setState(() {
      _policies.removeAt(index);
    });
  }

  void _resetToDefault() {
    setState(() {
      _policies = List<String>.from(UserSession.defaultSellerPolicies);
      if (_policies.length > maxPolicies) {
        _policies = _policies.sublist(0, maxPolicies);
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se han restablecido las políticas sugeridas'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _savePolicies() {
    setState(() {
      UserSession.sellerPolicies = List<String>.from(_policies);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Políticas del vendedor guardadas exitosamente'),
        backgroundColor: Color(0xFF016042),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0f231d) : const Color(0xFFf7faf5);
    final cardBgColor = isDark ? const Color(0xFF13281E) : Colors.white;
    final primaryColor = isDark ? const Color(0xFF67C83B) : const Color(0xFF016042);
    final onSurfaceColor = isDark ? Colors.white : const Color(0xFF181d1a);
    final onSurfaceVariant = isDark ? const Color(0xFFbec9c1) : const Color(0xFF5f6368);
    final isLimitReached = _policies.length >= maxPolicies;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Políticas del Vendedor',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Restablecer sugerencias',
            color: primaryColor,
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta informativa de cabecera
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE8F3EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_user_outlined, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reglas y Condiciones Comerciales',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estas políticas serán visibles para los clientes que visiten tu perfil de negocio o negocien pedidos contigo.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lista de políticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Políticas Vigentes (${_policies.length}/$maxPolicies)',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                    ),
                  ),
                  if (isLimitReached)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Máximo alcanzado',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.amber[300] : Colors.amber[900],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_policies.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No tienes políticas definidas aún. Agrega una abajo o restablece las sugeridas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_policies.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF016042)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _policies[index],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: onSurfaceColor,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                          tooltip: 'Eliminar',
                          onPressed: () => _removePolicy(index),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 20),

              // Agregar nueva política
              Text(
                'Agregar Nueva Política',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _newPolicyController,
                      enabled: !isLimitReached,
                      maxLength: maxPolicyLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(maxPolicyLength),
                      ],
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Nueva Política',
                        helperText: isLimitReached ? 'Límite de 5 políticas alcanzado' : 'Máximo 80 caracteres',
                        hintText: isLimitReached
                            ? 'Elimina alguna política para agregar una nueva.'
                            : 'Ej. Se requiere anticipo del 30% para pedidos por volumen...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: isLimitReached,
                        fillColor: isDark ? Colors.white10 : const Color(0xFFF1F4F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: isLimitReached ? null : _addPolicy,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          isLimitReached ? 'Límite de 5 políticas alcanzado' : 'Añadir a la lista',
                          style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(
                            color: isLimitReached ? Colors.grey.withValues(alpha: 0.3) : primaryColor,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón Guardar Cambios
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _savePolicies,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text(
                    'Guardar Políticas',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF016042),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


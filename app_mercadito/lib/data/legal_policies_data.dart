// Archivo generado con las politicas legales oficiales de El Mercadito
// Entidad responsable: Diaz Tecnologies (contacto@diaztecnologies.es)
import 'package:flutter/material.dart';

class PolicyClause {
  final String title;
  final String? subtitle;
  final String content;
  final List<String> points;

  const PolicyClause({
    required this.title,
    this.subtitle,
    required this.content,
    this.points = const [],
  });
}

class LegalDocument {
  final String title;
  final String subtitle;
  final String lastUpdated;
  final IconData icon;
  final List<PolicyClause> clauses;

  const LegalDocument({
    required this.title,
    required this.subtitle,
    required this.lastUpdated,
    required this.icon,
    required this.clauses,
  });
}

class LegalPoliciesData {
  static const String contactEmail = 'contacto@diaztecnologies.es';
  static const String alternateEmail = 'contacto@diaztecnologies.com';
  static const String entityName = 'Diaz Tecnologies';
  static const String lastUpdatedText = '24 de mayo de 2024';

  static const LegalDocument terminosYCondiciones = LegalDocument(
    title: 'Términos y Condiciones',
    subtitle: 'Condiciones de uso y contratación del servicio en El Mercadito',
    lastUpdated: '24 de mayo de 2024',
    icon: Icons.description_outlined,
    clauses: [
      PolicyClause(
        title: '1. General',
        content: 'Esta política describe cómo Mercadito (la "Plataforma") trata información relacionada con sus usuarios. La entidad responsable se identifica provisionalmente como Diaz Tecnologies, con correo de contacto contacto@diaztecnologies.es. Presta servicios a los usuarios según los siguientes Términos y Condiciones.\n\nEl uso de cualquier servicio ofrecido por Mercadito estará sujeto a los lineamientos y condiciones aplicables a tal Servicio o negocio. El desconocimiento de los Términos y Condiciones no justifica su incumplimiento.\n\nAl registrarse, los usuarios manifiestan su aceptación a estos Términos y Condiciones y a las demás políticas presentes en Mercadito.\n\nLa Plataforma facilita interacciones entre compradores y proveedores/vendedores de productos agrícolas y de mercado, incluyendo perfiles, catálogos, publicaciones, mensajes, negociaciones, pedidos, cupones, valoraciones y funciones de pago o recomendación habilitadas.\n\nLos menores de 18 años requieren autorización de sus padres antes de registrarse. CUALQUIER PERSONA QUE NO ACEPTE ESTOS TÉRMINOS Y CONDICIONES DEBERÁ ABSTENERSE DE UTILIZAR LA PLATAFORMA.',
      ),
      PolicyClause(
        title: '2. Privacidad',
        content: 'Revisar nuestra Política de Privacidad disponible en la plataforma, que también rige la relación con Mercadito, a fin de entender la información que obtenemos de los Usuarios y el uso que damos a esa información.',
      ),
      PolicyClause(
        title: '3. Naturaleza de la plataforma',
        content: 'Mercadito facilita la publicación y descubrimiento de productos y la interacción comercial entre compradores y proveedores. Salvo que se indique expresamente lo contrario en una transacción concreta, los proveedores son responsables de sus productos, disponibilidad, descripciones, precios, permisos, entrega, calidad, garantías y obligaciones fiscales; los compradores son responsables de revisar condiciones y cumplir los acuerdos que acepten.',
      ),
      PolicyClause(
        title: '4. Elegibilidad y cuentas',
        content: 'El usuario debe proporcionar información correcta, mantener actualizados sus datos y proteger sus credenciales.\n\nLa edad mínima de uso es de 18 años. En caso de menores de edad, deben contar con autorización y supervisión expresa de sus padres o tutores legales. Los proveedores deberán tener capacidad legal para ofrecer los productos y las autorizaciones comerciales o sanitarias aplicables.',
      ),
      PolicyClause(
        title: '5. Reglas de publicación',
        content: 'Al publicar en El Mercadito, los usuarios se comprometen a cumplir con las siguientes normas:',
        points: [
          'No publicar información engañosa sobre origen, calidad, cantidad, precio, disponibilidad o certificaciones.',
          'No publicar productos ilícitos, prohibidos o cuya comercialización requiera autorizaciones que el proveedor no posea.',
          'No subir material que infrinja derechos de autor, marcas, privacidad, imagen o derechos de terceros.',
          'No realizar fraude, suplantación, manipulación de reseñas, acoso, spam ni intentos de eludir controles de seguridad.',
          'Mantener actualizados los precios, inventario, unidades de venta y condiciones comerciales.',
          'No publicar artículos sexuales, pornográficos u otro contenido erótico.',
        ],
      ),
      PolicyClause(
        title: '6. Negociaciones',
        content: 'La aceptación, precio final, cantidad, unidad, lugar de entrega, fecha, gastos, cancelaciones y devoluciones son responsabilidad del usuario quien publica, ejecuta o edita dicha información.\n\nEl usuario comprende y acepta que Mercadito no produce, provee, vende, expende ni es agente, distribuidor ni comercializador de los bienes exhibidos. El usuario es totalmente responsable de los acuerdos de negociación que concrete dentro o fuera de la plataforma.',
      ),
      PolicyClause(
        title: '7. Pagos y proveedores externos',
        content: 'Los pagos pueden procesarse mediante pasarelas externas seguras como Azul, CardNET o Stripe cuando estén habilitadas y el comercio haya sido aprobado.\n\nLa operación puede quedar sujeta a los términos, comisiones, validaciones, contracargos y reglas propias del proveedor de pagos correspondiente.',
      ),
      PolicyClause(
        title: '8. Contenido de usuario',
        content: 'El usuario conserva los derechos que posea sobre el contenido que publique. Concede a la Plataforma una licencia no exclusiva, mundial, gratuita y limitada a alojar, reproducir, adaptar técnicamente, mostrar y distribuir ese contenido para operar, promocionar y mejorar las funciones que el usuario elija.\n\nEl usuario declara que cuenta con los derechos o permisos suficientes para cargar dicho contenido.',
      ),
      PolicyClause(
        title: '9. Derechos de autor y propiedad intelectual',
        content: 'Queda prohibido copiar, modificar, reproducir, distribuir, comercializar o explotar contenidos, código, estructura o recursos de Mercadito sin autorización previa y expresa de Diaz Tecnologies.\n\nLas fotografías, descripciones y publicaciones aportadas por los usuarios corresponden a sus respectivos titulares. Para presentar reclamaciones por infracción de derechos de autor, envíe una notificación formal a contacto@diaztecnologies.es con asunto "Reclamación de derechos de autor", incluyendo:',
        points: [
          'Firma física o electrónica de la persona autorizada.',
          'Identificación de la obra protegida presuntamente infringida.',
          'Identificación precisa del contenido infractor y datos para localizarlo (URL, ID, perfil).',
          'Datos de contacto suficientes del reclamante (dirección, email, teléfono).',
          'Declaración de buena fe y veracidad bajo pena de perjurio.',
        ],
      ),
      PolicyClause(
        title: '10. Inteligencia artificial',
        content: 'Las funciones de IA integradas son herramientas auxiliares de asistencia. El usuario debe verificar los resultados antes de utilizarlos para fijar precios, describir productos, tomar decisiones comerciales o publicar afirmaciones.\n\nNo se garantiza exactitud absoluta de las respuestas de IA ni exclusividad de resultados. No deben enviarse secretos comerciales, credenciales ni datos sensibles no autorizados.',
      ),
      PolicyClause(
        title: '11. Moderación, suspensión y terminación',
        content: 'La Plataforma podrá retirar contenido, limitar funciones o suspender cuentas cuando existan indicios razonables de fraude, riesgo de seguridad, incumplimiento de estos términos, infracción de derechos o requerimiento legal.\n\nSiempre que sea legal y razonablemente viable, se notificará al usuario el motivo y se habilitará un canal de revisión y soporte.',
      ),
      PolicyClause(
        title: '12. Disponibilidad y garantías',
        content: 'La Plataforma puede experimentar interrupciones por mantenimiento, actualizaciones o incidencias técnicas de conectividad o de terceros. En la medida permitida por la ley, no se garantiza disponibilidad ininterrumpida ininterrumpida ni exactitud absoluta de contenidos de terceros.\n\nMercadito informará con antelación razonable sobre mantenimientos programados.',
      ),
      PolicyClause(
        title: '13. Limitación de responsabilidad',
        content: 'Cualquier límite de responsabilidad es claro y compatible con la legislación aplicable. No se excluye responsabilidad por fraude propio, dolo, culpa grave o daños personales que la ley prohíba excluir.',
      ),
      PolicyClause(
        title: '14. Condiciones y uso de cupones',
        content: 'Mercadito, operado por Diaz Tecnologies, permite emitir y canjear cupones y promociones comerciales para facilitar transacciones entre compradores y vendedores.',
        points: [
          'Cupones de vendedores: Descuentos otorgados por proveedores sobre sus propios productos.',
          'Cupones de la plataforma: Promociones emitidas directamente por Diaz Tecnologies.',
          'Cupones por porcentaje o importe fijo sobre compras elegibles.',
          'Cupones sujetos a condiciones: Importe mínimo, productos seleccionados o vigencia temporal.',
        ],
      ),
      PolicyClause(
        title: '15. Eliminación de cuentas',
        content: 'Los usuarios pueden solicitar el cierre y eliminación definitiva de su cuenta:',
        points: [
          'Desde la aplicación: Configuración > Privacidad > Eliminar cuenta.',
          'Por correo electrónico: Escribiendo a contacto@diaztecnologies.es con el asunto "Solicitud de eliminación de cuenta".',
          'Qué se elimina: Cuenta, perfil, datos de contacto, publicaciones, fotos, tokens de sesión y preferencias.',
          'Qué podría conservarse: Información estrictamente necesaria para obligaciones fiscales, prevención de fraude o requerimientos judiciales durante el plazo legal aplicable.',
        ],
      ),
    ],
  );

  static const LegalDocument politicaDePrivacidad = LegalDocument(
    title: 'Política de Privacidad',
    subtitle: 'Tratamiento de datos personales, seguridad y controles de privacidad',
    lastUpdated: '24 de mayo de 2024',
    icon: Icons.privacy_tip_outlined,
    clauses: [
      PolicyClause(
        title: '1. Categorías de datos',
        content: 'Tratamos las siguientes categorías de información según el uso de la aplicación:',
        points: [
          'Datos aportados: Nombre, identificador, correo electrónico, teléfono, datos de perfil, ubicación comercial y fotos.',
          'Datos del comprador: Historial de consultas, pedidos, negociaciones y preferencias comerciales.',
          'Datos del proveedor: Nombre comercial, catálogo, precios, inventario, cupones y condiciones de venta.',
          'Contenido y mensajes: Conversaciones, reportes, comentarios y documentos cargados.',
          'Datos técnicos: Información del dispositivo, sistema operativo, idioma, dirección IP, registros de auditoría y métricas de uso.',
        ],
      ),
      PolicyClause(
        title: '2. Finalidades y bases aplicables',
        content: 'Los datos personales se tratan para: crear y gestionar cuentas de usuario; mostrar catálogos y perfiles según los controles de privacidad seleccionados; facilitar el chat, negociaciones y pedidos; procesar pagos de forma segura; brindar soporte y ayuda; prevenir fraudes y mantener la seguridad de la comunidad; cumplir requerimientos legales.',
      ),
      PolicyClause(
        title: '3. Visibilidad y controles del perfil',
        content: 'La Plataforma pone a disposición controles de privacidad para que los usuarios gestionen qué datos son visibles públicamente. Ocultar un campo en el perfil asegura que terceros no puedan acceder a él, salvo los datos indispensables para concretar una transacción o requeridos por ley.',
      ),
      PolicyClause(
        title: '4. Proveedores y destinatarios',
        content: 'Para prestar los servicios, la plataforma colabora con proveedores tecnológicos bajo estrictos acuerdos de confidencialidad y seguridad:',
        points: [
          'Supabase: Almacenamiento seguro de base de datos, autenticación y archivos.',
          'Google / Firebase: Notificaciones push, diagnóstico analítico y servicios en la nube.',
          'Proveedores de pagos (Azul, CardNET, Stripe): Procesamiento cifrado de transacciones y prevención de fraude.',
          'Proveedores de IA (OpenAI, Google Gemini, Anthropic Claude): Procesamiento de instrucciones y asistencia auxiliar.',
          'Autoridades y asesores: Únicamente ante requerimiento judicial o deber legal vinculante.',
        ],
      ),
      PolicyClause(
        title: '5. Inteligencia artificial',
        content: 'El Mercadito utiliza herramientas de IA para apoyar en recomendaciones de productos, descripciones y resúmenes. Se aplican medidas de minimización enviando solo el contexto estrictamente necesario y evitando la transmisión de datos sensibles o financieros sin autorización.',
      ),
      PolicyClause(
        title: '6. Pagos',
        content: 'Las transacciones monetarias son procesadas a través de proveedores certificados PCI-DSS (como Azul, CardNET o Stripe). La Plataforma no almacena datos confidenciales de tarjetas de crédito o débito en sus servidores propios.',
      ),
      PolicyClause(
        title: '7. Conservación de datos',
        content: 'Los datos personales se conservarán mientras la cuenta esté activa o según sea necesario para prestar el servicio, resolver disputas, prevenir fraudes y cumplir con obligaciones contables o tributarias exigidas por ley.',
      ),
      PolicyClause(
        title: '8. Sitios web y enlaces de terceros',
        content: 'La aplicación o las publicaciones pueden contener enlaces a sitios externos. Diaz Tecnologies no se hace responsable por las políticas de privacidad o el tratamiento de datos efectuado por terceros.',
      ),
      PolicyClause(
        title: '9. Actualización de su información',
        content: 'El usuario es responsable de mantener actualizados sus datos en su perfil para garantizar el adecuado funcionamiento de las compras, entregas y notificaciones del servicio.',
      ),
      PolicyClause(
        title: '10. Verificación de identidad y negocios (Perfiles Verificados)',
        content: 'Para obtener la insignia de Verificado, los usuarios pueden suministrar documentación acreditativa bajo estrictas medidas de protección:',
        points: [
          'Documentos aceptados: Cédula de identidad oficial / Pasaporte, Registro Mercantil vigente y Comprobante de domicilio o finca.',
          'Uso exclusivo: Verificación de la identidad y autenticidad del negocio, prevención de fraudes y protección de los compradores.',
          'Almacenamiento seguro: Los documentos se custodian en repositorios aislados con cifrado y acceso restringido.',
          'Privacidad pública: La insignia no expone imágenes de documentos personales ni números de identificación en el perfil público.',
        ],
      ),
      PolicyClause(
        title: '11. Derechos del usuario y contacto legal',
        content: 'Usted puede ejercer en cualquier momento sus derechos de acceso, rectificación, supresión y oposición escribiendo a nuestro canal oficial de privacidad:\n\nCorreo electrónico: contacto@diaztecnologies.es',
      ),
    ],
  );
}


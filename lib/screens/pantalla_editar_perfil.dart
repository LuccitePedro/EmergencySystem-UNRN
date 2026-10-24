// ignore_for_file: slash_for_doc_comments
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/perfil_medico.dart';
import '../services/storage_service.dart';
import '../services/notificacion_service.dart';
import '../theme/colores.dart';

/**
 * Pantalla de formulario para crear o editar el perfil médico completo.
 * Se usa tanto en el primer uso de la app como para ediciones posteriores.
 * perfilActual: Perfil médico con los datos actuales a pre-cargar en el formulario.
 * esPrimerUso: Indica si es la primera vez que el usuario abre la app.
 *              Si es true, muestra un mensaje de bienvenida y marca el onboarding como completado al guardar.
 */
class PantallaEditarPerfil extends StatefulWidget {
  final PerfilMedico perfilActual;
  final bool esPrimerUso;

  const PantallaEditarPerfil({
    super.key,
    required this.perfilActual,
    this.esPrimerUso = false,
  });

  @override
  State<PantallaEditarPerfil> createState() => _PantallaEditarPerfilState();
}

class _PantallaEditarPerfilState extends State<PantallaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _obraSocialCtrl;
  late TextEditingController _numeroSocioCtrl;

  late List<Alergia> _alergias;
  late List<Enfermedad> _enfermedades;
  late List<Medicamento> _medicacion;
  late List<Vacuna> _vacunas;
  late List<String> _restricciones;
  late List<ContactoEmergencia> _contactos;

  String? _grupoSanguineo;

  static const _gruposSanguineos = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  static const _severidades = ['Leve', 'Moderada', 'Grave'];

  static const _maxContactos = 2;
  static const _vias = ['Oral', 'Inyectable', 'Inhalada', 'Sublingual', 'Tópica'];

  @override
  void initState() {
    super.initState();
    final p = widget.perfilActual;
    _nombreCtrl = TextEditingController(text: p.nombre);
    _obraSocialCtrl = TextEditingController(text: p.obraSocial);
    _numeroSocioCtrl = TextEditingController(text: p.numeroSocio);
    _grupoSanguineo = p.grupoSanguineo.isEmpty ? null : p.grupoSanguineo;
    _alergias = List.from(p.alergias);
    _enfermedades = List.from(p.enfermedades);
    _medicacion = List.from(p.medicacion);
    _vacunas = List.from(p.vacunas);
    _restricciones = List.from(p.restriccionesAlimentarias);
    _contactos = List.from(p.contactos);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _obraSocialCtrl.dispose();
    _numeroSocioCtrl.dispose();
    super.dispose();
  }

/**
 * Se encarga de guardar el perfil médico con los datos del formulario.
 * Valida que los campos obligatorios estén completos antes de guardar.
 * Persiste los datos en el dispositivo usando StorageService.
 * Return: Navega hacia atrás pasando el PerfilMedico actualizado como resultado.
 */
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final perfilNuevo = PerfilMedico(
      nombre: _nombreCtrl.text.trim(),
      grupoSanguineo: _grupoSanguineo ?? '',
      alergias: _alergias,
      enfermedades: _enfermedades,
      medicacion: _medicacion,
      vacunas: _vacunas,
      obraSocial: _obraSocialCtrl.text.trim(),
      numeroSocio: _numeroSocioCtrl.text.trim(),
      restriccionesAlimentarias: _restricciones,
      contactos: _contactos,
    );

    await StorageService.guardarPerfil(perfilNuevo);
    if (widget.esPrimerUso) await StorageService.marcarPrimerUsoCompletado();
    await NotificacionService.mostrarNotificacionPermanente(perfilNuevo);
    if (mounted) Navigator.pop(context, perfilNuevo);
  }

/**
 * Se encarga de mostrar un diálogo para agregar una nueva alergia.
 * Incluye campos para nombre, reacción, severidad y qué hacer en caso de reacción.
 * Return: Agrega la Alergia a la lista interna si el usuario confirmó.
 */
  Future<void> _agregarAlergia() async {
    final nombreCtrl = TextEditingController();
    final reaccionCtrl = TextEditingController();
    final queHacerCtrl = TextEditingController();
    String? severidad;

    final resultado = await showDialog<Alergia>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Agregar alergia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: Penicilina)'),
                _Campo(ctrl: reaccionCtrl, label: 'Reacción (ej: urticaria)'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<String>(
                    initialValue: severidad,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: _severidades
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => severidad = v),
                  ),
                ),
                _Campo(ctrl: queHacerCtrl, label: 'Qué hacer (ej: aplicar EpiPen)'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, Alergia(
                  nombre: nombreCtrl.text.trim(),
                  reaccion: reaccionCtrl.text.trim(),
                  severidad: severidad ?? 'Leve',
                  queHacer: queHacerCtrl.text.trim(),
                ));
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
    if (resultado != null) setState(() => _alergias.add(resultado));
  }

/**
 * Se encarga de mostrar un diálogo para agregar una nueva enfermedad.
 * Incluye campos para nombre, tratamiento actual y fecha de diagnóstico.
 * Return: Agrega la Enfermedad a la lista interna si el usuario confirmó.
 */  Future<void> _agregarEnfermedad() async {
    final nombreCtrl = TextEditingController();
    final tratamientoCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<Enfermedad>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar enfermedad'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: Diabetes tipo 2)'),
                _Campo(ctrl: tratamientoCtrl, label: 'Tratamiento actual'),
                _CampoFecha(ctrl: fechaCtrl, label: 'Fecha de diagnóstico'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty || !formKey.currentState!.validate()) return;
              Navigator.pop(ctx, Enfermedad(
                nombre: nombreCtrl.text.trim(),
                tratamiento: tratamientoCtrl.text.trim(),
                fechaDiagnostico: fechaCtrl.text.trim(),
              ));
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (resultado != null) setState(() => _enfermedades.add(resultado));
  }

/**
 * Se encarga de mostrar un diálogo para agregar un nuevo medicamento.
 * Incluye campos para nombre, dosis, marca, frecuencia, vía e indicación.
 * Return: Agrega el Medicamento a la lista interna si el usuario confirmó.
 */
  Future<void> _agregarMedicamento() async {
    final nombreCtrl = TextEditingController();
    final dosisCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final frecuenciaCtrl = TextEditingController();
    final indicacionCtrl = TextEditingController();
    String? via;

    final resultado = await showDialog<Medicamento>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Agregar medicamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: Metformina)'),
                _Campo(ctrl: dosisCtrl, label: 'Dosis (ej: 500mg)'),
                _Campo(ctrl: marcaCtrl, label: 'Marca (opcional)'),
                _Campo(ctrl: frecuenciaCtrl, label: 'Frecuencia (ej: mañana y noche)'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: DropdownButtonFormField<String>(
                    initialValue: via,
                    decoration: const InputDecoration(labelText: 'Vía de administración'),
                    items: _vias
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => via = v),
                  ),
                ),
                _Campo(ctrl: indicacionCtrl, label: 'Para qué es (ej: para la presión)'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, Medicamento(
                  nombre: nombreCtrl.text.trim(),
                  dosis: dosisCtrl.text.trim(),
                  marca: marcaCtrl.text.trim(),
                  frecuencia: frecuenciaCtrl.text.trim(),
                  via: via ?? '',
                  indicacion: indicacionCtrl.text.trim(),
                ));
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
    if (resultado != null) setState(() => _medicacion.add(resultado));
  }

/**
 * Se encarga de mostrar un diálogo para agregar una nueva vacuna.
 * Incluye campos para nombre, dosis, marca, fecha y localidad.
 * Return: Agrega la Vacuna a la lista interna si el usuario confirmó.
 */
  Future<void> _agregarVacuna() async {
    final nombreCtrl = TextEditingController();
    final dosisCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();
    final localidadCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<Vacuna>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar vacuna'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: COVID-19)'),
                _Campo(ctrl: dosisCtrl, label: 'Dosis (ej: Primera, Única)'),
                _Campo(ctrl: marcaCtrl, label: 'Marca (ej: Pfizer BioNTech)'),
                _CampoFecha(ctrl: fechaCtrl, label: 'Fecha de aplicación'),
                _Campo(ctrl: localidadCtrl, label: 'Localidad (ej: Hospital Bariloche)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty || !formKey.currentState!.validate()) return;
              Navigator.pop(ctx, Vacuna(
                nombre: nombreCtrl.text.trim(),
                dosis: dosisCtrl.text.trim(),
                marca: marcaCtrl.text.trim(),
                fecha: fechaCtrl.text.trim(),
                localidad: localidadCtrl.text.trim(),
              ));
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (resultado != null) setState(() => _vacunas.add(resultado));
  }

/**
 * Se encarga de mostrar un diálogo para agregar una restricción alimentaria.
 * Solo requiere el nombre de la restricción (ej: Sin gluten).
 * Return: Agrega la restricción a la lista interna si el usuario confirmó.
 */
  Future<void> _agregarRestriccion() async {
    final ctrl = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar restricción'),
        content: _Campo(ctrl: ctrl, label: 'Ej: Sin gluten'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, ctrl.text.trim());
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (resultado != null) setState(() => _restricciones.add(resultado));
  }

/**
 * Se encarga de mostrar un diálogo para agregar un contacto de emergencia.
 * Incluye campos para nombre, relación con el usuario y teléfono.
 * Return: Agrega el ContactoEmergencia a la lista interna si el usuario confirmó.
 */
  Future<void> _agregarContacto() async {
    final nombreCtrl = TextEditingController();
    final relacionCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    final resultado = await showDialog<ContactoEmergencia>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Campo(ctrl: nombreCtrl, label: 'Nombre y apellido'),
            _Campo(ctrl: relacionCtrl, label: 'Relación (ej: Madre)'),
            _Campo(ctrl: telCtrl, label: 'Teléfono', teclado: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty || telCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, ContactoEmergencia(
                nombre: nombreCtrl.text.trim(),
                relacion: relacionCtrl.text.trim(),
                telefono: telCtrl.text.trim(),
              ));
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (resultado != null) setState(() => _contactos.add(resultado));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esPrimerUso ? 'Completá tu perfil' : 'Editar perfil'),
        actions: [
          TextButton(
            onPressed: _guardar,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Guardar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.esPrimerUso) ...[
              const Text(
                '¡Bienvenido! Completá tus datos para que en una emergencia cualquiera pueda ayudarte.',
                style: TextStyle(fontSize: 15, color: Colores.textoSuave),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            _SeccionTitulo(titulo: 'Datos personales', icono: Icons.person_outline),
            _CampoTexto(controlador: _nombreCtrl, label: 'Nombre y apellido', icono: Icons.person_outline, obligatorio: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _grupoSanguineo,
              decoration: const InputDecoration(
                labelText: 'Grupo y factor sanguíneo',
                prefixIcon: Icon(Icons.bloodtype_outlined),
              ),
              hint: const Text('Seleccioná tu grupo'),
              items: _gruposSanguineos
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _grupoSanguineo = v),
            ),

            _SeccionTitulo(titulo: 'Obra Social', icono: Icons.badge_outlined),
            _CampoTexto(controlador: _obraSocialCtrl, label: 'Nombre (ej: OSDE 310)', icono: Icons.badge_outlined),
            const SizedBox(height: 12),
            _CampoTexto(controlador: _numeroSocioCtrl, label: 'Número de socio', icono: Icons.numbers),

            // ── Alergias ──
            _SeccionTitulo(titulo: 'Alergias', icono: Icons.warning_amber_rounded),
            ..._alergias.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: _unir([e.value.severidad, e.value.reaccion]),
              onEliminar: () => setState(() => _alergias.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar alergia', onTap: _agregarAlergia),

            // ── Enfermedades ──
            _SeccionTitulo(titulo: 'Enfermedades', icono: Icons.monitor_heart_outlined),
            ..._enfermedades.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: e.value.tratamiento.isEmpty ? 'Sin tratamiento registrado' : e.value.tratamiento,
              onEliminar: () => setState(() => _enfermedades.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar enfermedad', onTap: _agregarEnfermedad),

            // ── Medicación ──
            _SeccionTitulo(titulo: 'Medicación', icono: Icons.medication_outlined),
            ..._medicacion.asMap().entries.map((e) => _TarjetaItem(
              titulo: '${e.value.nombre} ${e.value.dosis}',
              subtitulo: e.value.frecuencia.isEmpty ? '' : e.value.frecuencia,
              onEliminar: () => setState(() => _medicacion.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar medicamento', onTap: _agregarMedicamento),

            // ── Vacunas ──
            _SeccionTitulo(titulo: 'Vacunas', icono: Icons.vaccines_outlined),
            ..._vacunas.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: _unir([e.value.dosis, e.value.fecha]),
              onEliminar: () => setState(() => _vacunas.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar vacuna', onTap: _agregarVacuna),

            // ── Restricciones ──
            _SeccionTitulo(titulo: 'Restricciones alimentarias', icono: Icons.no_food_outlined),
            ..._restricciones.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value,
              subtitulo: '',
              onEliminar: () => setState(() => _restricciones.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar restricción', onTap: _agregarRestriccion),

            // ── Contactos ──
            _SeccionTitulo(titulo: 'Contactos de emergencia', icono: Icons.contact_phone_outlined),
            ..._contactos.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: _unir([e.value.relacion, e.value.telefono]),
              onEliminar: () => setState(() => _contactos.removeAt(e.key)),
            )),
            // Máximo 2 contactos: son los que aparecen como botones de llamada en la pantalla principal
            if (_contactos.length < _maxContactos)
              _BotonAgregar(texto: 'Agregar contacto', onTap: _agregarContacto),

            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Guardar perfil'),
              style: FilledButton.styleFrom(
                backgroundColor: Colores.rojo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS INTERNOS
// ─────────────────────────────────────────────

// Une los datos con " · " salteando los vacíos (evita subtítulos como "Leve · ")
String _unir(List<String> partes) => partes.where((p) => p.isNotEmpty).join(' · ');

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  const _SeccionTitulo({required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Icon(icono, color: Colores.bordo, size: 22),
          const SizedBox(width: 8),
          Text(titulo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colores.bordo)),
        ],
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controlador;
  final String label;
  final IconData icono;
  final bool obligatorio;

  const _CampoTexto({
    required this.controlador,
    required this.label,
    required this.icono,
    this.obligatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
      ),
      validator: obligatorio
          ? (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null
          : null,
    );
  }
}

// Campo simple para usar dentro de los diálogos
class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType teclado;

  const _Campo({
    required this.ctrl,
    required this.label,
    this.teclado = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    // Margen arriba y abajo: la etiqueta flotante sube sobre el borde y necesita lugar
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: teclado,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

/// Campo de fecha para los diálogos: solo acepta números y arma solo el formato dd/mm/aaaa.
/// Es opcional, pero si se completa tiene que ser una fecha real y no futura.
class _CampoFecha extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;

  const _CampoFecha({required this.ctrl, required this.label});

  static String? _validar(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    final partes = texto.split('/');
    if (partes.length != 3 || partes[2].length != 4) return 'Completá la fecha: dd/mm/aaaa';
    final d = int.parse(partes[0]), m = int.parse(partes[1]), a = int.parse(partes[2]);
    final fecha = DateTime(a, m, d);
    // DateTime corrige fechas imposibles (ej: 31/02 pasa a marzo), así se detectan
    if (fecha.day != d || fecha.month != m || a < 1900) return 'Fecha inválida';
    if (fecha.isAfter(DateTime.now())) return 'La fecha no puede ser futura';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _FormatoFecha()],
        decoration: InputDecoration(
          labelText: label,
          hintText: 'dd/mm/aaaa',
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        validator: _validar,
      ),
    );
  }
}

/// Inserta las barras mientras se escribe: "20012021" se ve como "20/01/2021".
class _FormatoFecha extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue nuevo) {
    final digitos = nuevo.text.length > 8 ? nuevo.text.substring(0, 8) : nuevo.text;
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _TarjetaItem extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final VoidCallback onEliminar;

  const _TarjetaItem({
    required this.titulo,
    required this.subtitulo,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        title: Text(titulo,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: subtitulo.isEmpty
            ? null
            : Text(subtitulo,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white70),
          tooltip: 'Eliminar',
          onPressed: onEliminar,
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _BotonAgregar({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colores.bordo,
        side: const BorderSide(color: Colores.bordo),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
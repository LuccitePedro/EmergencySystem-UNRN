import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/storage_service.dart';

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
    if (mounted) Navigator.pop(context, perfilNuevo);
  }

  // ── Diálogo para agregar Alergia ──
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
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: severidad,
                  hint: const Text('Severidad'),
                  items: _severidades
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => severidad = v),
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

  // ── Diálogo para agregar Enfermedad ──
  Future<void> _agregarEnfermedad() async {
    final nombreCtrl = TextEditingController();
    final tratamientoCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();

    final resultado = await showDialog<Enfermedad>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar enfermedad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: Diabetes tipo 2)'),
              _Campo(ctrl: tratamientoCtrl, label: 'Tratamiento actual'),
              _Campo(ctrl: fechaCtrl, label: 'Fecha de diagnóstico (ej: 2019)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty) return;
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

  // ── Diálogo para agregar Medicamento ──
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
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: via,
                  hint: const Text('Vía de administración'),
                  items: _vias
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => via = v),
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

  // ── Diálogo para agregar Vacuna ──
  Future<void> _agregarVacuna() async {
    final nombreCtrl = TextEditingController();
    final dosisCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    final fechaCtrl = TextEditingController();
    final localidadCtrl = TextEditingController();

    final resultado = await showDialog<Vacuna>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar vacuna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: nombreCtrl, label: 'Nombre (ej: COVID-19)'),
              _Campo(ctrl: dosisCtrl, label: 'Dosis (ej: Primera, Única)'),
              _Campo(ctrl: marcaCtrl, label: 'Marca (ej: Pfizer BioNTech)'),
              _Campo(ctrl: fechaCtrl, label: 'Fecha (ej: 20/01/2021)'),
              _Campo(ctrl: localidadCtrl, label: 'Localidad (ej: Hospital Bariloche)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty) return;
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

  // ── Diálogo para agregar restricción alimentaria ──
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

  // ── Diálogo para agregar contacto ──
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
    const Color rojo = Color(0xFFF9183E);
    const Color rojoBorde = Color(0xFFA03333);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: rojo,
        title: Text(
          widget.esPrimerUso ? 'Completá tu perfil' : 'Editar perfil',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            _SeccionTitulo(titulo: 'Datos personales'),
            _CampoTexto(controlador: _nombreCtrl, label: 'Nombre y apellido', icono: Icons.person, obligatorio: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _grupoSanguineo,
              decoration: InputDecoration(
                labelText: 'Grupo y factor sanguíneo',
                prefixIcon: const Icon(Icons.bloodtype, color: rojoBorde),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: rojo, width: 2),
                ),
              ),
              hint: const Text('Seleccioná tu grupo'),
              items: _gruposSanguineos
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _grupoSanguineo = v),
            ),

            _SeccionTitulo(titulo: 'Obra Social'),
            _CampoTexto(controlador: _obraSocialCtrl, label: 'Nombre (ej: OSDE 310)', icono: Icons.card_membership),
            const SizedBox(height: 12),
            _CampoTexto(controlador: _numeroSocioCtrl, label: 'Número de socio', icono: Icons.numbers),

            // ── Alergias ──
            _SeccionTitulo(titulo: 'Alergias'),
            ..._alergias.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: '${e.value.severidad} · ${e.value.reaccion}',
              onEliminar: () => setState(() => _alergias.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar alergia', onTap: _agregarAlergia),

            // ── Enfermedades ──
            _SeccionTitulo(titulo: 'Enfermedades'),
            ..._enfermedades.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: e.value.tratamiento.isEmpty ? 'Sin tratamiento registrado' : e.value.tratamiento,
              onEliminar: () => setState(() => _enfermedades.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar enfermedad', onTap: _agregarEnfermedad),

            // ── Medicación ──
            _SeccionTitulo(titulo: 'Medicación'),
            ..._medicacion.asMap().entries.map((e) => _TarjetaItem(
              titulo: '${e.value.nombre} ${e.value.dosis}',
              subtitulo: e.value.frecuencia.isEmpty ? '' : e.value.frecuencia,
              onEliminar: () => setState(() => _medicacion.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar medicamento', onTap: _agregarMedicamento),

            // ── Vacunas ──
            _SeccionTitulo(titulo: 'Vacunas'),
            ..._vacunas.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: '${e.value.dosis} · ${e.value.fecha}',
              onEliminar: () => setState(() => _vacunas.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar vacuna', onTap: _agregarVacuna),

            // ── Restricciones ──
            _SeccionTitulo(titulo: 'Restricciones alimentarias'),
            ..._restricciones.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value,
              subtitulo: '',
              onEliminar: () => setState(() => _restricciones.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar restricción', onTap: _agregarRestriccion),

            // ── Contactos ──
            _SeccionTitulo(titulo: 'Contactos de emergencia'),
            ..._contactos.asMap().entries.map((e) => _TarjetaItem(
              titulo: e.value.nombre,
              subtitulo: '${e.value.relacion} · ${e.value.telefono}',
              onEliminar: () => setState(() => _contactos.removeAt(e.key)),
            )),
            _BotonAgregar(texto: 'Agregar contacto', onTap: _agregarContacto),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: rojo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar perfil',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA03333))),
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
        prefixIcon: Icon(icono, color: const Color(0xFFA03333)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF9183E), width: 2),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: teclado,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
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
      color: const Color(0xFFA03333),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(titulo,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: subtitulo.isEmpty
            ? null
            : Text(subtitulo,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white70),
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
      icon: const Icon(Icons.add, color: Color(0xFFA03333)),
      label: Text(texto, style: const TextStyle(color: Color(0xFFA03333))),
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFA03333))),
    );
  }
}
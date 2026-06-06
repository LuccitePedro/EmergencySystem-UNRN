import 'package:flutter/material.dart';
import '../models/perfil_medico.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

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

  // Controladores para campos de texto simples
  late TextEditingController _nombreCtrl;
  late TextEditingController _obraSocialCtrl;
  late TextEditingController _numeroSocioCtrl;

  // Listas editables
  late List<String> _alergias;
  late List<String> _enfermedades;
  late List<String> _medicacion;
  late List<String> _vacunas;
  late List<String> _restricciones;
  late List<ContactoEmergencia> _contactos;

  // Grupo sanguíneo con selector
  String? _grupoSanguineo;

  static const _gruposSanguineos = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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

  // Muestra un diálogo para agregar un ítem de texto a una lista
  Future<void> _agregarItem(List<String> lista, String titulo) async {
    final ctrl = TextEditingController();
    final resultado = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Agregar $titulo'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: titulo),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (resultado != null && resultado.isNotEmpty) {
      setState(() => lista.add(resultado));
    }
  }

  // Muestra un diálogo para agregar un contacto de emergencia
  Future<void> _agregarContacto() async {
    final nombreCtrl = TextEditingController();
    final relacionCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    final resultado = await showDialog<ContactoEmergencia>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar contacto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre y apellido'),
            ),
            TextField(
              controller: relacionCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Relación (ej: Madre, Amigo)'),
            ),
            TextField(
              controller: telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.trim().isEmpty || telCtrl.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                ContactoEmergencia(
                  nombre: nombreCtrl.text.trim(),
                  relacion: relacionCtrl.text.trim(),
                  telefono: telCtrl.text.trim(),
                ),
              );
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
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

            // ── Datos básicos ──
            _SeccionTitulo(titulo: 'Datos personales'),
            _CampoTexto(
              controlador: _nombreCtrl,
              label: 'Nombre y apellido',
              icono: Icons.person,
              obligatorio: true,
            ),
            const SizedBox(height: 12),
            _SelectorGrupoSanguineo(
              valorActual: _grupoSanguineo,
              grupos: _gruposSanguineos,
              onCambio: (v) => setState(() => _grupoSanguineo = v),
            ),

            // ── Obra Social ──
            _SeccionTitulo(titulo: 'Obra Social'),
            _CampoTexto(controlador: _obraSocialCtrl, label: 'Nombre (ej: OSDE 310)', icono: Icons.card_membership),
            const SizedBox(height: 12),
            _CampoTexto(controlador: _numeroSocioCtrl, label: 'Número de socio', icono: Icons.numbers),

            // ── Listas ──
            _SeccionLista(
              titulo: 'Alergias',
              icono: Icons.warning_amber,
              items: _alergias,
              onAgregar: () => _agregarItem(_alergias, 'alergia'),
              onEliminar: (i) => setState(() => _alergias.removeAt(i)),
            ),
            _SeccionLista(
              titulo: 'Enfermedades',
              icono: Icons.local_hospital,
              items: _enfermedades,
              onAgregar: () => _agregarItem(_enfermedades, 'enfermedad'),
              onEliminar: (i) => setState(() => _enfermedades.removeAt(i)),
            ),
            _SeccionLista(
              titulo: 'Medicación',
              icono: Icons.medication,
              items: _medicacion,
              onAgregar: () => _agregarItem(_medicacion, 'medicamento (ej: Ibuprofeno 400mg)'),
              onEliminar: (i) => setState(() => _medicacion.removeAt(i)),
            ),
            _SeccionLista(
              titulo: 'Vacunas',
              icono: Icons.vaccines,
              items: _vacunas,
              onAgregar: () => _agregarItem(_vacunas, 'vacuna (ej: COVID-19 2022)'),
              onEliminar: (i) => setState(() => _vacunas.removeAt(i)),
            ),
            _SeccionLista(
              titulo: 'Restricciones alimentarias',
              icono: Icons.no_meals,
              items: _restricciones,
              onAgregar: () => _agregarItem(_restricciones, 'restricción (ej: Sin gluten)'),
              onEliminar: (i) => setState(() => _restricciones.removeAt(i)),
            ),

            // ── Contactos de emergencia ──
            _SeccionTitulo(titulo: 'Contactos de emergencia'),
            ..._contactos.asMap().entries.map(
              (entry) => Card(
                color: const Color(0xFFA03333),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(entry.value.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${entry.value.relacion} · ${entry.value.telefono}', style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white70),
                    onPressed: () => setState(() => _contactos.removeAt(entry.key)),
                  ),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _agregarContacto,
              icon: const Icon(Icons.person_add, color: Color(0xFFA03333)),
              label: const Text('Agregar contacto', style: TextStyle(color: Color(0xFFA03333))),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFA03333))),
            ),

            const SizedBox(height: 30),

            // ── Botón guardar ──
            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: rojo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar perfil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGETS INTERNOS DEL FORMULARIO
// ─────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA03333)),
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

class _SelectorGrupoSanguineo extends StatelessWidget {
  final String? valorActual;
  final List<String> grupos;
  final ValueChanged<String?> onCambio;

  const _SelectorGrupoSanguineo({
    required this.valorActual,
    required this.grupos,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valorActual,
      decoration: InputDecoration(
        labelText: 'Grupo y factor sanguíneo',
        prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFFA03333)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF9183E), width: 2),
        ),
      ),
      hint: const Text('Seleccioná tu grupo'),
      items: grupos.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: onCambio,
    );
  }
}

class _SeccionLista extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<String> items;
  final VoidCallback onAgregar;
  final ValueChanged<int> onEliminar;

  const _SeccionLista({
    required this.titulo,
    required this.icono,
    required this.items,
    required this.onAgregar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SeccionTitulo(titulo: titulo),
        ...items.asMap().entries.map(
          (entry) => Card(
            color: const Color(0xFFA03333),
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(icono, color: Colors.white70, size: 20),
              title: Text(entry.value, style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white70),
                onPressed: () => onEliminar(entry.key),
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAgregar,
          icon: const Icon(Icons.add, color: Color(0xFFA03333)),
          label: Text('Agregar $titulo', style: const TextStyle(color: Color(0xFFA03333))),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFA03333))),
        ),
      ],
    );
  }
}
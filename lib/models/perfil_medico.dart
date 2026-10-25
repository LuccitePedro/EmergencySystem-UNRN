
// ─────────────────────────────────────────────
//  MODELOS DE DETALLE
// ─────────────────────────────────────────────

/// Vacuna aplicada: nombre, dosis, marca, fecha (dd/mm/aaaa) y lugar de aplicación.
class Vacuna {
  final String nombre;
  final String dosis;
  final String marca;
  final String fecha;
  final String localidad;

  const Vacuna({
    required this.nombre,
    required this.dosis,
    required this.marca,
    required this.fecha,
    required this.localidad,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'dosis': dosis,
        'marca': marca,
        'fecha': fecha,
        'localidad': localidad,
      };

  factory Vacuna.fromJson(Map<String, dynamic> json) => Vacuna(
        nombre: json['nombre'] ?? '',
        dosis: json['dosis'] ?? '',
        marca: json['marca'] ?? '',
        fecha: json['fecha'] ?? '',
        localidad: json['localidad'] ?? '',
      );
}

/// Medicamento que toma el usuario, con dosis, frecuencia, vía y para qué es.
class Medicamento {
  final String nombre;
  final String dosis;
  final String marca;
  final String frecuencia;
  final String via;         // oral, inyectable, inhalada, etc.
  final String indicacion;  // para qué es

  const Medicamento({
    required this.nombre,
    required this.dosis,
    required this.marca,
    required this.frecuencia,
    required this.via,
    required this.indicacion,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'dosis': dosis,
        'marca': marca,
        'frecuencia': frecuencia,
        'via': via,
        'indicacion': indicacion,
      };

  factory Medicamento.fromJson(Map<String, dynamic> json) => Medicamento(
        nombre: json['nombre'] ?? '',
        dosis: json['dosis'] ?? '',
        marca: json['marca'] ?? '',
        frecuencia: json['frecuencia'] ?? '',
        via: json['via'] ?? '',
        indicacion: json['indicacion'] ?? '',
      );
}

/// Enfermedad o condición crónica, con su tratamiento y fecha de diagnóstico.
class Enfermedad {
  final String nombre;
  final String tratamiento;
  final String fechaDiagnostico;

  const Enfermedad({
    required this.nombre,
    required this.tratamiento,
    required this.fechaDiagnostico,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'tratamiento': tratamiento,
        'fechaDiagnostico': fechaDiagnostico,
      };

  factory Enfermedad.fromJson(Map<String, dynamic> json) => Enfermedad(
        nombre: json['nombre'] ?? '',
        tratamiento: json['tratamiento'] ?? '',
        fechaDiagnostico: json['fechaDiagnostico'] ?? '',
      );
}

/// Alergia con su reacción, severidad (Leve, Moderada o Grave) y qué hacer ante una reacción.
class Alergia {
  final String nombre;
  final String reaccion;
  final String severidad;     // Leve, Moderada, Grave
  final String queHacer;      // ej: aplicar EpiPen

  const Alergia({
    required this.nombre,
    required this.reaccion,
    required this.severidad,
    required this.queHacer,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'reaccion': reaccion,
        'severidad': severidad,
        'queHacer': queHacer,
      };

  factory Alergia.fromJson(Map<String, dynamic> json) => Alergia(
        nombre: json['nombre'] ?? '',
        reaccion: json['reaccion'] ?? '',
        severidad: json['severidad'] ?? '',
        queHacer: json['queHacer'] ?? '',
      );
}

/// Persona a la que llamar en una emergencia.
class ContactoEmergencia {
  final String nombre;
  final String relacion;
  final String telefono;

  const ContactoEmergencia({
    required this.nombre,
    required this.relacion,
    required this.telefono,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'relacion': relacion,
        'telefono': telefono,
      };

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) =>
      ContactoEmergencia(
        nombre: json['nombre'] ?? '',
        relacion: json['relacion'] ?? '',
        telefono: json['telefono'] ?? '',
      );
}

// ─────────────────────────────────────────────
//  PERFIL MÉDICO PRINCIPAL
// ─────────────────────────────────────────────

/// Perfil médico completo del usuario. Es inmutable: para cambiar un dato se crea una copia con [copyWith].
/// Se guarda como JSON (ver [toJson] y [PerfilMedico.fromJson]).
class PerfilMedico {
  final String nombre;
  final String grupoSanguineo;
  final List<Alergia> alergias;
  final List<Enfermedad> enfermedades;
  final List<Medicamento> medicacion;
  final List<Vacuna> vacunas;
  final String obraSocial;
  final String numeroSocio;
  final List<String> restriccionesAlimentarias;
  final List<ContactoEmergencia> contactos;

  const PerfilMedico({
    required this.nombre,
    required this.grupoSanguineo,
    required this.alergias,
    required this.enfermedades,
    required this.medicacion,
    required this.vacunas,
    required this.obraSocial,
    required this.numeroSocio,
    required this.restriccionesAlimentarias,
    required this.contactos,
  });

  /// Perfil sin datos, usado en el primer uso o si no se pudo leer el guardado.
  static const PerfilMedico vacio = PerfilMedico(
    nombre: '',
    grupoSanguineo: '',
    alergias: [],
    enfermedades: [],
    medicacion: [],
    vacunas: [],
    obraSocial: '',
    numeroSocio: '',
    restriccionesAlimentarias: [],
    contactos: [],
  );

  /// Indica si todavía no se cargó el perfil (el nombre es el único dato obligatorio).
  bool get estaVacio => nombre.isEmpty;

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'grupoSanguineo': grupoSanguineo,
        'alergias': alergias.map((a) => a.toJson()).toList(),
        'enfermedades': enfermedades.map((e) => e.toJson()).toList(),
        'medicacion': medicacion.map((m) => m.toJson()).toList(),
        'vacunas': vacunas.map((v) => v.toJson()).toList(),
        'obraSocial': obraSocial,
        'numeroSocio': numeroSocio,
        'restriccionesAlimentarias': restriccionesAlimentarias,
        'contactos': contactos.map((c) => c.toJson()).toList(),
      };

  /// Reconstruye el perfil desde JSON. Los campos que falten quedan vacíos, así un perfil
  /// guardado con una versión anterior de la app se sigue pudiendo leer.
  factory PerfilMedico.fromJson(Map<String, dynamic> json) => PerfilMedico(
        nombre: json['nombre'] ?? '',
        grupoSanguineo: json['grupoSanguineo'] ?? '',
        alergias: (json['alergias'] as List<dynamic>? ?? [])
            .map((a) => Alergia.fromJson(a as Map<String, dynamic>))
            .toList(),
        enfermedades: (json['enfermedades'] as List<dynamic>? ?? [])
            .map((e) => Enfermedad.fromJson(e as Map<String, dynamic>))
            .toList(),
        medicacion: (json['medicacion'] as List<dynamic>? ?? [])
            .map((m) => Medicamento.fromJson(m as Map<String, dynamic>))
            .toList(),
        vacunas: (json['vacunas'] as List<dynamic>? ?? [])
            .map((v) => Vacuna.fromJson(v as Map<String, dynamic>))
            .toList(),
        obraSocial: json['obraSocial'] ?? '',
        numeroSocio: json['numeroSocio'] ?? '',
        restriccionesAlimentarias:
            List<String>.from(json['restriccionesAlimentarias'] ?? []),
        contactos: (json['contactos'] as List<dynamic>? ?? [])
            .map((c) => ContactoEmergencia.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  /// Devuelve una copia del perfil cambiando solo los campos indicados.
  PerfilMedico copyWith({
    String? nombre,
    String? grupoSanguineo,
    List<Alergia>? alergias,
    List<Enfermedad>? enfermedades,
    List<Medicamento>? medicacion,
    List<Vacuna>? vacunas,
    String? obraSocial,
    String? numeroSocio,
    List<String>? restriccionesAlimentarias,
    List<ContactoEmergencia>? contactos,
  }) {
    return PerfilMedico(
      nombre: nombre ?? this.nombre,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      alergias: alergias ?? this.alergias,
      enfermedades: enfermedades ?? this.enfermedades,
      medicacion: medicacion ?? this.medicacion,
      vacunas: vacunas ?? this.vacunas,
      obraSocial: obraSocial ?? this.obraSocial,
      numeroSocio: numeroSocio ?? this.numeroSocio,
      restriccionesAlimentarias:
          restriccionesAlimentarias ?? this.restriccionesAlimentarias,
      contactos: contactos ?? this.contactos,
    );
  }
}
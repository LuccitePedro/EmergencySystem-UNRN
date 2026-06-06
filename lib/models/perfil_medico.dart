
class PerfilMedico {
  final String nombre;
  final String grupoSanguineo;
  final List<String> alergias;
  final List<String> enfermedades;
  final List<String> medicacion;
  final List<String> vacunas;
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

  static const PerfilMedico ejemplo = PerfilMedico(
    nombre: 'Persona Equis',
    grupoSanguineo: 'A+',
    alergias: ['Penicilina', 'Ibuprofeno'],
    enfermedades: ['Diabetes tipo 2', 'Hipertensión'],
    medicacion: ['Metformina 500mg (mañana)', 'Enalapril 10mg (noche)'],
    vacunas: ['COVID-19 (2022)', 'Gripe (2024)', 'Tétanos (2021)'],
    obraSocial: 'OSDE 310',
    numeroSocio: '1234567-8',
    restriccionesAlimentarias: ['Sin gluten', 'Sin lactosa'],
    contactos: [
      ContactoEmergencia(nombre: 'María García', relacion: 'Madre', telefono: '2944123456'),
      ContactoEmergencia(nombre: 'Carlos Equis', relacion: 'Padre', telefono: '2944654321'),
    ],
  );

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'grupoSanguineo': grupoSanguineo,
      'alergias': alergias,
      'enfermedades': enfermedades,
      'medicacion': medicacion,
      'vacunas': vacunas,
      'obraSocial': obraSocial,
      'numeroSocio': numeroSocio,
      'restriccionesAlimentarias': restriccionesAlimentarias,
      'contactos': contactos.map((c) => c.toJson()).toList(),
    };
  }

  factory PerfilMedico.fromJson(Map<String, dynamic> json) {
    return PerfilMedico(
      nombre: json['nombre'] ?? '',
      grupoSanguineo: json['grupoSanguineo'] ?? '',
      alergias: List<String>.from(json['alergias'] ?? []),
      enfermedades: List<String>.from(json['enfermedades'] ?? []),
      medicacion: List<String>.from(json['medicacion'] ?? []),
      vacunas: List<String>.from(json['vacunas'] ?? []),
      obraSocial: json['obraSocial'] ?? '',
      numeroSocio: json['numeroSocio'] ?? '',
      restriccionesAlimentarias: List<String>.from(json['restriccionesAlimentarias'] ?? []),
      contactos: (json['contactos'] as List<dynamic>? ?? [])
          .map((c) => ContactoEmergencia.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  PerfilMedico copyWith({
    String? nombre,
    String? grupoSanguineo,
    List<String>? alergias,
    List<String>? enfermedades,
    List<String>? medicacion,
    List<String>? vacunas,
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
      restriccionesAlimentarias: restriccionesAlimentarias ?? this.restriccionesAlimentarias,
      contactos: contactos ?? this.contactos,
    );
  }

  bool get estaVacio => nombre.isEmpty;
}

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

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) {
    return ContactoEmergencia(
      nombre: json['nombre'] ?? '',
      relacion: json['relacion'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }
}
class UserEntity {
  final String uid;
  final String nombre;
  final String email;
  final String? fotoUrl;
  final double peso;
  final double altura;
  final DateTime fechaRegistro;
  final int totalEntrenamientos;
  final double totalDistancia;
  final int totalPasos;

  const UserEntity({
    required this.uid,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    required this.peso,
    required this.altura,
    required this.fechaRegistro,
    this.totalEntrenamientos = 0,
    this.totalDistancia = 0.0,
    this.totalPasos = 0,
  });

  UserEntity copyWith({
    String? uid,
    String? nombre,
    String? email,
    String? fotoUrl,
    double? peso,
    double? altura,
    DateTime? fechaRegistro,
    int? totalEntrenamientos,
    double? totalDistancia,
    int? totalPasos,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      totalEntrenamientos: totalEntrenamientos ?? this.totalEntrenamientos,
      totalDistancia: totalDistancia ?? this.totalDistancia,
      totalPasos: totalPasos ?? this.totalPasos,
    );
  }
}

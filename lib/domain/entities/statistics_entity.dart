class PeriodStats {
  final double distanciaTotal;
  final int pasosTotal;
  final int tiempoTotal; // seconds
  final int entrenamientos;

  const PeriodStats({
    this.distanciaTotal = 0.0,
    this.pasosTotal = 0,
    this.tiempoTotal = 0,
    this.entrenamientos = 0,
  });
}

class StatisticsEntity {
  final String usuarioId;
  final PeriodStats semanaActual;
  final PeriodStats mesActual;
  final double mejorDistancia;
  final int mejorTiempo;
  final int rachaDias;

  const StatisticsEntity({
    required this.usuarioId,
    this.semanaActual = const PeriodStats(),
    this.mesActual = const PeriodStats(),
    this.mejorDistancia = 0.0,
    this.mejorTiempo = 0,
    this.rachaDias = 0,
  });
}

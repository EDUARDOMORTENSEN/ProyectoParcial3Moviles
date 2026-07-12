import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/statistics_viewmodel.dart';
import '../../widgets/common/stat_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.uid;
      if (userId != null) {
        context.read<StatisticsViewModel>().loadStatistics(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estadísticas',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Consumer<StatisticsViewModel>(
                  builder: (context, statsVM, _) {
                    if (statsVM.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    }

                    final stats = statsVM.statistics;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weekly summary
                        Text(
                          'Esta Semana',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.route_rounded,
                                label: 'Distancia',
                                value:
                                    (stats?.semanaActual.distanciaTotal ?? 0).toStringAsFixed(1),
                                suffix: 'km',
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.directions_walk,
                                label: 'Pasos',
                                value:
                                    '${stats?.semanaActual.pasosTotal ?? 0}',
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.timer,
                                label: 'Tiempo',
                                value: _formatTime(
                                    stats?.semanaActual.tiempoTotal ?? 0),
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.fitness_center,
                                label: 'Entrenamientos',
                                value:
                                    '${stats?.semanaActual.entrenamientos ?? 0}',
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Weekly chart
                        Text(
                          'Actividad Semanal',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 10,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => AppColors.surface,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const days = [
                                        'Lun',
                                        'Mar',
                                        'Mié',
                                        'Jue',
                                        'Vie',
                                        'Sáb',
                                        'Dom'
                                      ];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: Text(
                                          days[value.toInt()],
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              barGroups: List.generate(7, (index) {
                                // Simulated data based on current day
                                final today = DateTime.now().weekday - 1;
                                final hasData = index <= today;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: hasData
                                          ? (3 + index * 0.5)
                                              .clamp(0, 10)
                                              .toDouble()
                                          : 0,
                                      color: index == today
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(alpha: 0.3),
                                      width: 20,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Personal records
                        Text(
                          'Récords Personales',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildRecordCard(
                          context,
                          Icons.emoji_events,
                          'Mejor Distancia',
                          '${(stats?.mejorDistancia ?? 0).toStringAsFixed(2)} km',
                          AppColors.warning,
                        ),
                        const SizedBox(height: 12),
                        _buildRecordCard(
                          context,
                          Icons.local_fire_department,
                          'Racha de Días',
                          '${stats?.rachaDias ?? 0} días',
                          AppColors.error,
                        ),
                        const SizedBox(height: 32),

                        // Monthly overview
                        Text(
                          'Este Mes',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            children: [
                              _buildMonthRow(
                                context,
                                'Distancia Total',
                                '${(stats?.mesActual.distanciaTotal ?? 0).toStringAsFixed(1)} km',
                                Icons.route,
                              ),
                              Divider(color: AppColors.glassBorder),
                              _buildMonthRow(
                                context,
                                'Pasos Totales',
                                '${stats?.mesActual.pasosTotal ?? 0}',
                                Icons.directions_walk,
                              ),
                              Divider(color: AppColors.glassBorder),
                              _buildMonthRow(
                                context,
                                'Tiempo Total',
                                _formatTime(
                                    stats?.mesActual.tiempoTotal ?? 0),
                                Icons.timer,
                              ),
                              Divider(color: AppColors.glassBorder),
                              _buildMonthRow(
                                context,
                                'Entrenamientos',
                                '${stats?.mesActual.entrenamientos ?? 0}',
                                Icons.fitness_center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

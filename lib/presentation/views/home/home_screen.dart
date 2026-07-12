import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/training_viewmodel.dart';
import '../../viewmodels/statistics_viewmodel.dart';
import '../../viewmodels/ranking_viewmodel.dart';
import '../../widgets/common/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.uid;
    if (userId != null) {
      context.read<TrainingViewModel>().loadHistory(userId);
      context.read<StatisticsViewModel>().loadStatistics(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboard(),
              _buildTrainingPlaceholder(),
              _buildHistoryPlaceholder(),
              _buildRankingPlaceholder(),
              _buildProfilePlaceholder(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.pushNamed(context, AppRoutes.training);
              return;
            }
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill_rounded),
              label: AppStrings.training,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: AppStrings.history,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: AppStrings.ranking,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              return Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        (authVM.currentUser?.nombre ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${authVM.currentUser?.nombre ?? 'Usuario'}!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '¿Listo para entrenar?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to statistics
                      Navigator.pushNamed(context, AppRoutes.statistics);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Start training button
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.training),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.startTraining,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GPS • Pasos • Distancia',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Today's stats
          Text(
            'Resumen de Hoy',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Consumer<StatisticsViewModel>(
            builder: (context, statsVM, _) {
              final stats = statsVM.statistics;
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.directions_walk_rounded,
                      label: AppStrings.steps,
                      value: '${stats?.semanaActual.pasosTotal ?? 0}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.route_rounded,
                      label: AppStrings.distance,
                      value:
                          '${(stats?.semanaActual.distanciaTotal ?? 0).toStringAsFixed(1)} km',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Consumer<StatisticsViewModel>(
            builder: (context, statsVM, _) {
              final stats = statsVM.statistics;
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department_rounded,
                      label: AppStrings.calories,
                      value: '${stats?.semanaActual.tiempoTotal ?? 0}',
                      suffix: AppStrings.kcal,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Entrenamientos',
                      value:
                          '${stats?.semanaActual.entrenamientos ?? 0}',
                      color: AppColors.info,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent trainings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entrenamientos Recientes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _currentIndex = 2), // Go to history tab
                child: const Text('Ver todos',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<TrainingViewModel>(
            builder: (context, trainingVM, _) {
              if (trainingVM.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (trainingVM.history.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.directions_run,
                          size: 48,
                          color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.noTrainings,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: trainingVM.history.take(3).map((training) {
                  return _buildTrainingCard(training);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(dynamic training) {
    IconData icon;
    Color color;
    switch (training.tipo) {
      case 'correr':
        icon = Icons.directions_run;
        color = AppColors.primary;
        break;
      case 'caminar':
        icon = Icons.directions_walk;
        color = AppColors.accent;
        break;
      case 'ciclismo':
        icon = Icons.directions_bike;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.fitness_center;
        color = AppColors.info;
    }

    final duration = Duration(seconds: training.duracionSegundos);
    final durationStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  training.tipo[0].toUpperCase() + training.tipo.substring(1),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${training.distanciaKm.toStringAsFixed(2)} km • $durationStr',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${training.pasos}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'pasos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder builders for tabs that navigate to dedicated screens
  Widget _buildTrainingPlaceholder() => const SizedBox(); // Handled by navigation

  Widget _buildHistoryPlaceholder() {
    return _HistoryTab(
      onTrainingTap: (training) {
        Navigator.pushNamed(context, AppRoutes.trainingDetail, arguments: training);
      },
    );
  }

  Widget _buildRankingPlaceholder() {
    return const _RankingTab();
  }

  Widget _buildProfilePlaceholder() {
    return _ProfileTab(
      onLogout: () async {
        await context.read<AuthViewModel>().logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
    );
  }
}

// ─── History Tab ───
class _HistoryTab extends StatelessWidget {
  final Function(dynamic) onTrainingTap;
  const _HistoryTab({required this.onTrainingTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingViewModel>(
      builder: (context, trainingVM, _) {
        if (trainingVM.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (trainingVM.history.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noTrainings,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: trainingVM.history.length,
          itemBuilder: (context, index) {
            final training = trainingVM.history[index];
            return _buildHistoryItem(context, training);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic training) {
    IconData icon;
    Color color;
    switch (training.tipo) {
      case 'correr':
        icon = Icons.directions_run;
        color = AppColors.primary;
        break;
      case 'caminar':
        icon = Icons.directions_walk;
        color = AppColors.accent;
        break;
      case 'ciclismo':
        icon = Icons.directions_bike;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.fitness_center;
        color = AppColors.info;
    }

    final duration = Duration(seconds: training.duracionSegundos);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final durationStr = hours > 0
        ? '${hours}h ${minutes}m'
        : '$minutes:${seconds.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => onTrainingTap(training),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.tipo[0].toUpperCase() + training.tipo.substring(1),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.route, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${training.distanciaKm.toStringAsFixed(2)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        durationStr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.directions_walk,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${training.pasos}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Ranking Tab ───
class _RankingTab extends StatelessWidget {
  const _RankingTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.globalRanking,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer2<RankingViewModel, AuthViewModel>(
              builder: (context, rankingVM, authVM, _) {
                if (rankingVM.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (rankingVM.rankings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.leaderboard,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          'No hay datos de ranking',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: rankingVM.rankings.length,
                  itemBuilder: (context, index) {
                    final ranking = rankingVM.rankings[index];
                    final isCurrentUser =
                        ranking.usuarioId == authVM.currentUser?.uid;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentUser
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Position
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: index < 3
                                  ? [
                                      AppColors.warning,
                                      AppColors.textSecondary,
                                      const Color(0xFFCD7F32),
                                    ][index]
                                      .withValues(alpha: 0.2)
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index < 3
                                      ? [
                                          AppColors.warning,
                                          AppColors.textSecondary,
                                          const Color(0xFFCD7F32),
                                        ][index]
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              ranking.nombre.isNotEmpty
                                  ? ranking.nombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ranking.nombre,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isCurrentUser
                                            ? AppColors.primary
                                            : null,
                                      ),
                                ),
                                Text(
                                  '${ranking.distanciaTotalKm.toStringAsFixed(1)} km',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${ranking.pasosTotal}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'pasos',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Tab ───
class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (user?.nombre ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.nombre ?? 'Usuario',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Stats row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat(
                      context,
                      '${user?.totalEntrenamientos ?? 0}',
                      'Entrenam.',
                      AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.glassBorder,
                    ),
                    _buildProfileStat(
                      context,
                      (user?.totalDistancia ?? 0).toStringAsFixed(1),
                      'km Total',
                      AppColors.accent,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.glassBorder,
                    ),
                    _buildProfileStat(
                      context,
                      '${user?.totalPasos ?? 0}',
                      'Pasos',
                      AppColors.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info cards
              _buildInfoRow(context, 'Peso', '${user?.peso ?? 0} kg',
                  Icons.monitor_weight_outlined),
              const SizedBox(height: 8),
              _buildInfoRow(context, 'Altura', '${user?.altura ?? 0} cm',
                  Icons.height),
              const SizedBox(height: 32),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    AppStrings.logout,
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(
      BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

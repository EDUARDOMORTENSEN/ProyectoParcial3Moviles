import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/training_viewmodel.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<Position>? _positionSub;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Recenter the map on each GPS fix so the trail stays on-screen.
    final vm = context.read<TrainingViewModel>();
    _positionSub = vm.positionStream.listen((position) {
      if (_mapReady) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          _mapController.camera.zoom,
        );
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Consumer<TrainingViewModel>(
            builder: (context, trainingVM, _) {
              if (trainingVM.state == TrainingState.idle) {
                return _buildStartView(trainingVM);
              }
              return _buildActiveView(trainingVM);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStartView(TrainingViewModel trainingVM) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios,
                    color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                'Nuevo Entrenamiento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 40),

          // Training type selector
          Text(
            'Tipo de Actividad',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTypeOption(
                trainingVM,
                'correr',
                Icons.directions_run,
                AppStrings.running,
                AppColors.primary,
              ),
              _buildTypeOption(
                trainingVM,
                'caminar',
                Icons.directions_walk,
                AppStrings.walking,
                AppColors.accent,
              ),
              _buildTypeOption(
                trainingVM,
                'ciclismo',
                Icons.directions_bike,
                AppStrings.cycling,
                AppColors.warning,
              ),
            ],
          ),
          const Spacer(),

          // Weather info
          if (trainingVM.weatherData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${trainingVM.weatherData!.temperature.toStringAsFixed(0)}°C • ${trainingVM.weatherData!.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Start button
          ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: () => trainingVM.startTraining(
              weightKg: context.read<AuthViewModel>().currentUser?.peso,
            ),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 48, color: Colors.white),
                    Text(
                      'INICIAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTypeOption(TrainingViewModel vm, String type, IconData icon,
      String label, Color color) {
    final isSelected = vm.trainingType == type;
    return GestureDetector(
      onTap: () => vm.setTrainingType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? color : AppColors.textHint),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView(TrainingViewModel trainingVM) {
    final routePoints = trainingVM.routePoints;
    final polylinePoints =
        routePoints.map((p) => LatLng(p.latitud, p.longitud)).toList();

    return Column(
      children: [
        // Header with back
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _showDiscardDialog(trainingVM);
                },
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
              const Spacer(),
              // Training type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trainingVM.trainingType.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              // Pause/Resume
              if (trainingVM.state == TrainingState.active)
                IconButton(
                  onPressed: () => trainingVM.pauseTraining(),
                  icon: const Icon(Icons.pause_circle_filled,
                      color: AppColors.warning, size: 32),
                )
              else if (trainingVM.state == TrainingState.paused)
                IconButton(
                  onPressed: () => trainingVM.resumeTraining(),
                  icon: const Icon(Icons.play_circle_filled,
                      color: AppColors.accent, size: 32),
                ),
            ],
          ),
        ),

        // Map
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: trainingVM.currentPosition != null
                    ? LatLng(trainingVM.currentPosition!.latitude,
                        trainingVM.currentPosition!.longitude)
                    : const LatLng(-0.1807, -78.4678), // Quito default
                initialZoom: 16,
                onMapReady: () => _mapReady = true,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'ec.edu.espe.mortenzen_martes',
                ),
                if (polylinePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Stats panel
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                // Timer
                Text(
                  trainingVM.formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: trainingVM.state == TrainingState.paused
                            ? AppColors.warning
                            : AppColors.textPrimary,
                        fontSize: 48,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLiveStat(
                      Icons.route_rounded,
                      trainingVM.distanceKm.toStringAsFixed(2),
                      AppStrings.km,
                      AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.glassBorder,
                    ),
                    _buildLiveStat(
                      Icons.directions_walk,
                      '${trainingVM.steps}',
                      AppStrings.steps,
                      AppColors.accent,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.glassBorder,
                    ),
                    _buildLiveStat(
                      Icons.speed,
                      trainingVM.currentSpeed.toStringAsFixed(1),
                      AppStrings.kmh,
                      AppColors.warning,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.glassBorder,
                    ),
                    _buildLiveStat(
                      Icons.local_fire_department,
                      trainingVM.calories.toStringAsFixed(0),
                      AppStrings.kcal,
                      AppColors.error,
                    ),
                  ],
                ),
                const Spacer(),
                // Stop button
                if (trainingVM.state != TrainingState.finished)
                  GestureDetector(
                    onTap: () => _stopTraining(trainingVM),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.stop_rounded,
                          size: 32, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Future<void> _stopTraining(TrainingViewModel trainingVM) async {
    final userId = context.read<AuthViewModel>().currentUser?.uid;
    if (userId == null) return;

    final training = await trainingVM.stopTraining(userId);
    if (training != null && mounted) {
      _showSaveDialog(trainingVM, training);
    }
  }

  void _showSaveDialog(TrainingViewModel trainingVM, dynamic training) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Entrenamiento Completado',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              '${training.distanciaKm.toStringAsFixed(2)} km en ${trainingVM.formattedTime}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              trainingVM.discardTraining();
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text(AppStrings.discardTraining,
                style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId =
                  context.read<AuthViewModel>().currentUser?.uid ?? '';
              await trainingVM.saveTrainingData(training, userId);
              if (dialogContext.mounted && mounted) {
                Navigator.pop(dialogContext); // close dialog
                Navigator.pop(context); // back to home
              }
            },
            child: const Text(AppStrings.saveTraining),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog(TrainingViewModel trainingVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Descartar entrenamiento?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Se perderán todos los datos del entrenamiento actual.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              trainingVM.discardTraining();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text(AppStrings.discardTraining,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // Using CartoDB Dark tile server for dark theme map style
}

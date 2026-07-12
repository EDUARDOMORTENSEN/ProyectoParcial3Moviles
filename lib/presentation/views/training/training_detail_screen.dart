import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/training_entity.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../di/injection_container.dart';

class TrainingDetailScreen extends StatefulWidget {
  final TrainingEntity training;

  const TrainingDetailScreen({super.key, required this.training});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  RouteEntity? _route;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await di.routeRepository.getRouteByTrainingId(widget.training.id);
      setState(() {
        _route = route;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final training = widget.training;
    final duration = Duration(seconds: training.duracionSegundos);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final durationStr = hours > 0
        ? '${hours}h ${minutes}m ${seconds}s'
        : '$minutes:${seconds.toString().padLeft(2, '0')}';

    IconData typeIcon;
    Color typeColor;
    switch (training.tipo) {
      case 'correr':
        typeIcon = Icons.directions_run;
        typeColor = AppColors.primary;
        break;
      case 'caminar':
        typeIcon = Icons.directions_walk;
        typeColor = AppColors.accent;
        break;
      case 'ciclismo':
        typeIcon = Icons.directions_bike;
        typeColor = AppColors.warning;
        break;
      default:
        typeIcon = Icons.fitness_center;
        typeColor = AppColors.info;
    }

    final polylinePoints = _route?.puntos
            .map((p) => LatLng(p.latitud, p.longitud))
            .toList() ??
        [];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Icon(typeIcon, color: typeColor, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      training.tipo[0].toUpperCase() +
                          training.tipo.substring(1),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),

              // Map
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: polylinePoints.isNotEmpty
                                ? polylinePoints.first
                                : const LatLng(-0.1807, -78.4678),
                            zoom: 15,
                          ),
                          polylines: {
                            if (polylinePoints.length >= 2)
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: polylinePoints,
                                color: typeColor,
                                width: 4,
                              ),
                          },
                          markers: {
                            if (polylinePoints.isNotEmpty)
                              Marker(
                                markerId: const MarkerId('start'),
                                position: polylinePoints.first,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen),
                              ),
                            if (polylinePoints.length > 1)
                              Marker(
                                markerId: const MarkerId('end'),
                                position: polylinePoints.last,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed),
                              ),
                          },
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats grid
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              Icons.route_rounded,
                              'Distancia',
                              '${training.distanciaKm.toStringAsFixed(2)} km',
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              Icons.timer_rounded,
                              'Duración',
                              durationStr,
                              AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              Icons.directions_walk,
                              'Pasos',
                              '${training.pasos}',
                              AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              Icons.local_fire_department,
                              'Calorías',
                              '${training.calorias.toStringAsFixed(0)} kcal',
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              Icons.speed,
                              'Vel. Promedio',
                              '${training.velocidadPromedio.toStringAsFixed(1)} km/h',
                              AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailCard(
                              Icons.flash_on,
                              'Vel. Máxima',
                              '${training.velocidadMaxima.toStringAsFixed(1)} km/h',
                              AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorites_controller.dart';
import '../models/tv_show.dart';
import '../services/notification_service.dart';
import '../services/tvmaze_service.dart';

class ShowDetailPage extends StatefulWidget {
  const ShowDetailPage({required this.showId, super.key});

  final int showId;

  @override
  State<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends State<ShowDetailPage> {
  final _service = TvMazeService();
  late Future<TvShow> _showFuture;

  @override
  void initState() {
    super.initState();
    _showFuture = _service.fetchShow(widget.showId);
  }

  void _retry() {
    setState(() => _showFuture = _service.fetchShow(widget.showId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail serial')),
      body: FutureBuilder<TvShow>(
        future: _showFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail serial tidak dapat dimuat.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _retry,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final show = snapshot.data;
          if (show == null) {
            return const Center(child: Text('Data serial tidak tersedia.'));
          }
          return _ShowDetails(show: show);
        },
      ),
    );
  }
}

class _ShowDetails extends StatelessWidget {
  const _ShowDetails({required this.show});

  final TvShow show;

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 340,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (show.imageUrl == null)
                  ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: const Icon(Icons.live_tv_rounded, size: 72),
                  )
                else
                  Hero(
                    tag: 'show-poster-${show.id}',
                    child: Image.network(
                      show.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: const Icon(Icons.live_tv_rounded, size: 72),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFF70A7FF),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          show.rating?.toStringAsFixed(1) ?? 'Belum ada rating',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          show.name,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.star_rounded, color: colors.secondary),
            const SizedBox(width: 4),
            Text(
              show.rating?.toStringAsFixed(1) ?? 'Belum ada rating',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (show.genres.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: show.genres
                .map(
                  (genre) => Chip(
                    label: Text(genre),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(growable: false),
          ),
        ],
        const SizedBox(height: 22),
        Text(
          'Tentang serial',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          show.summary.isEmpty ? 'Belum ada ringkasan.' : show.summary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 24),
        Obx(() {
          final isFavorite = favoritesController.contains(show);
          return FilledButton.icon(
            onPressed: () async {
              await favoritesController.toggle(show);
              Get.snackbar(
                isFavorite ? 'Favorit dihapus' : 'Ditambahkan ke favorit',
                show.name,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(
              isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          );
        }),
        if (NotificationService.isSupported) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final scheduled = await NotificationService().scheduleReminder(
                  title: 'Waktunya menonton',
                  body: 'Jangan lupa lanjutkan serial ${show.name}.',
                );
                Get.snackbar(
                  scheduled ? 'Pengingat dibuat' : 'Izin notifikasi diperlukan',
                  scheduled
                      ? 'Notifikasi dijadwalkan sekitar 1 menit lagi.'
                      : 'Aktifkan izin notifikasi di pengaturan perangkat.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } on Exception catch (error) {
                Get.snackbar(
                  'Pengingat gagal dibuat',
                  error.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Ingatkan saya 1 menit lagi'),
          ),
        ],
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authController = Get.find<AuthController>();
  final _favoritesController = Get.find<FavoritesController>();
  late final ProfileController _profileController;
  late final LocationController _locationController;
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _profileController = Get.put(ProfileController(Get.find()));
    _locationController = Get.put(LocationController(LocationService()));
    _nameController = TextEditingController(
      text: _profileController.displayName.value,
    );
    _bioController = TextEditingController(text: _profileController.bio.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await _profileController.saveProfile(
        displayName: _nameController.text,
        bio: _bioController.text,
      );
      Get.snackbar(
        'Profil diperbarui',
        'Perubahan profil berhasil disimpan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on Exception catch (error) {
      Get.snackbar(
        'Profil gagal disimpan',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil foto'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _pickPhoto(ImageSource.camera);
              },
            ),
            Obx(
              () => _profileController.photoBase64.isEmpty
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Hapus foto profil'),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        try {
                          await _profileController.removePhoto();
                        } on Exception catch (error) {
                          _showError('Foto gagal dihapus', error);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final changed = await _profileController.pickPhoto(source);
      if (changed) {
        Get.snackbar(
          'Foto profil diperbarui',
          'Foto berhasil disimpan di perangkat.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on Exception catch (error) {
      _showError('Foto gagal dipilih', error);
    }
  }

  void _showError(String title, Object error) {
    Get.snackbar(title, error.toString(), snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _showInstantNotification() async {
    try {
      final shown = await NotificationService().showInstantNotification(
        title: 'Halo dari Serially!',
        body: 'Semoga hari ini kamu menemukan serial yang seru.',
      );
      Get.snackbar(
        shown ? 'Notifikasi dikirim' : 'Izin notifikasi diperlukan',
        shown
            ? 'Periksa panel notifikasi perangkat.'
            : 'Aktifkan izin notifikasi di pengaturan perangkat.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on Exception catch (error) {
      _showError('Notifikasi gagal', error);
    }
  }

  Future<void> _logout() async {
    try {
      await _authController.logout();
      if (!mounted) return;
      unawaited(
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          (_) => false,
        ),
      );
    } on Exception catch (error) {
      _showError('Logout gagal', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10213D), Color(0xFF174A9B)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Stack(
                    children: [
                      Obx(() {
                        final encoded = _profileController.photoBase64.value;
                        return CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: colors.surfaceContainerHighest,
                            backgroundImage: encoded.isEmpty
                                ? null
                                : MemoryImage(base64Decode(encoded)),
                            child: encoded.isEmpty
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53945),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => Text(
                    _profileController.displayName.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    'NIM ${_authController.username.value}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        label: 'NIM',
                        value: _authController.username.value,
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => _ProfileStat(
                          label: 'Favorit',
                          value: '${_favoritesController.favorites.length}',
                          icon: Icons.favorite_border_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi profil',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'Nama tampilan',
                      prefixIcon: Icon(Icons.person_outline),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 160,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Ceritakan sedikit tentang dirimu',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Simpan profil'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: colors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Kesan & pesan',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Praktikum ini memberi pengalaman langsung membangun aplikasi '
                    'mobile dari antarmuka sampai pengelolaan data. Terima kasih '
                    'kepada para pengampu dan asisten atas ilmu dan bimbingannya. '
                    'Semoga materi yang dipelajari bermanfaat untuk proyek berikutnya.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          if (NotificationService.isSupported) ...[
            const SizedBox(height: 14),
            _LocationCard(controller: _locationController),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifikasi lokal',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Coba notifikasi langsung atau buat pengingat tontonan '
                      'dari halaman detail serial.',
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _showInstantNotification,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Kirim notifikasi uji'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF70A7FF)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.controller});

  final LocationController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location-based service',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ambil lokasi untuk melihat titik demo terdekat. Dalam radius '
              '150 meter, Serially mengirim satu notifikasi kedekatan.',
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoading.value) {
                return const LinearProgressIndicator();
              }
              if (controller.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }
              final position = controller.position.value;
              if (position == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Koordinat: ${position.latitude.toStringAsFixed(5)}, '
                      '${position.longitude.toStringAsFixed(5)}\n'
                      'Terdekat: ${controller.nearestSpot(position)}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                    if (controller.proximityMessage.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        controller.proximityMessage.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: controller.loadCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Ambil lokasi saya'),
            ),
          ],
        ),
      ),
    );
  }
}

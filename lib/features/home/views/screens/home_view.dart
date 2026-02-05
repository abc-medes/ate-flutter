import 'dart:io';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/routes/route_names.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String? _selectedImagePath;
  static final ImagePicker _imagePicker = ImagePicker();

  /// Only request on first open of home this app launch.
  static bool _didRequestPermissionsOnOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPermissionsOnOpen());
  }

  /// When app opens (home shown), ask for health then gallery permission once per launch.
  Future<void> _requestPermissionsOnOpen() async {
    if (_didRequestPermissionsOnOpen || !mounted) return;
    _didRequestPermissionsOnOpen = true;

    // 1. Health (HealthKit / Health Connect) — system sheet
    await healthPermissionService.requestAuthorization();
    if (!mounted) return;

    // 2. Gallery (photos) — system dialog
    await Permission.photos.request();
  }

  /// Request photo library permission (system dialog on first use), then open gallery.
  Future<void> _pickFromGallery() async {
    if (!mounted) return;

    // 1. Request permission — iOS shows dialog using NSPhotoLibraryUsageDescription
    final status = await Permission.photos.request();
    if (!mounted) return;

    if (status.isDenied || status.isPermanentlyDenied) {
      await _showPhotoPermissionDeniedDialog();
      return;
    }

    // 2. Permission granted or limited — open picker
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _selectedImagePath = file.path);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Could not open gallery. Try restarting the app.',
          ),
          backgroundColor: $styles.colors.error,
        ),
      );
    }
  }

  Future<void> _showPhotoPermissionDeniedDialog() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Photo access'),
        content: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Photo library access is needed to select images for analysis. '
            'You can enable it in Settings.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all($styles.insets.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Home',
                    style: $styles.text.h3.copyWith(
                      color: $styles.colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => context.push(RouteNames.chatHistory),
                        child: Icon(
                          CupertinoIcons.calendar,
                          color: $styles.colors.black,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: $styles.insets.xs),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => context.go(RouteNames.settings),
                        child: Icon(
                          CupertinoIcons.settings,
                          color: $styles.colors.black,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: $styles.insets.xs),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => context.go(RouteNames.debug),
                        child: Icon(
                          CupertinoIcons.ant,
                          color: $styles.colors.black,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImagePath!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: $styles.insets.md),
                      CupertinoButton(
                        onPressed: () =>
                            setState(() => _selectedImagePath = null),
                        child: Text(
                          'Clear photo',
                          style: $styles.text.body.copyWith(
                            color: $styles.colors.error,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        'Tap the photo button to select from gallery',
                        style: $styles.text.body.copyWith(
                          color: $styles.colors.caption,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGalleryFAB(context),
    );
  }

  Widget _buildGalleryFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: $styles.colors.greyMedium.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _pickFromGallery,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: $styles.colors.accent1,
          ),
          child: Icon(
            CupertinoIcons.photo_on_rectangle,
            color: $styles.colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

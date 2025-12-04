import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../themes/app_typography.dart';
import '../../services/auth/auth_service.dart';
import '../../services/profile/profile_cache_service.dart';
import '../../services/profile/profile_notifier.dart';
import '../../models/user_profile.dart';
import '../../services/auth/secure_store.dart'; // para limpiar credenciales biométricas
import '../../services/auth/session_prefs.dart';
import '../../services/auth/secure_store.dart'; // si ya lo estabas usando para biometría

// ignore_for_file: uri_does_not_exist, undefined_method, undefined_identifier, non_type_in_catch_clause, use_build_context_synchronously

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _initializing = true;
  bool _loadingAvatarChange = false;

  final TextEditingController _resetEmailCtrl = TextEditingController();

  String _nickname = '';
  String _email = '';

  // Perfil guardado actualmente
  String? _avatarLocalPath;

  // Cambios temporales que el usuario selecciona pero aún no confirma
  String? _pendingAssetAvatar;
  String? _pendingGalleryPath;

  final List<String> _presetAvatars = [
    'assets/avatars/bat_avatar.png',
    'assets/avatars/bear_avatar.png',
    'assets/avatars/beaver_avatar.png',
    'assets/avatars/boar_avatar.png',
    'assets/avatars/buffalo_avatar.png',
    'assets/avatars/camel_avatar.png',
    'assets/avatars/cat_avatar.png',
    'assets/avatars/chameleon_avatar.png',
    'assets/avatars/cheetah_avatar.png',
    'assets/avatars/cow_avatar.png',
    'assets/avatars/deer_avatar.png',
    'assets/avatars/dog_avatar.png',
    'assets/avatars/duck_avatar.png',
    'assets/avatars/eagle_avatar.png',
    'assets/avatars/elephant_avatar.png',
    'assets/avatars/fox_avatar.png',
    'assets/avatars/frog_avatar.png',
    'assets/avatars/giraffe_avatar.png',
    'assets/avatars/goat_avatar.png',
    'assets/avatars/gorilla_avatar.png',
    'assets/avatars/hamster_avatar.png',
    'assets/avatars/hen_avatar.png',
    'assets/avatars/hippo_avatar.png',
    'assets/avatars/horse_avatar.png',
    'assets/avatars/kangaroo_avatar.png',
    'assets/avatars/koala_avatar.png',
    'assets/avatars/lemur_avatar.png',
    'assets/avatars/lion_avatar.png',
    'assets/avatars/llama_avatar.png',
    'assets/avatars/monkey_avatar.png',
    'assets/avatars/ostrich_avatar.png',
    'assets/avatars/owl_avatar.png',
    'assets/avatars/panda_avatar.png',
    'assets/avatars/penguin_avatar.png',
    'assets/avatars/pig_avatar.png',
    'assets/avatars/polarbear_avatar.png',
    'assets/avatars/rabbit_avatar.png',
    'assets/avatars/raccoon_avatar.png',
    'assets/avatars/rhinoceros_avatar.png',
    'assets/avatars/shark_avatar.png',
    'assets/avatars/sheep_avatar.png',
    'assets/avatars/sloth_avatar.png',
    'assets/avatars/snake_avatar.png',
    'assets/avatars/squirrel_avatar.png',
    'assets/avatars/swan_avatar.png',
    'assets/avatars/tiger_avatar.png',
    'assets/avatars/turtle_avatar.png',
    'assets/avatars/walrus_avatar.png',
    'assets/avatars/wolf_avatar.png',
    'assets/avatars/zebra_avatar.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromCache();
  }

  @override
  void dispose() {
    _resetEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFromCache() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final email = user?.email ?? '';

    final cache = ProfileCacheService();
    final UserProfile? prof = await cache.loadProfile(email);

    final nickname = prof?.nickname ?? (email.isNotEmpty ? email : 'Student');
    final avatarPath = prof?.avatarLocalPath;

    setState(() {
      _email = email;
      _resetEmailCtrl.text = email;
      _nickname = nickname;
      _avatarLocalPath = avatarPath;
      _initializing = false;
    });

    final notifier = context.read<ProfileNotifier>();
    notifier.setAll(
      nickname: nickname,
      avatarLocalPath: avatarPath,
    );
  }

  ImageProvider? _currentAvatarProvider() {
    // prioridad 1: selección nueva (sin guardar aún)
    if (_pendingGalleryPath != null) {
      return FileImage(File(_pendingGalleryPath!));
    }
    if (_pendingAssetAvatar != null) {
      return AssetImage(_pendingAssetAvatar!);
    }

    // prioridad 2: avatar ya persistido
    if (_avatarLocalPath != null && _avatarLocalPath!.isNotEmpty) {
      if (_avatarLocalPath!.startsWith('asset:')) {
        final realAsset = _avatarLocalPath!.replaceFirst('asset:', '');
        return AssetImage(realAsset);
      } else {
        return FileImage(File(_avatarLocalPath!));
      }
    }

    // fallback -> null => mostramos letra inicial
    return null;
  }

  void _snack(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.surfaceDim,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            msg,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
  }

  Future<void> _choosePresetAvatar() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _presetAvatars.length,
            itemBuilder: (c, i) {
              final asset = _presetAvatars[i];
              return GestureDetector(
                onTap: () => Navigator.pop(c, asset),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice != null) {
      setState(() {
        _pendingAssetAvatar = choice;
        _pendingGalleryPath = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _pendingGalleryPath = picked.path;
        _pendingAssetAvatar = null;
      });
    }
  }

  Future<void> _saveAvatarChange() async {
    if (_email.isEmpty) {
      _snack('No active user.');
      return;
    }

    if (_pendingGalleryPath == null && _pendingAssetAvatar == null) {
      _snack('No changes to save.');
      return;
    }

    setState(() {
      _loadingAvatarChange = true;
    });

    final cache = ProfileCacheService();
    String? finalPath;

    try {
      // 1. Resolver path final del avatar
      if (_pendingGalleryPath != null) {
        // Foto desde galería -> comprimimos y guardamos estable
        finalPath = await cache.saveCompressedAvatarForEmail(
          email: _email,
          originalPath: _pendingGalleryPath!,
        );
      } else if (_pendingAssetAvatar != null) {
        // Avatar predefinido -> guardamos referencia tipo asset:
        finalPath = 'asset:${_pendingAssetAvatar!}';
      } else {
        finalPath = _avatarLocalPath;
      }

      if (finalPath == null) {
        _snack('Nothing to save.');
        return;
      }

      // 2. Guardar perfil completo en caché persistente
      final updatedProfile = UserProfile(
        email: _email,
        nickname: _nickname,
        avatarLocalPath: finalPath,
      );
      await cache.saveProfile(updatedProfile);

      // 3. Actualizar estado local en Settings
      setState(() {
        _avatarLocalPath = finalPath;
        _pendingGalleryPath = null;
        _pendingAssetAvatar = null;
      });

      // 4. Notificar globalmente -> BurgerMenu / headers refrescan YA
      context.read<ProfileNotifier>().setAll(
        nickname: _nickname,
        avatarLocalPath: finalPath,
      );

      _snack('Profile picture updated');
    } catch (e) {
      _snack('Could not save profile picture.');
    } finally {
      if (mounted) {
        setState(() {
          _loadingAvatarChange = false;
        });
      }
    }
  }

  Future<void> _sendResetPassword() async {
    final email = _resetEmailCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _snack('Enter a valid email.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _snack('Reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? 'Could not send reset link.');
    } catch (_) {
      _snack('Could not send reset link.');
    }
  }
  Future<void> _logout() async {
    try {
      final auth = context.read<AuthService>();
      await auth.signOut();
      await SecureStore.clearBiometricCredentials(); // si usas quick-login
      await SecureStore.clearSessionCredentials();   // ✅ limpia auto-login
      await SessionPrefs.setWasLoggedIn(false);      // ✅ apaga flag offline
    } catch (e) {
      _snack('Could not sign out: $e');
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }





  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (_initializing) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: cs.surfaceDim,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isLight
                    ? 'assets/logos/t_blue.svg'
                    : 'assets/logos/t_white.svg',
                height: 24,
              ),
              const SizedBox(width: 8),
              const Text('AceUp'),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final avatarProvider = _currentAvatarProvider();
    final initialLetter =
    _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surfaceDim,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isLight
                  ? 'assets/logos/t_blue.svg'
                  : 'assets/logos/t_white.svg',
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text('AceUp'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // header visual
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isLight
                    ? 'assets/logos/t_blue.svg'
                    : 'assets/logos/t_white.svg',
                height: 60,
              ),
              const SizedBox(height: 8),
              Text(
                'Account',
                style: AppTypography.h4.copyWith(
                  color: cs.onPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // avatar + nickname
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primaryContainer,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? Text(
                  initialLetter,
                  style: AppTypography.h3.copyWith(
                    color: cs.onPrimary,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _nickname,
                  style: AppTypography.h3.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // botones avatar
          Row(
            children: [
              FilledButton.tonal(
                onPressed: _loadingAvatarChange ? null : _choosePresetAvatar,
                child: const Text('Choose avatar'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _loadingAvatarChange ? null : _pickFromGallery,
                child: const Text('Upload photo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loadingAvatarChange ? null : _saveAvatarChange,
            child: _loadingAvatarChange
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Save profile picture'),
          ),

          const SizedBox(height: 32),

          // security / reset pass
          Text(
            'Security',
            style: AppTypography.bodyM.copyWith(color: cs.secondary),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _resetEmailCtrl,
            decoration: const InputDecoration(
              labelText: 'Account email',
            ),
          ),
          const SizedBox(height: 8),

          FilledButton(
            onPressed: _sendResetPassword,
            child: const Text('Send password reset email'),
          ),

          const SizedBox(height: 32),

          // logout
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: cs.errorContainer,
              foregroundColor: cs.onErrorContainer,
            ),
            onPressed: _logout,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

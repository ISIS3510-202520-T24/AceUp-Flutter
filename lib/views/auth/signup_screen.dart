// lib/views/auth/signup_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ignore: uri_does_not_exist
import 'package:image_picker/image_picker.dart'; // ignore: uri_does_not_exist
import 'package:provider/provider.dart';

import '../../themes/app_typography.dart';
import '../../viewmodels/auth/signup_viewmodel.dart';

import '../../services/profile/profile_cache_service.dart';
import '../../services/profile/profile_notifier.dart';
import '../../models/user_profile.dart';

// ignore_for_file: undefined_identifier, undefined_method

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- Estado visual para avatar en registro ---
  String? _pendingAssetAvatar;   // ej. 'assets/avatars/avatar_2.png'
  String? _pendingGalleryPath;   // ej. '/storage/emulated/0/DCIM/..'
  final List<String> _presetAvatars = const [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
  ];

  bool _pickingAvatar = false; // para deshabilitar botones si está cargando algo

  ImageProvider? _currentAvatarProvider(SignUpViewModel vm, ColorScheme cs) {
    // prioridad: la foto nueva que el user seleccionó en esta pantalla
    if (_pendingGalleryPath != null) {
      return FileImage(File(_pendingGalleryPath!));
    }
    if (_pendingAssetAvatar != null) {
      return AssetImage(_pendingAssetAvatar!);
    }

    // fallback visual si no escogió nada:
    return const AssetImage('assets/avatars/avatar_1.png');
  }

  Future<void> _choosePresetAvatar() async {
    if (_pickingAvatar) return;
    setState(() {
      _pickingAvatar = true;
    });

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
                child: CircleAvatar(
                  backgroundImage: AssetImage(asset),
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

    setState(() {
      _pickingAvatar = false;
    });
  }

  Future<void> _pickFromGallery() async {
    if (_pickingAvatar) return;
    setState(() {
      _pickingAvatar = true;
    });

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

    setState(() {
      _pickingAvatar = false;
    });
  }

  /// Después de que el signup() del ViewModel diga "ok",
  /// persistimos el perfil localmente y notificamos al resto de la app.
  ///
  /// - Guarda nickname y avatar en cache local (ProfileCacheService)
  /// - Llama ProfileNotifier.setAll(...) para que BurgerMenu y Settings se actualicen
  Future<void> _finishSignupPersistProfile({
    required String email,
    required String nickname,
  }) async {
    final cache = ProfileCacheService();
    String? finalAvatarPath;

    // caso foto de galería → comprimimos / guardamos estable por correo
    if (_pendingGalleryPath != null) {
      finalAvatarPath = await cache.saveCompressedAvatarForEmail(
        email: email,
        originalPath: _pendingGalleryPath!,
      );
    }
    // caso avatar predefinido → guardamos referencia "asset:..."
    else if (_pendingAssetAvatar != null) {
        finalAvatarPath = 'asset:${_pendingAssetAvatar!}';
    }
    // fallback → un avatar default
    else {
      finalAvatarPath = 'asset:assets/avatars/avatar_1.png';
    }

    final profile = UserProfile(
      email: email,
      nickname: nickname,
      avatarLocalPath: finalAvatarPath,
    );

    await cache.saveProfile(profile);

    if (mounted) {
      context.read<ProfileNotifier>().setAll(
            nickname: nickname,
            avatarLocalPath: finalAvatarPath,
          );
    }
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final avatarProvider = _currentAvatarProvider(vm, cs);
    final displayNick = vm.form.nickname.isNotEmpty
        ? vm.form.nickname
        : 'Your nickname';
    final initialLetter = vm.form.nickname.isNotEmpty
        ? vm.form.nickname[0].toUpperCase()
        : 'U';

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HEADER con branding
            _Header(isLight: isLight),

            const SizedBox(height: 24),

            // Avatar + Nickname preview
            Row(
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
                    displayNick,
                    style: AppTypography.h3.copyWith(
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: vm.loading || _pickingAvatar
                      ? null
                      : _choosePresetAvatar,
                  child: const Text('Choose avatar'),
                ),
                OutlinedButton(
                  onPressed:
                      vm.loading || _pickingAvatar ? null : _pickFromGallery,
                  child: const Text('Upload photo'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Nickname
            _NicknameField(vm: vm),
            const SizedBox(height: 16),

            // Email
            _EmailField(vm: vm),
            const SizedBox(height: 16),

            // Password
            _PasswordField(vm: vm),
            const SizedBox(height: 16),

            // Confirm password
            _ConfirmField(vm: vm),
            const SizedBox(height: 16),

            // Terms and Conditions
            _TermsAndConditions(vm: vm),

            const SizedBox(height: 24),

            // Botón de crear cuenta
            _SubmitButton(
              vm: vm,
              onSuccess: ({
                required String email,
                required String nickname,
              }) async {
                // 1. Guardar perfil + avatar en cache local
                await _finishSignupPersistProfile(
                  email: email,
                  nickname: nickname,
                );

                // 2. Navegar
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/today');
              },
              onError: (msg) {
                _snack(msg ?? 'Sign up failed.');
              },
            ),

            const SizedBox(height: 24),

            // error global
            if (vm.errorGlobal != null && vm.errorGlobal!.isNotEmpty)
              Text(
                vm.errorGlobal!,
                style: AppTypography.bodyS.copyWith(
                  color: cs.error,
                ),
              ),

            // info extra (ej. "check your email to verify")
            if (vm.infoMessage != null && vm.infoMessage!.isNotEmpty)
              Text(
                vm.infoMessage!,
                style: AppTypography.bodyS.copyWith(
                  color: cs.secondary,
                ),
              ),

            const SizedBox(height: 32),

            // back to login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.secondary,
                  ),
                ),
                TextButton(
                  onPressed: vm.loading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// Encabezado (branding + texto)
// ===============================
class _Header extends StatelessWidget {
  final bool isLight;
  const _Header({required this.isLight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          isLight ? 'assets/logos/t_blue.svg' : 'assets/logos/t_white.svg',
          height: 60,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account',
          style: AppTypography.h4.copyWith(
            color: cs.onPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sync classes, assignments, and holidays across devices.',
          style: AppTypography.bodyM.copyWith(
            color: cs.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ===============================
// Nickname
// ===============================
class _NicknameField extends StatelessWidget {
  final SignUpViewModel vm;
  const _NicknameField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: vm.setNickname,
      decoration: InputDecoration(
        labelText: 'Nickname',
        errorText: vm.errorNickname,
      ),
    );
  }
}

// ===============================
// Email
// ===============================
class _EmailField extends StatelessWidget {
  final SignUpViewModel vm;
  const _EmailField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: vm.setEmail,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: vm.errorEmail,
      ),
    );
  }
}

// ===============================
// Password
// ===============================
class _PasswordField extends StatefulWidget {
  final SignUpViewModel vm;
  const _PasswordField({required this.vm});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return TextField(
      obscureText: _obscure,
      onChanged: vm.setPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: vm.errorPassword,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}

// ===============================
// Confirm password
// ===============================
class _ConfirmField extends StatefulWidget {
  final SignUpViewModel vm;
  const _ConfirmField({required this.vm});

  @override
  State<_ConfirmField> createState() => _ConfirmFieldState();
}

class _ConfirmFieldState extends State<_ConfirmField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return TextField(
      obscureText: _obscure,
      onChanged: vm.setPasswordConfirm,
      decoration: InputDecoration(
        labelText: 'Confirm password',
        errorText: vm.errorConfirm,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}

// ===============================
// Términos y Condiciones
// ===============================
class _TermsAndConditions extends StatelessWidget {
  final SignUpViewModel vm;
  const _TermsAndConditions({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: vm.form.acceptTerms,
              onChanged: (v) {
                vm.setAcceptTerms(v ?? false);
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _openTermsSheet(context);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and the ',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text:
                            '. I understand that my schedule, assignments, and holidays may sync using cloud backup.',
                        style: AppTypography.bodyS.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // error visual si no aceptó términos
        if (vm.errorGlobal == 'TERMS')
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'You must accept terms.',
              style: AppTypography.bodyS.copyWith(
                color: cs.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// BottomSheet con Términos y Privacidad
void _openTermsSheet(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms & Privacy',
                      style: AppTypography.h4.copyWith(
                        color: cs.onPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'AceUp Terms of Service',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By creating an account you agree that this app will store and sync certain academic data '
                  'such as assignments, deadlines, classes, and holidays. We use this data ONLY to help you plan.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Privacy Policy',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We respect your privacy. Your schedule and course data belongs to you. '
                  'We may back it up in the cloud so you can access it from multiple devices, '
                  'and to enable optional features like biometric quick login.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Data Retention',
                  style: AppTypography.h4.copyWith(
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you delete your account, we will remove any stored personal data from our cloud. '
                  'Some anonymized usage statistics may be kept to help us improve.',
                  style: AppTypography.bodyS.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ===============================
// Botón principal "Create account"
// ===============================
class _SubmitButton extends StatelessWidget {
  final SignUpViewModel vm;

  /// onSuccess se llama SOLO si vm.signup() -> ok:true
  /// Te paso email/nickname que quedaron en el form, para persistir perfil.
  final Future<void> Function({
    required String email,
    required String nickname,
  }) onSuccess;

  /// onError se llama si signup falla.
  final void Function(String? message) onError;

  const _SubmitButton({
    required this.vm,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: vm.loading
          ? null
          : () async {
              final res = await vm.signup();
              if (!context.mounted) return;

              if (res.ok) {
                await onSuccess(
                  email: vm.form.email,
                  nickname: vm.form.nickname,
                );
              } else {
                onError(res.message);
              }
            },
      child: vm.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Create account'),
    );
  }
}

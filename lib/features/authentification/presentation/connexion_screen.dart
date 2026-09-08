import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_controller.dart';

// Écran de connexion par SMS : d'abord le numéro de téléphone, puis le
// code reçu par SMS. Deux étapes gérées dans le même écran.
class ConnexionScreen extends ConsumerStatefulWidget {
  const ConnexionScreen({super.key});

  @override
  ConsumerState<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends ConsumerState<ConnexionScreen> {
  final _telephoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _telephoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _envoyerCode() {
    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) return;
    ref.read(authControllerProvider.notifier).envoyerCode(telephone);
  }

  void _verifierCode(String verificationId) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    ref.read(authControllerProvider.notifier).verifierCode(verificationId, code);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final enCours = authState is AuthEnvoiCodeEnCours;
    final codeEnvoye = authState is AuthCodeEnvoye;
    final messageErreur = switch (authState) {
      AuthNonConnecte(:final messageErreur) => messageErreur,
      AuthCodeEnvoye(:final messageErreur) => messageErreur,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school_rounded, size: 56, color: Color(0xFF1F3864)),
                const SizedBox(height: 12),
                Text(
                  'LMS National',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F3864),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Formation des cadres et élus locaux',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),

                if (messageErreur != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            messageErreur,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (!codeEnvoye) ...[
                  Text('Numéro de téléphone', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Ex : +224622000000',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Format international requis (indicatif du pays inclus).',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: enCours ? null : _envoyerCode,
                    child: enCours
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Recevoir le code par SMS', style: TextStyle(fontSize: 16)),
                  ),
                ] else ...[
                  Text('Code reçu par SMS', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, letterSpacing: 4),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: '••••••'),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: enCours
                        ? null
                        : () => _verifierCode((authState as AuthCodeEnvoye).verificationId),
                    child: enCours
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Valider', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
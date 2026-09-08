import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/certificats_providers.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class CertificatsScreen extends ConsumerWidget {
  const CertificatsScreen({super.key});

  // Ouvre le PDF du certificat dans le navigateur/lecteur PDF du telephone,
  // qui propose ensuite de le telecharger ou de le partager.
  Future<void> _telechargerCertificat(WidgetRef ref, String certificatId) async {
    final dio = ref.read(dioProvider);
    final url = '${dio.options.baseUrl}${ApiEndpoints.certificatPdf(certificatId)}';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatsAsync = ref.watch(certificatsProvider);
    final formatDate = DateFormat('d MMMM yyyy', 'fr_FR');
    return Scaffold(
      appBar: AppBar(title: const Text('Mes certificats')),
      body: certificatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(certificatsProvider),
            child: const Text('Erreur de chargement — Réessayer'),
          ),
        ),
        data: (certificats) {
          if (certificats.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun certificat pour le moment.\nTerminez une formation à 100% pour en obtenir un.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: certificats.length,
            itemBuilder: (context, index) {
              final certificat = certificats[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Certificat de réussite',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                                Text(
                                  certificat.formationTitre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Délivré le ${formatDate.format(certificat.dateDelivrance)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _telechargerCertificat(ref, certificat.id),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Télécharger le certificat'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

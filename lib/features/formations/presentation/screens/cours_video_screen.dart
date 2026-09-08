import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../documents/data/repositories/documents_repository.dart';
import '../../../documents/providers/document_controller.dart';
import '../../data/models/cours_model.dart';

class CoursVideoScreen extends ConsumerStatefulWidget {
  final Cours cours;
  const CoursVideoScreen({super.key, required this.cours});

  @override
  ConsumerState<CoursVideoScreen> createState() => _CoursVideoScreenState();
}

class _CoursVideoScreenState extends ConsumerState<CoursVideoScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _erreur;
  bool _initialise = false;

  late final DocumentParams _params;

  @override
  void initState() {
    super.initState();
    _params = DocumentParams(
      id: widget.cours.id,
      url: widget.cours.urlFichier,
      nom: widget.cours.titre,
    );
    _initialiserLecteur();
  }

  Future<void> _initialiserLecteur({String? cheminLocal}) async {
    setState(() => _initialise = false);
    _videoController = cheminLocal != null
        ? VideoPlayerController.file(File(cheminLocal))
        : VideoPlayerController.networkUrl(Uri.parse(widget.cours.urlFichier));
    try {
      await _videoController!.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
        );
        _initialise = true;
      });
    } catch (e) {
      setState(() => _erreur = 'Impossible de charger la vidéo.');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final etat = ref.watch(documentControllerProvider(_params));

    ref.listen(documentControllerProvider(_params), (previous, next) {
      if (next is DocumentTelecharge && previous is! DocumentTelecharge) {
        _videoController?.pause();
        _initialiserLecteur(cheminLocal: next.cheminLocal);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cours.titre),
        actions: [_boutonTelechargement(etat)],
      ),
      body: Center(
        child: _erreur != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_erreur!, textAlign: TextAlign.center),
              )
            : !_initialise
                ? const CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio == 0
                        ? 16 / 9
                        : _videoController!.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
      ),
    );
  }

  Widget _boutonTelechargement(EtatDocument etat) {
    return switch (etat) {
      DocumentNonTelecharge() => IconButton(
          icon: const Icon(Icons.download_for_offline_outlined),
          tooltip: 'Télécharger pour le hors-ligne',
          onPressed: () =>
              ref.read(documentControllerProvider(_params).notifier).telecharger(),
        ),
      DocumentEnTelechargement(:final progression) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(value: progression, strokeWidth: 2, color: Colors.white),
          ),
        ),
      DocumentTelecharge() => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.offline_pin_rounded, color: Colors.greenAccent),
        ),
      DocumentErreurTelechargement() => IconButton(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          tooltip: 'Échec — réessayer',
          onPressed: () =>
              ref.read(documentControllerProvider(_params).notifier).telecharger(),
        ),
    };
  }
}

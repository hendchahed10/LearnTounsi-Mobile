import 'package:flutter/material.dart';
import 'package:learntounsi_mobile/main.dart';
import 'package:learntounsi_mobile/viewmodel/matieres_viewmodel.dart';
import 'package:learntounsi_mobile/model/matiere.dart';
import 'dart:io';                       // pour File
import 'package:file_picker/file_picker.dart'; // pour FilePicker
import '../widgets/gardient.dart';

class EcranMatieres extends StatefulWidget {
  @override
  _EcranMatieresState createState() => _EcranMatieresState();
}

class _EcranMatieresState extends State<EcranMatieres> {
  late final MatieresViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = MatieresViewModel();          // ViewModel gère le stream
  }

  @override
  void dispose() {
    _vm.dispose();                       // libère les observables
    super.dispose();
  }

  /* ----------------------------------------------------------
                             BUILD
   ---------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
      valueListenable: _vm.isLoading,
        builder: (_, loading, __) {
          if (loading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(
                  color: Color(0xFF7ca982),
                  strokeWidth: 5,
                ),
              ),
            );
          }

          return ValueListenableBuilder<List<Matiere>>( //widget reactif qui rebuild automatiquement une partie de l'interface, et non pas l'entierté de l'arbre comme avec setState
            valueListenable: _vm.matieres,
            builder: (_, matieres, __) {
              return CustomScrollView(
                  slivers: [
              /* ---------- Header ---------- */
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 30,
                          left: MediaQuery.of(context).size.width < 600 ? 20 : 40,
                          right: MediaQuery.of(context).size.width < 600 ? 20 : 40,
                          bottom: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Bouton "+"
                            Container(
                              width: MediaQuery.of(context).size.width < 600 ? 60 : 80,
                              height: MediaQuery.of(context).size.width < 600 ? 60 : 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7ca982),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: MediaQuery.of(context).size.width < 600 ? 30 : 40,
                                  color: Colors.white,
                                ),
                                onPressed: () => _showAddMatiereDialog(context),
                                tooltip: 'Ajouter une matière',
                              ),
                            ),

                            // Titre (responsive)
                            Expanded(
                              child: Center(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Calcul de la taille de police responsive
                                    double fontSize;
                                    if (constraints.maxWidth < 400) {
                                      fontSize = 24; // Très petit écran
                                    } else if (constraints.maxWidth < 600) {
                                      fontSize = 32; // Mobile
                                    } else if (constraints.maxWidth < 900) {
                                      fontSize = 40; // Tablette
                                    } else {
                                      fontSize = 50; // Desktop
                                    }

                                    return Text(
                                      'Interface Admin',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Lucida',
                                        fontSize: fontSize,
                                        color: Color(0xFF528859),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Bouton Statistiques
                            Container(
                              width: MediaQuery.of(context).size.width < 600 ? 60 : 80,
                              height: MediaQuery.of(context).size.width < 600 ? 60 : 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFd4c78f),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.bar_chart,
                                  size: MediaQuery.of(context).size.width < 600 ? 30 : 40,
                                  color: Color(0xFF243e36),
                                ),
                                onPressed: () => Navigator.pushNamed(context, '/statistiques_matieres'),
                                tooltip: 'Voir les statistiques des matières',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

              /* ---------- Liste observable ---------- */
                      if (matieres.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open, size: 80, color: Colors.grey),
                                SizedBox(height: 20),
                                Text(
                                  'Aucune matière trouvée',
                                  style: TextStyle(fontSize: 20, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount;
                              double mainAxisExtent;
                              if (constraints.crossAxisExtent > 1400) {
                                crossAxisCount = 4;
                                mainAxisExtent = 350; // Plus de hauteur pour desktop
                              } else if (constraints.crossAxisExtent > 1000) {
                                crossAxisCount = 3;
                                mainAxisExtent = 380;
                              } else if (constraints.crossAxisExtent > 700) {
                                crossAxisCount = 2;
                                mainAxisExtent = 400;
                              } else {
                                crossAxisCount = 1;
                                mainAxisExtent = 450; // Encore plus de hauteur pour mobile
                              }

                              return SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 30,
                                  crossAxisSpacing: 30,
                                  mainAxisExtent:  mainAxisExtent, //  Hauteur dynamique
                                ),
                                delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildMatiereCard(matieres[index]),
                                  childCount: matieres.length,
                                ),
                              );
                            },
                          ),
                        ),

                    const SliverToBoxAdapter(child: SizedBox(height: 50)),
                  ],
              );
            },
              );
            },
          ),
          ),
          );
  }

  /* ----------------------------------------------------------
                         Widgets / Dialogs
   ---------------------------------------------------------- */
  Widget _buildMatiereCard(Matiere matiere) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFb6f0bd),  // Vert plus foncé en haut à gauche
            Color(0xFFc8d5b9),  // Vert clair au milieu
            Color(0xFFe8f0d8),  // Vert très clair en bas à droite
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,  // Important : transparent pour voir le dégradé
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, '/details_matiere', arguments: matiere),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageWidget(matiere.image),
                Text(
                  matiere.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243e36)),
                ),
                const SizedBox(height: 8),
                Text(
                  matiere.description ?? 'Aucune description.',
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: const Color(0xFF243e36).withOpacity(.7), height: 1.3),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ca982).withOpacity(.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Prix : ${matiere.prix.toStringAsFixed(0)} DT',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF243e36)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _iconButton(Icons.edit, const Color(0xFFa89968), () => _showEditMatiereDialog(matiere)),
                    const SizedBox(width: 8),
                    _iconButton(Icons.delete, const Color(0xFFc97777), () => _showDeleteConfirmDialog(matiere)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    // Si pas d'image
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        'assets/images/matieres/$imagePath',
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Erreur chargement image: $error');
          return Container(
            height: 120,
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey), //affichage d'une image grisâtre en cas d'erreur
                SizedBox(height: 5),
                Text(
                  'Image non trouvée',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; //si le chargement est complet, retourner l'image
          return Container(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! //barre de progression tant que l’image télécharge
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );
  }

  /* ---------- Dialogs ---------- */
  void _showAddMatiereDialog(BuildContext context) {
    final titreCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final prixCtrl  = TextEditingController();
    final catCtrl   = TextEditingController();
    final imageCtrl = TextEditingController();
    String? imageSelectionnee;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajouter une matière'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 15),
              TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix (DT)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Choisir image'),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    imageCtrl.text = result.files.single.name;   // affiche le nom
                  }
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'Nom image (ou laisser vide)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titreCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le titre est obligatoire !')),
                );
                return;
              }

              final prix = double.tryParse(prixCtrl.text) ?? 0.0;
              if (prixCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le prix est obligatoire !')),
                );
                return;
              }

              else if (prix < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le prix ne peut pas être négatif !')),
                );
                return;
              }
              try {
                await _vm.addMatiere(
                  titre: titreCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  prix: double.tryParse(prixCtrl.text) ?? 0.0,
                  category: catCtrl.text.trim(),
                  image: imageCtrl.text,

                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Matière ajoutée')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur : $e')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditMatiereDialog(Matiere m) {
    final titreCtrl = TextEditingController(text: m.titre);
    final descCtrl  = TextEditingController(text: m.description);
    final prixCtrl  = TextEditingController(text: m.prix.toString());
    final catCtrl   = TextEditingController(text: m.category);
    final imageCtrl = TextEditingController();
    File? _selectedFile;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifier la matière ${m.titre}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 15),
              TextField(controller: prixCtrl, decoration: const InputDecoration(labelText: 'Prix (DT)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Choisir image'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  _selectedFile = File(result.files.single.path!);
                  imageCtrl.text = result.files.single.name;   // affiche le nom
                }
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: imageCtrl,
              decoration: const InputDecoration(labelText: 'Nom image (ou laisser vide)', border: OutlineInputBorder()),
              readOnly: _selectedFile != null, // empêche la saisie si fichier choisi
            ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titreCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le titre est obligatoire !')),
                );
                return;
              }

              final prix = double.tryParse(prixCtrl.text) ?? 0.0;
              if (prixCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le prix est obligatoire !')),
                );
                return;
              }

              else if (prix < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le prix ne peut pas être négatif !')),
                );
                return;
              }
              try {
                await _vm.updateMatiere(
                  id: m.id,
                  titre: titreCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  prix: double.tryParse(prixCtrl.text) ?? 0.0,
                  category: catCtrl.text.trim(),
                  image : imageCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Matière modifiée')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur : $e')),
                );
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Matiere m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer « ${m.titre} » ?'),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _vm.deleteMatiere(m.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Matière supprimée')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur : $e')),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
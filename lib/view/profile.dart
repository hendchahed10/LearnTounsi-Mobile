import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;

  Map<String, dynamic>? firestoreUser;
  List<Map<String, dynamic>> achats = [];
  List<Map<String, dynamic>> consultes = [];
  List<Map<String, dynamic>> termines = [];

  int progression = 0;
  String activeTab = "achats";
  bool loading = true;

  String? editingField;
  String tempValue = "";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      await Future.wait([
        _loadUser(user.uid),

        _loadAchats(),

        _loadConsultes(user.uid),
        _loadTermines(user.uid),
      ]);

      _computeProgression();
    } catch (e) {
      debugPrint("Erreur chargement profil: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _loadUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) firestoreUser = doc.data();
  }

  Future<void> _loadAchats() async {
    final snap = await FirebaseFirestore.instance
        .collection('cours')
        .where('payant', isEqualTo: "oui")
        .get();

    achats = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  Future<void> _loadConsultes(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('consultation')
        .where('user_id', isEqualTo: uid)
        .get();

    final all = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();

    all.sort((a, b) {
      final ta = a['date'];
      final tb = b['date'];
      final sa = ta is Timestamp ? ta.seconds : 0;
      final sb = tb is Timestamp ? tb.seconds : 0;
      return sa.compareTo(sb);
    });

    final seen = <dynamic>{};
    consultes = [];

    for (final c in all) {
      if (!seen.contains(c["cours_id"])) {
        consultes.add(c);
        seen.add(c["cours_id"]);
      }
    }
  }

  // 🔹 4) Charger cours terminés
  Future<void> _loadTermines(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('cours_termines')
        .where('user_id', isEqualTo: uid)
        .get();

    termines = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }


  void _computeProgression() {
    if (consultes.isEmpty) {
      progression = 0;
      return;
    }
    progression = ((termines.length / consultes.length) * 100).round().clamp(0, 100);
  }

  // 🔹 6) Enregistrer un champ modifié
  Future<void> _saveField() async {
    if (editingField == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({editingField!: tempValue});

      firestoreUser![editingField!] = tempValue;
      setState(() => editingField = null);
    } catch (e) {
      debugPrint("Erreur maj: $e");
    }
  }

  // 🔹 Champ éditable
  Widget _buildEditableField(String label, String key) {
    final value = firestoreUser?[key] ?? "—";
    final isEditing = editingField == key;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text("$label :", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: isEditing
                ? TextField(
              autofocus: true,
              onChanged: (v) => tempValue = v,
              controller: TextEditingController(text: tempValue),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            )
                : Text(value.toString()),
          ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => setState(() {
                editingField = key;
                tempValue = value;
              }),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, size: 18, color: Colors.green),
              onPressed: _saveField,
            ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is! Timestamp) return "—";
    final dt = date.toDate();
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
    }

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        backgroundColor: const Color(0xFF234138),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 30, child: Icon(Icons.person)),
                        const SizedBox(width: 10),
                        Text(user.email ?? "", style: const TextStyle(fontSize: 16)),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildEditableField("Nom", "nom"),
                    _buildEditableField("Prénom", "prenom"),
                    _buildEditableField("Date de naissance", "dateNaissance"),

                    const SizedBox(height: 20),
                    const Text("Progression globale :", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),

                    Stack(
                      children: [
                        Container(height: 10, color: Colors.grey.shade300),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * progression / 100,
                          color: const Color(0xFFC2A83E),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("$progression%"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),


            Row(
              children: [
                _buildTabButton("Cours achetés", "achats"),
                _buildTabButton("Cours terminés", "termines"),
                _buildTabButton("Cours consultés", "consultes"),
              ],
            ),

            const SizedBox(height: 16),

            if (activeTab == "achats") _buildAchatsTable(),
            if (activeTab == "termines") _buildTerminesTable(),
            if (activeTab == "consultes") _buildConsultesTable(),
          ],
        ),
      ),
    );
  }

  //boutton
  Widget _buildTabButton(String label, String key) {
    final isActive = activeTab == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF234138) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: isActive ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  // achetes
  Widget _buildAchatsTable() {
    if (achats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("Aucun cours acheté.")),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Cours")),
          DataColumn(label: Text("Matière")),
          DataColumn(label: Text("Prix")),
          DataColumn(label: Text("Statut")),
        ],
        rows: achats.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c['titre'] ?? "")),
              DataCell(Text(c['matiere'] ?? "")),
              DataCell(Text("${c['prix'] ?? 0} DT")),
              const DataCell(Text("Payé")),
            ],
          );
        }).toList(),
      ),
    );
  }

  //termines
  Widget _buildTerminesTable() {
    if (termines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("Aucun cours terminé.")),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Matière")),
          DataColumn(label: Text("Cours")),
          DataColumn(label: Text("Date")),
        ],
        rows: termines.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c['matiere'] ?? "")),
              DataCell(Text(c['titre'] ?? "")),
              DataCell(Text(_formatDate(c['date']))),
            ],
          );
        }).toList(),
      ),
    );
  }

  //consultes
  Widget _buildConsultesTable() {
    if (consultes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("Aucun cours consulté.")),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Matière")),
          DataColumn(label: Text("Cours")),
          DataColumn(label: Text("Date")),
        ],
        rows: consultes.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c['matiere'] ?? "")),
              DataCell(Text(c['titre'] ?? c['cours_id'] ?? "")),
              DataCell(Text(_formatDate(c['date']))),
            ],
          );
        }).toList(),
      ),
    );
  }
}

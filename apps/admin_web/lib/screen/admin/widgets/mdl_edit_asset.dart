import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ModalEditAsset {
  static void show(
    BuildContext context, {
    required String namaAset,
    required List<Map<String, dynamic>> asetRows,
    required Function(List<Map<String, dynamic>>, Map<String, dynamic>) onSave,
  }) {
    if (asetRows.isEmpty) return;

    final _formKey = GlobalKey<FormState>();
    final _kodeMesinController = TextEditingController(
      text: asetRows.first["kode_assets"] ?? '',
    );

    String _namaAset = asetRows.first["nama_aset"];
    String _jenisAset = asetRows.first["jenis_aset"];
    String? _gambarAset = asetRows.first["gambar_aset"];
    String? _prioritas = asetRows.first["mt_priority"];

    Map<String, List<Map<String, dynamic>>> grouped = _groupByBagian(asetRows);
    List<Map<String, dynamic>> bagianList =
        grouped.entries.map((entry) {
          return {
            "namaBagian": entry.key,
            "komponen":
                entry.value
                    .map(
                      (item) => {
                        "namaKomponen": item["komponen_aset"],
                        "spesifikasi": item["produk_yang_digunakan"],
                      },
                    )
                    .toList(),
          };
        }).toList();

    final ImagePicker picker = ImagePicker();
    XFile? newImage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(ctx),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Row untuk Nama Aset dan Kode Mesin
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNamaAsetField(
                                      _namaAset,
                                      (v) => _namaAset = v,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildKodeMesinField(
                                      _kodeMesinController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildJenisAsetField(
                                _jenisAset,
                                (v) => _jenisAset = v!,
                              ),
                              SizedBox(height: 16),
                              _buildPrioritasField(
                                _prioritas,
                                (v) => _prioritas = v,
                                setDialogState,
                              ),
                              SizedBox(height: 20),
                              _buildBagianKomponenSection(
                                bagianList,
                                setDialogState,
                              ),
                              SizedBox(height: 20),
                              _buildGambarSection(
                                _gambarAset,
                                newImage,
                                picker,
                                setDialogState,
                                (image) => newImage = image,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(
                      context,
                      ctx,
                      _formKey,
                      _namaAset,
                      _kodeMesinController,
                      _jenisAset,
                      _prioritas,
                      _gambarAset,
                      newImage,
                      bagianList,
                      asetRows,
                      namaAset,
                      onSave,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Map<String, List<Map<String, dynamic>>> _groupByBagian(
    List<Map<String, dynamic>> items,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      String bagian = item["bagian_aset"];
      if (!grouped.containsKey(bagian)) {
        grouped[bagian] = [];
      }
      grouped[bagian]!.add(item);
    }
    return grouped;
  }

  static Widget _buildHeader(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0A9C5D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            'Edit Data Aset',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  static Widget _buildNamaAsetField(
    String namaAset,
    Function(String) onChanged,
  ) {
    return TextFormField(
      initialValue: namaAset,
      decoration: InputDecoration(
        labelText: 'Nama Aset *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
    );
  }

  static Widget _buildKodeMesinField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Kode Mesin',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.qr_code),
        hintText: 'Contoh: MP-001',
      ),
      // Kode mesin tidak wajib (optional)
    );
  }

  static Widget _buildJenisAsetField(
    String jenisAset,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: jenisAset,
      decoration: InputDecoration(
        labelText: "Jenis Aset *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          [
            "Mesin Produksi",
            "Alat Berat",
            "Listrik",
            "Kendaraan",
            "Lainnya",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  static Widget _buildPrioritasField(
    String? selectedPrioritas,
    Function(String?) onChanged,
    StateSetter setDialogState,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedPrioritas,
      decoration: InputDecoration(
        labelText: 'Prioritas Maintenance',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high),
        helperText: 'Prioritas untuk maintenance schedule',
      ),
      items: [
        'Low',
        'Medium',
        'High',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          onChanged(value);
        });
      },
      // Prioritas optional (bisa null)
    );
  }

  static Widget _buildBagianKomponenSection(
    List<Map<String, dynamic>> bagianList,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bagian & Komponen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 12),
        ...bagianList.asMap().entries.map((entry) {
          int i = entry.key;
          Map<String, dynamic> bagian = entry.value;

          return _buildBagianCard(i, bagian, bagianList, setDialogState);
        }).toList(),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            icon: Icon(Icons.add_circle),
            label: Text("Tambah Bagian"),
            onPressed: () {
              setDialogState(() {
                bagianList.add({
                  "namaBagian": "",
                  "komponen": [
                    {"namaKomponen": "", "spesifikasi": ""},
                  ],
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A9C5D),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildBagianCard(
    int i,
    Map<String, dynamic> bagian,
    List<Map<String, dynamic>> bagianList,
    StateSetter setDialogState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: bagian["namaBagian"],
                  decoration: InputDecoration(
                    labelText: "Nama Bagian *",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => bagian["namaBagian"] = v,
                ),
              ),
              if (bagianList.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setDialogState(() {
                      bagianList.removeAt(i);
                    });
                  },
                ),
            ],
          ),
          SizedBox(height: 16),
          ...bagian["komponen"].asMap().entries.map((compEntry) {
            int j = compEntry.key;
            Map<String, dynamic> komponen = compEntry.value;

            return _buildKomponenCard(j, komponen, bagian, setDialogState);
          }).toList(),
          OutlinedButton.icon(
            icon: Icon(Icons.add),
            label: Text("Tambah Komponen"),
            onPressed: () {
              setDialogState(() {
                (bagian["komponen"] as List).add({
                  "namaKomponen": "",
                  "spesifikasi": "",
                });
              });
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildKomponenCard(
    int j,
    Map<String, dynamic> komponen,
    Map<String, dynamic> bagian,
    StateSetter setDialogState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: komponen["namaKomponen"],
              decoration: InputDecoration(
                labelText: "Komponen *",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => komponen["namaKomponen"] = v,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: komponen["spesifikasi"],
              decoration: InputDecoration(
                labelText: "Spesifikasi *",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => komponen["spesifikasi"] = v,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setDialogState(() {
                (bagian["komponen"] as List).removeAt(j);
              });
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildGambarSection(
    String? gambarAset,
    XFile? newImage,
    ImagePicker picker,
    StateSetter setDialogState,
    Function(XFile?) onImageChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Gambar Aset",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 12),
        if (gambarAset != null || newImage != null)
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  newImage != null
                      ? (kIsWeb
                          ? Image.network(newImage.path, fit: BoxFit.cover)
                          : Image.file(File(newImage.path), fit: BoxFit.cover))
                      : (kIsWeb
                          ? Image.network(gambarAset!, fit: BoxFit.cover)
                          : Image.file(File(gambarAset!), fit: BoxFit.cover)),
            ),
          ),
        SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(Icons.upload_file),
          label: Text("Ganti Foto"),
          onPressed: () async {
            final picked = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
            );
            if (picked != null) {
              setDialogState(() {
                onImageChanged(picked);
              });
            }
          },
        ),
      ],
    );
  }

  static Widget _buildFooter(
    BuildContext context,
    BuildContext ctx,
    GlobalKey<FormState> formKey,
    String namaAset,
    TextEditingController kodeMesinController,
    String jenisAset,
    String? prioritas,
    String? gambarAset,
    XFile? newImage,
    List<Map<String, dynamic>> bagianList,
    List<Map<String, dynamic>> asetRows,
    String originalNamaAset,
    Function(List<Map<String, dynamic>>, Map<String, dynamic>) onSave,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(child: Text("Batal"), onPressed: () => Navigator.pop(ctx)),
          SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A9C5D),
              foregroundColor: Colors.white,
            ),
            child: Text("Simpan Perubahan"),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              // Capture variables untuk digunakan di closure
              final currentNamaAset = namaAset;
              final currentKodeMesin = kodeMesinController.text.trim();
              final currentJenisAset = jenisAset;
              final currentPrioritas = prioritas;
              final currentGambarAset = gambarAset;
              final currentNewImage = newImage;
              final currentBagianList = bagianList;
              final currentAsetRows = asetRows;
              final currentOriginalNamaAset = originalNamaAset;

              List<Map<String, dynamic>> newData = [];
              for (var bagian in currentBagianList) {
                for (var komponen in bagian["komponen"]) {
                  newData.add({
                    "id": currentAsetRows.first["id"], // Include ID untuk update
                    "nama_aset": currentNamaAset,
                    "kode_assets": currentKodeMesin.isEmpty 
                        ? null 
                        : currentKodeMesin,
                    "jenis_aset": currentJenisAset,
                    "status": currentAsetRows.first["status"] ?? 'Aktif', // Keep existing status
                    "mt_priority": currentPrioritas,
                    "maintenance_terakhir":
                        currentAsetRows.first["maintenance_terakhir"],
                    "maintenance_selanjutnya":
                        currentAsetRows.first["maintenance_selanjutnya"],
                    "bagian_aset": bagian["namaBagian"],
                    "komponen_aset": komponen["namaKomponen"],
                    "produk_yang_digunakan": komponen["spesifikasi"],
                    "gambar_aset":
                        currentNewImage != null ? currentNewImage.path : currentGambarAset,
                  });
                }
              }

              onSave(newData, {"nama_aset": currentOriginalNamaAset});
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Data aset berhasil diperbarui"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

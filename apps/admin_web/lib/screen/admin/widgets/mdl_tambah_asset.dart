import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared/repositories/asset_supabase_repository.dart';
import 'package:shared/models/asset_supabase_models.dart';
import 'package:shared/services/supabase_storage_service.dart';

class ModalTambahAsset {
  static void show(
    BuildContext context, {
    required Function(List<Map<String, dynamic>>) onSave,
  }) {
    final _formKey = GlobalKey<FormState>();
    final _namaAsetController = TextEditingController();
    final _kodeMesinController = TextEditingController();
    final ImagePicker _imagePicker = ImagePicker();

    String? _selectedJenisAset;
    String? _selectedPrioritas;
    XFile? _selectedImage;

    List<Map<String, dynamic>> bagianAsetList = [
      {
        'namaBagian': '',
        'komponen': [
          {'namaKomponen': '', 'spesifikasi': ''},
        ],
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(dialogContext, () {
                      _selectedImage = null;
                      _namaAsetController.dispose();
                      _kodeMesinController.dispose();
                    }),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Row untuk Nama Aset dan Kode Mesin
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNamaAsetField(_namaAsetController),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: _buildKodeMesinField(_kodeMesinController),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildJenisAsetField(
                                _selectedJenisAset,
                                setDialogState,
                                (value) => _selectedJenisAset = value,
                              ),
                              SizedBox(height: 16),
                              _buildPrioritasField(
                                _selectedPrioritas,
                                setDialogState,
                                (value) => _selectedPrioritas = value,
                              ),
                              SizedBox(height: 24),
                              Divider(thickness: 2, color: Colors.grey[300]),
                              SizedBox(height: 16),
                              _buildBagianKomponenSection(
                                bagianAsetList,
                                setDialogState,
                              ),
                              SizedBox(height: 24),
                              Divider(thickness: 2, color: Colors.grey[300]),
                              SizedBox(height: 16),
                              _buildGambarSection(
                                context,
                                _selectedImage,
                                _imagePicker,
                                setDialogState,
                                (image) => _selectedImage = image,
                              ),
                              SizedBox(height: 24),
                              Text(
                                '* Wajib diisi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(
                      context,
                      dialogContext,
                      _formKey,
                      _namaAsetController,
                      _kodeMesinController,
                      _selectedJenisAset,
                      _selectedPrioritas,
                      _selectedImage,
                      bagianAsetList,
                      onSave,
                      () {
                        _selectedImage = null;
                      },
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

  static Widget _buildHeader(
    BuildContext dialogContext,
    VoidCallback onClose,
  ) {
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
          Icon(Icons.add_circle, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            'Tambah Data Aset',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onClose();
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildNamaAsetField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nama Aset *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.business),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama aset harus diisi';
        }
        return null;
      },
    );
  }

  static Widget _buildKodeMesinField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Kode Mesin',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.qr_code),
        hintText: 'Contoh: MP-001',
      ),
      // Kode mesin tidak wajib (optional)
    );
  }

  static Widget _buildJenisAsetField(
    String? selectedJenisAset,
    StateSetter setDialogState,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedJenisAset,
      decoration: InputDecoration(
        labelText: 'Jenis Aset *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          [
            'Mesin Produksi',
            'Alat Berat',
            'Listrik',
            'Kendaraan',
            'Lainnya',
          ].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (value) {
        setDialogState(() {
          onChanged(value);
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Jenis aset harus dipilih';
        }
        return null;
      },
    );
  }

  static Widget _buildPrioritasField(
    String? selectedPrioritas,
    StateSetter setDialogState,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedPrioritas,
      decoration: InputDecoration(
        labelText: 'Prioritas Maintenance',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    List<Map<String, dynamic>> bagianAsetList,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bagian Aset & Komponen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 16),
        ...bagianAsetList.asMap().entries.map((entry) {
          int bagianIndex = entry.key;
          Map<String, dynamic> bagian = entry.value;
          List<Map<String, dynamic>> komponenList =
              bagian['komponen'] as List<Map<String, dynamic>>;

          return _buildBagianCard(
            bagianIndex,
            bagian,
            komponenList,
            bagianAsetList,
            setDialogState,
          );
        }).toList(),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            setDialogState(() {
              List<Map<String, dynamic>> newBagianList = List.from(
                bagianAsetList,
              );
              newBagianList.add({
                'namaBagian': '',
                'komponen': [
                  {'namaKomponen': '', 'spesifikasi': ''},
                ],
              });
              bagianAsetList.clear();
              bagianAsetList.addAll(newBagianList);
            });
          },
          icon: Icon(Icons.add_circle),
          label: Text('Tambah Bagian Aset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0A9C5D),
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  static Widget _buildBagianCard(
    int bagianIndex,
    Map<String, dynamic> bagian,
    List<Map<String, dynamic>> komponenList,
    List<Map<String, dynamic>> bagianAsetList,
    StateSetter setDialogState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('bagian_$bagianIndex'),
                  initialValue: bagian['namaBagian'] as String,
                  decoration: InputDecoration(
                    labelText: 'Nama Bagian Aset *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.build),
                  ),
                  onChanged: (value) {
                    bagian['namaBagian'] = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama bagian harus diisi';
                    }
                    return null;
                  },
                ),
              ),
              if (bagianAsetList.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setDialogState(() {
                      List<Map<String, dynamic>> newBagianList = List.from(
                        bagianAsetList,
                      );
                      newBagianList.removeAt(bagianIndex);
                      bagianAsetList.clear();
                      bagianAsetList.addAll(newBagianList);
                    });
                  },
                  tooltip: 'Hapus Bagian',
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Komponen',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          ...komponenList.asMap().entries.map((komponenEntry) {
            int komponenIndex = komponenEntry.key;
            Map<String, dynamic> komponen = komponenEntry.value;

            return _buildKomponenCard(
              bagianIndex,
              komponenIndex,
              komponen,
              komponenList,
              bagian,
              bagianAsetList,
              setDialogState,
            );
          }).toList(),
          SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              setDialogState(() {
                List<Map<String, dynamic>> newKomponenList = List.from(
                  komponenList,
                );
                newKomponenList.add({'namaKomponen': '', 'spesifikasi': ''});
                Map<String, dynamic> newBagian = Map.from(bagian);
                newBagian['komponen'] = newKomponenList;
                List<Map<String, dynamic>> newBagianList = List.from(
                  bagianAsetList,
                );
                newBagianList[bagianIndex] = newBagian;
                bagianAsetList.clear();
                bagianAsetList.addAll(newBagianList);
              });
            },
            icon: Icon(Icons.add, size: 18),
            label: Text('Tambah Komponen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF0A9C5D),
              side: BorderSide(color: Color(0xFF0A9C5D)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildKomponenCard(
    int bagianIndex,
    int komponenIndex,
    Map<String, dynamic> komponen,
    List<Map<String, dynamic>> komponenList,
    Map<String, dynamic> bagian,
    List<Map<String, dynamic>> bagianAsetList,
    StateSetter setDialogState,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('komponen_${bagianIndex}_$komponenIndex'),
                  initialValue: komponen['namaKomponen'] as String,
                  decoration: InputDecoration(
                    labelText: 'Nama Komponen *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.settings, size: 20),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    komponen['namaKomponen'] = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama komponen harus diisi';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey('spesifikasi_${bagianIndex}_$komponenIndex'),
                  initialValue: komponen['spesifikasi'] as String,
                  decoration: InputDecoration(
                    labelText: 'Spesifikasi *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.description, size: 20),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    komponen['spesifikasi'] = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Spesifikasi harus diisi';
                    }
                    return null;
                  },
                ),
              ),
              if (komponenList.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    setDialogState(() {
                      List<Map<String, dynamic>> newKomponenList = List.from(
                        komponenList,
                      );
                      newKomponenList.removeAt(komponenIndex);
                      Map<String, dynamic> newBagian = Map.from(bagian);
                      newBagian['komponen'] = newKomponenList;
                      List<Map<String, dynamic>> newBagianList = List.from(
                        bagianAsetList,
                      );
                      newBagianList[bagianIndex] = newBagian;
                      bagianAsetList.clear();
                      bagianAsetList.addAll(newBagianList);
                    });
                  },
                  tooltip: 'Hapus Komponen',
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildGambarSection(
    BuildContext context,
    XFile? selectedImage,
    ImagePicker imagePicker,
    StateSetter setDialogState,
    Function(XFile?) onImageChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Asset',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedImage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        kIsWeb
                            ? Image.network(
                              selectedImage.path,
                              fit: BoxFit.cover,
                            )
                            : Image.file(
                              File(selectedImage.path),
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final XFile? image = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        setDialogState(() {
                          onImageChanged(image);
                        });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal memilih gambar: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Foto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF0A9C5D),
                    side: BorderSide(color: Color(0xFF0A9C5D)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (selectedImage != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        onImageChanged(null);
                      });
                    },
                    icon: Icon(Icons.delete_outline),
                    label: Text('Hapus Gambar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildFooter(
    BuildContext context,
    BuildContext dialogContext,
    GlobalKey<FormState> formKey,
    TextEditingController namaAsetController,
    TextEditingController kodeMesinController,
    String? selectedJenisAset,
    String? selectedPrioritas,
    XFile? selectedImage,
    List<Map<String, dynamic>> bagianAsetList,
    Function(List<Map<String, dynamic>>) onSave,
    VoidCallback onClose,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              namaAsetController.dispose();
              kodeMesinController.dispose();
              onClose();
            },
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                bool isValid = true;
                String errorMessage = '';

                // Validasi bagian dan komponen
                for (var bagian in bagianAsetList) {
                  String namaBagian = bagian['namaBagian'] as String;
                  if (namaBagian.isEmpty) {
                    isValid = false;
                    errorMessage = 'Semua nama bagian aset harus diisi';
                    break;
                  }

                  List<Map<String, dynamic>> komponenList =
                      bagian['komponen'] as List<Map<String, dynamic>>;
                  for (var komponen in komponenList) {
                    String namaKomponen = komponen['namaKomponen'] as String;
                    String spesifikasi = komponen['spesifikasi'] as String;
                    if (namaKomponen.isEmpty || spesifikasi.isEmpty) {
                      isValid = false;
                      errorMessage =
                          'Semua komponen harus memiliki nama dan spesifikasi';
                      break;
                    }
                  }

                  if (!isValid) break;
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // LOGIKA SIMPAN KE DATABASE
                try {
                  // Tampilkan Loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menyimpan data ke database...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // 1. Upload Gambar (Jika Ada)
                  String? imageUrl;
                  if (selectedImage != null) {
                    try {
                      // Panggil Service Upload
                      final storageService = SupabaseStorageService();
                      // Pass XFile langsung (Support Web & Mobile)
                      imageUrl = await storageService.uploadAssetImage(
                        selectedImage,
                      );
                    } catch (uploadError) {
                      throw Exception(
                        'Gagal upload gambar: $uploadError. Pastikan bucket "asset-images" sudah dibuat & Public.',
                      );
                    }
                  }

                  // 2. Buat Model Asset
                  final assetModel = AssetModelSupabase(
                    namaAssets: namaAsetController.text,
                    kodeAssets: kodeMesinController.text.trim().isEmpty 
                        ? null 
                        : kodeMesinController.text.trim(),
                    jenisAssets: selectedJenisAset,
                    foto: imageUrl, // Simpan URL publik dari Supabase Storage
                    status: 'Aktif', // Default aktif (tidak perlu di form)
                    mtPriority: selectedPrioritas,
                  );

                  // 3. Panggil Repository
                  await AssetSupabaseRepository().insertCompleteAsset(
                    asset: assetModel,
                    bagianList: bagianAsetList,
                  );

                  // 4. Update UI (Optimistic Update untuk list view di parent)
                  List<Map<String, dynamic>> flatData = [];

                  for (var bagian in bagianAsetList) {
                    String namaBagian = bagian['namaBagian'] as String;
                    List<Map<String, dynamic>> komponenList =
                        bagian['komponen'] as List<Map<String, dynamic>>;
                    for (var komponen in komponenList) {
                      flatData.add({
                        "nama_aset": namaAsetController.text,
                        "jenis_aset": selectedJenisAset!,
                        "maintenance_terakhir": "-",
                        "maintenance_selanjutnya": "-",
                        "bagian_aset": namaBagian,
                        "komponen_aset": komponen['namaKomponen'] as String,
                        "produk_yang_digunakan":
                            komponen['spesifikasi'] as String,
                        "gambar_aset":
                            imageUrl ??
                            selectedImage?.path, // Gunakan URL atau path lokal
                      });
                    }
                  }

                  onSave(flatData); // Update tampilan di list

                  // Tutup Dialog
                  Navigator.of(dialogContext).pop();
                  namaAsetController.dispose();
                  kodeMesinController.dispose();
                  onClose();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data aset berhasil ditambahkan ke Database!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0A9C5D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Simpan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DataMesinPage extends StatefulWidget {
  @override
  _DataMesinPageState createState() => _DataMesinPageState();
}

class _DataMesinPageState extends State<DataMesinPage> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // Sinkronkan scroll body ke header
    _horizontalScrollController.addListener(() {
      if (!_isSyncing && _headerScrollController.hasClients) {
        _isSyncing = true;
        _headerScrollController.jumpTo(_horizontalScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
    // Sinkronkan scroll header ke body
    _headerScrollController.addListener(() {
      if (!_isSyncing && _horizontalScrollController.hasClients) {
        _isSyncing = true;
        _horizontalScrollController.jumpTo(_headerScrollController.offset);
        Future.microtask(() => _isSyncing = false);
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  // Data mentah dengan detail per komponen (setiap komponen = 1 row)
  List<Map<String, dynamic>> _rawData = [
    // Creeper 1 - Roll Atas (3 komponen)
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Bearing",
      "produk_yang_digunakan": "SKF 6205",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 25x40x7",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Atas",
      "komponen_aset": "Shaft",
      "produk_yang_digunakan": "Shaft Steel 40mm",
      "gambar_aset": null,
    },
    // Creeper 1 - Roll Bawah (4 komponen)
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Bearing",
      "produk_yang_digunakan": "SKF 6206",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 30x45x7",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Shaft",
      "produk_yang_digunakan": "Shaft Steel 45mm",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Creeper 1",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "15 Januari 2024",
      "maintenance_selanjutnya": "18 Januari 2024",
      "bagian_aset": "Roll Bawah",
      "komponen_aset": "Pulley",
      "produk_yang_digunakan": "Pulley V-Belt 8PK",
      "gambar_aset": null,
    },
    // Excavator
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Hydraulic Pump",
      "produk_yang_digunakan": "Hydraulic Oil AW46",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Cylinder",
      "produk_yang_digunakan": "Seal Kit Cylinder",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Excavator",
      "jenis_aset": "Alat Berat",
      "maintenance_terakhir": "10 Januari 2024",
      "maintenance_selanjutnya": "10 Februari 2024",
      "bagian_aset": "Hydraulic System",
      "komponen_aset": "Hose",
      "produk_yang_digunakan": "Hydraulic Hose 1/2 inch",
      "gambar_aset": null,
    },
    // Generator Set
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Alternator",
      "produk_yang_digunakan": "Alternator 12V 100A",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Battery",
      "produk_yang_digunakan": "Battery Dry 12V 100Ah",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Generator Set",
      "jenis_aset": "Listrik",
      "maintenance_terakhir": "5 Januari 2024",
      "maintenance_selanjutnya": "5 Februari 2024",
      "bagian_aset": "Engine",
      "komponen_aset": "Fuel System",
      "produk_yang_digunakan": "Fuel Filter Element",
      "gambar_aset": null,
    },
    // Mixing Machine
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Gear",
      "produk_yang_digunakan": "Gear Oil EP90",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Oli",
      "produk_yang_digunakan": "Gear Oil EP90 5L",
      "gambar_aset": null,
    },
    {
      "nama_aset": "Mixing Machine",
      "jenis_aset": "Mesin Produksi",
      "maintenance_terakhir": "20 Januari 2024",
      "maintenance_selanjutnya": "20 Februari 2024",
      "bagian_aset": "Gearbox",
      "komponen_aset": "Seal",
      "produk_yang_digunakan": "Oil Seal 50x70x8",
      "gambar_aset": null,
    },
  ];

  // Mengelompokkan data berdasarkan nama_aset
  Map<String, List<Map<String, dynamic>>> _groupByAset() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _rawData) {
      String nama = item["nama_aset"];
      if (!grouped.containsKey(nama)) {
        grouped[nama] = [];
      }
      grouped[nama]!.add(item);
    }
    return grouped;
  }

  // Mengelompokkan data berdasarkan bagian dalam satu aset
  Map<String, List<Map<String, dynamic>>> _groupByBagian(
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

  // Method untuk menampilkan form tambah data asset
  void _showAddAssetForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _namaAsetController = TextEditingController();
    final ImagePicker _imagePicker = ImagePicker();

    String? _selectedJenisAset;
    XFile? _selectedImage;

    // List bagian aset - setiap bagian memiliki nama dan list komponen
    // Setiap komponen memiliki nama dan spesifikasi
    List<Map<String, dynamic>> bagianAsetList = [
      {
        'namaBagian': '',
        'komponen': [
          {'namaKomponen': '', 'spesifikasi': ''},
        ],
      },
    ];

    // Simpan reference ke setState widget state
    final updateWidgetState = setState;

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
                    // Header
                    Container(
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
                              _namaAsetController.dispose();
                              _selectedImage = null;
                            },
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Aset
                              TextFormField(
                                controller: _namaAsetController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Aset *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama aset harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Jenis Aset (Dropdown)
                              DropdownButtonFormField<String>(
                                value: _selectedJenisAset,
                                decoration: InputDecoration(
                                  labelText: 'Jenis Aset *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    _selectedJenisAset = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jenis aset harus dipilih';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),

                              // Divider
                              Divider(thickness: 2, color: Colors.grey[300]),
                              SizedBox(height: 16),

                              // Bagian Aset (Dinamis)
                              Text(
                                'Bagian Aset & Komponen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF022415),
                                ),
                              ),
                              SizedBox(height: 16),

                              // List Bagian Aset
                              ...bagianAsetList.asMap().entries.map((entry) {
                                int bagianIndex = entry.key;
                                Map<String, dynamic> bagian = entry.value;
                                List<Map<String, dynamic>> komponenList =
                                    bagian['komponen']
                                        as List<Map<String, dynamic>>;

                                return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Bagian Aset
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              key: ValueKey(
                                                'bagian_$bagianIndex',
                                              ),
                                              initialValue:
                                                  bagian['namaBagian']
                                                      as String,
                                              decoration: InputDecoration(
                                                labelText: 'Nama Bagian Aset *',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                prefixIcon: Icon(Icons.build),
                                              ),
                                              onChanged: (value) {
                                                bagian['namaBagian'] = value;
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Nama bagian harus diisi';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          if (bagianAsetList.length > 1)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setDialogState(() {
                                                  // Buat list baru untuk memastikan state terdeteksi
                                                  List<Map<String, dynamic>>
                                                  newBagianList = List.from(
                                                    bagianAsetList,
                                                  );
                                                  newBagianList.removeAt(
                                                    bagianIndex,
                                                  );
                                                  bagianAsetList.clear();
                                                  bagianAsetList.addAll(
                                                    newBagianList,
                                                  );
                                                });
                                              },
                                              tooltip: 'Hapus Bagian',
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 16),

                                      // List Komponen dalam Bagian
                                      Text(
                                        'Komponen',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      ...komponenList.asMap().entries.map((
                                        komponenEntry,
                                      ) {
                                        int komponenIndex = komponenEntry.key;
                                        Map<String, dynamic> komponen =
                                            komponenEntry.value;

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      key: ValueKey(
                                                        'komponen_${bagianIndex}_$komponenIndex',
                                                      ),
                                                      initialValue:
                                                          komponen['namaKomponen']
                                                              as String,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            'Nama Komponen *',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.settings,
                                                          size: 20,
                                                        ),
                                                        isDense: true,
                                                      ),
                                                      onChanged: (value) {
                                                        komponen['namaKomponen'] =
                                                            value;
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Nama komponen harus diisi';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: TextFormField(
                                                      key: ValueKey(
                                                        'spesifikasi_${bagianIndex}_$komponenIndex',
                                                      ),
                                                      initialValue:
                                                          komponen['spesifikasi']
                                                              as String,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            'Spesifikasi *',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.description,
                                                          size: 20,
                                                        ),
                                                        isDense: true,
                                                      ),
                                                      onChanged: (value) {
                                                        komponen['spesifikasi'] =
                                                            value;
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Spesifikasi harus diisi';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  if (komponenList.length > 1)
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setDialogState(() {
                                                          // Buat list baru untuk komponen
                                                          List<
                                                            Map<String, dynamic>
                                                          >
                                                          newKomponenList =
                                                              List.from(
                                                                komponenList,
                                                              );
                                                          newKomponenList
                                                              .removeAt(
                                                                komponenIndex,
                                                              );
                                                          // Buat map baru untuk bagian
                                                          Map<String, dynamic>
                                                          newBagian = Map.from(
                                                            bagian,
                                                          );
                                                          newBagian['komponen'] =
                                                              newKomponenList;
                                                          // Buat list baru untuk bagianAsetList
                                                          List<
                                                            Map<String, dynamic>
                                                          >
                                                          newBagianList =
                                                              List.from(
                                                                bagianAsetList,
                                                              );
                                                          newBagianList[bagianIndex] =
                                                              newBagian;
                                                          bagianAsetList
                                                              .clear();
                                                          bagianAsetList.addAll(
                                                            newBagianList,
                                                          );
                                                        });
                                                      },
                                                      tooltip: 'Hapus Komponen',
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),

                                      // Button Tambah Komponen
                                      SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setDialogState(() {
                                            // Buat list baru untuk komponen
                                            List<Map<String, dynamic>>
                                            newKomponenList = List.from(
                                              komponenList,
                                            );
                                            newKomponenList.add({
                                              'namaKomponen': '',
                                              'spesifikasi': '',
                                            });
                                            // Buat map baru untuk bagian
                                            Map<String, dynamic> newBagian =
                                                Map.from(bagian);
                                            newBagian['komponen'] =
                                                newKomponenList;
                                            // Buat list baru untuk bagianAsetList
                                            List<Map<String, dynamic>>
                                            newBagianList = List.from(
                                              bagianAsetList,
                                            );
                                            newBagianList[bagianIndex] =
                                                newBagian;
                                            bagianAsetList.clear();
                                            bagianAsetList.addAll(
                                              newBagianList,
                                            );
                                          });
                                        },
                                        icon: Icon(Icons.add, size: 18),
                                        label: Text('Tambah Komponen'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Color(0xFF0A9C5D),
                                          side: BorderSide(
                                            color: Color(0xFF0A9C5D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              // Button Tambah Bagian Aset
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setDialogState(() {
                                    // Buat list baru untuk memastikan state terdeteksi
                                    List<Map<String, dynamic>> newBagianList =
                                        List.from(bagianAsetList);
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),

                              // Divider
                              Divider(thickness: 2, color: Colors.grey[300]),
                              SizedBox(height: 16),

                              // Upload Gambar Asset
                              Text(
                                'Gambar Asset',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF022415),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Preview dan Upload Button
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Preview Image
                                    if (_selectedImage != null)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        width: double.infinity,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(_selectedImage!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    // Upload Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          try {
                                            final XFile? image =
                                                await _imagePicker.pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 85,
                                            );
                                            if (image != null) {
                                              setDialogState(() {
                                                _selectedImage = image;
                                              });
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
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
                                          side: BorderSide(
                                            color: Color(0xFF0A9C5D),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_selectedImage != null)
                                      Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: TextButton.icon(
                                          onPressed: () {
                                            setDialogState(() {
                                              _selectedImage = null;
                                            });
                                          },
                                          icon: Icon(Icons.delete_outline),
                                          label: Text('Hapus Gambar'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
                    // Actions
                    Container(
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
                              _namaAsetController.dispose();
                              _selectedImage = null;
                            },
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Validasi bagian aset dan komponen
                                bool isValid = true;
                                String errorMessage = '';

                                for (var bagian in bagianAsetList) {
                                  String namaBagian =
                                      bagian['namaBagian'] as String;
                                  if (namaBagian.isEmpty) {
                                    isValid = false;
                                    errorMessage =
                                        'Semua nama bagian aset harus diisi';
                                    break;
                                  }

                                  List<Map<String, dynamic>> komponenList =
                                      bagian['komponen']
                                          as List<Map<String, dynamic>>;
                                  for (var komponen in komponenList) {
                                    String namaKomponen =
                                        komponen['namaKomponen'] as String;
                                    String spesifikasi =
                                        komponen['spesifikasi'] as String;
                                    if (namaKomponen.isEmpty ||
                                        spesifikasi.isEmpty) {
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

                                // Tambahkan data ke _rawData - setiap komponen menjadi satu row
                                updateWidgetState(() {
                                  // Simpan path gambar jika ada
                                  String? gambarPath = _selectedImage?.path;
                                  
                                  for (var bagian in bagianAsetList) {
                                    String namaBagian =
                                        bagian['namaBagian'] as String;
                                    List<Map<String, dynamic>> komponenList =
                                        bagian['komponen']
                                            as List<Map<String, dynamic>>;
                                    for (var komponen in komponenList) {
                                      _rawData.add({
                                        "nama_aset": _namaAsetController.text,
                                        "jenis_aset": _selectedJenisAset!,
                                        "maintenance_terakhir": null,
                                        "maintenance_selanjutnya": null,
                                        "bagian_aset": namaBagian,
                                        "komponen_aset":
                                            komponen['namaKomponen'] as String,
                                        "produk_yang_digunakan":
                                            komponen['spesifikasi'] as String,
                                        "gambar_aset": gambarPath,
                                      });
                                    }
                                  }
                                });

                                Navigator.of(dialogContext).pop();
                                _namaAsetController.dispose();
                                _selectedImage = null;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Data aset berhasil ditambahkan',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0A9C5D),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
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

  // Helper method untuk mendapatkan nama bulan
  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Data Aset",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF022415),
          ),
        ),
        SizedBox(height: 20),

        // Button Tambah
        ElevatedButton.icon(
          onPressed: () {
            _showAddAssetForm(context);
          },
          icon: Icon(Icons.add),
          label: Text("Tambah"),
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            backgroundColor: Color(0xFF0A9C5D),
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 5),

        // ================= TABLE ==================
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: _buildTableWithStickyHeader(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTableWithStickyHeader(BuildContext context) {
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold);
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0; // Nama Aset
    const double col2 = 150.0; // Jenis Aset
    const double col3 = 200.0; // Maintenance Terakhir
    const double col4 = 200.0; // Maintenance Selanjutnya
    const double col5 = 150.0; // Bagian Aset
    const double col6 = 150.0; // Komponen Aset
    const double col7 = 200.0; // Spesifikasi
    const double col8 = 120.0; // Gambar Aset
    const double col9 = 200.0; // Kolom AKSI

    // Build header row content (tanpa scroll view)
    Widget headerRowContent = Row(
      children: [
        _cellCenter("NO", colNo, rowHeight, headerStyle, isHeader: true),
        _cellCenter("NAMA ASET", col1, rowHeight, headerStyle, isHeader: true),
        _cellCenter("JENIS ASET", col2, rowHeight, headerStyle, isHeader: true),
        _cellCenter(
          "MAINTENANCE TERAKHIR",
          col3,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "MAINTENANCE SELANJUTNYA",
          col4,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "BAGIAN ASET",
          col5,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "KOMPONEN ASET",
          col6,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "SPESIFIKASI",
          col7,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter(
          "GAMBAR ASET",
          col8,
          rowHeight,
          headerStyle,
          isHeader: true,
        ),
        _cellCenter("AKSI", col9, rowHeight, headerStyle, isHeader: true),
      ],
    );

    // Build body
    Widget tableBody = _buildTableBody(context);

    return Stack(
      children: [
        // Scrollable Body dengan horizontal scroll
        Column(
          children: [
            // Spacer untuk header
            SizedBox(height: rowHeight),
            // Scrollable Body
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: tableBody,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Sticky Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              color: Colors.white,
            ),
            child: Scrollbar(
              controller: _headerScrollController,
              thumbVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                physics: AlwaysScrollableScrollPhysics(),
                child: headerRowContent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableBody(BuildContext context) {
    const double rowHeight = 65.0;

    // Lebar kolom
    const double colNo = 60.0;
    const double col1 = 180.0; // Nama Aset
    const double col2 = 150.0; // Jenis Aset
    const double col3 = 200.0; // Maintenance Terakhir
    const double col4 = 200.0; // Maintenance Selanjutnya
    const double col5 = 150.0; // Bagian Aset
    const double col6 = 150.0; // Komponen Aset
    const double col7 = 200.0; // Spesifikasi
    const double col8 = 120.0; // Gambar Aset
    const double col9 = 200.0; // Kolom AKSI

    Map<String, List<Map<String, dynamic>>> grouped = _groupByAset();
    List<Widget> dataRows = [];

    // Data Rows dengan MERGED CELLS
    int globalNo = 1;
    grouped.forEach((namaAset, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;

      // Ambil data dari item pertama untuk kolom yang di-merge
      var firstItem = items[0];

      // Kelompokkan berdasarkan bagian
      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(
        items,
      );
      List<Widget> bagianRows = [];

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;

        if (bagianRowCount > 1) {
          // Jika bagian memiliki lebih dari 1 komponen, merge bagian
          bagianRows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian - merged untuk semua komponen dalam bagian ini
                _cellCenter(bagian, col5, bagianMergedHeight, null),

                // Data untuk setiap komponen dalam bagian (tanpa gambar dan aksi)
                Column(
                  children:
                      bagianItems.map((item) {
                        return Row(
                          children: [
                            _cellCenter(
                              item["komponen_aset"]!,
                              col6,
                              rowHeight,
                              null,
                            ),
                            _cellCenter(
                              item["produk_yang_digunakan"]!,
                              col7,
                              rowHeight,
                              null,
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        } else {
          // Jika bagian hanya 1 komponen, tidak perlu merge
          var item = bagianItems[0];
          bagianRows.add(
            Row(
              children: [
                _cellCenter(bagian, col5, rowHeight, null),
                _cellCenter(item["komponen_aset"]!, col6, rowHeight, null),
                _cellCenter(
                  item["produk_yang_digunakan"]!,
                  col7,
                  rowHeight,
                  null,
                ),
              ],
            ),
          );
        }
      });

      dataRows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom NO - merged untuk semua baris
            _cellCenter(globalNo.toString(), colNo, mergedHeight, null),

            // Kolom NAMA ASET - merged untuk semua baris
            _cellCenter(namaAset, col1, mergedHeight, null),

            // Kolom JENIS ASET - merged untuk semua baris
            _cellCenter(firstItem["jenis_aset"]!, col2, mergedHeight, null),

            // Kolom MAINTENANCE TERAKHIR - merged untuk semua baris
            _cellCenter(
              firstItem["maintenance_terakhir"]!,
              col3,
              mergedHeight,
              null,
            ),

            // Kolom MAINTENANCE SELANJUTNYA - merged untuk semua baris
            _cellCenter(
              firstItem["maintenance_selanjutnya"]!,
              col4,
              mergedHeight,
              null,
            ),

            // Kolom BAGIAN ASET, KOMPONEN ASET, PRODUK
            Column(children: bagianRows),

            // Kolom GAMBAR ASET - merged untuk semua baris dalam satu aset
            _imageCell(firstItem["gambar_aset"], col8, mergedHeight),

            // Kolom AKSI - merged untuk semua baris dalam satu aset
            _actionCell(context, firstItem, col9, mergedHeight),
          ],
        ),
      );
      globalNo++;
    });

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 1),
          right: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Column(children: dataRows),
    );
  }

  Widget _cellCenter(
    String text,
    double width,
    double height,
    TextStyle? style, {
    bool isHeader = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFE0E0E0) : Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _imageCell(String? imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: imagePath != null
          ? (imagePath.startsWith('assets/')
              ? Image.asset(
                  imagePath,
                  width: width - 8,
                  height: height - 8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 24);
                  },
                )
              : Image.file(
                  File(imagePath),
                  width: width - 8,
                  height: height - 8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported, size: 24);
                  },
                ))
          : Icon(Icons.image, size: 24, color: Colors.grey),
    );
  }

  Widget _actionCell(
    BuildContext context,
    Map<String, dynamic> item,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Edit
          _iconButton(
            icon: Icons.edit,
            color: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Edit: ${item["nama_aset"]}")),
              );
            },
          ),
          const SizedBox(width: 4),
          // Tombol Hapus
          _iconButton(
            icon: Icons.delete,
            color: Colors.red,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Hapus: ${item["nama_aset"]}")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

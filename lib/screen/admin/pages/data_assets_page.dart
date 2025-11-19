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
  final TextEditingController _searchController = TextEditingController();
  bool _isSyncing = false;
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;
  String? _filterJenisAset;
  String? _hoveredRowKey;

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
    // Listener untuk search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    _searchController.dispose();
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

  // Method untuk filter dan sort data
  List<Map<String, dynamic>> _getFilteredAndSortedData() {
    List<Map<String, dynamic>> filtered = _rawData;

    // Filter berdasarkan jenis aset
    if (_filterJenisAset != null && _filterJenisAset!.isNotEmpty) {
      filtered = filtered.where((item) {
        return item["jenis_aset"]?.toString() == _filterJenisAset;
      }).toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item["nama_aset"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["jenis_aset"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["bagian_aset"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["komponen_aset"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["produk_yang_digunakan"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["maintenance_terakhir"]?.toString().toLowerCase().contains(_searchQuery) == true ||
            item["maintenance_selanjutnya"]?.toString().toLowerCase().contains(_searchQuery) == true;
      }).toList();
    }

    // Sort data
    if (_sortColumn != null) {
      filtered.sort((a, b) {
        var aValue = a[_sortColumn]?.toString() ?? '';
        var bValue = b[_sortColumn]?.toString() ?? '';
        
        int comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  // Method untuk mendapatkan list jenis aset unik
  List<String> _getJenisAsetList() {
    Set<String> jenisSet = {};
    for (var item in _rawData) {
      if (item["jenis_aset"] != null) {
        jenisSet.add(item["jenis_aset"].toString());
      }
    }
    return jenisSet.toList()..sort();
  }

  // Mengelompokkan data berdasarkan nama_aset
  Map<String, List<Map<String, dynamic>>> _groupByAset() {
    List<Map<String, dynamic>> data = _getFilteredAndSortedData();
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in data) {
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

        // Search Bar, Filter, dan Button Tambah
        Column(
          children: [
            Row(
              children: [
                // Search Bar
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
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari data aset...',
                        prefixIcon: Icon(Icons.search, color: Color(0xFF0A9C5D)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF0A9C5D), width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Filter Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: _filterJenisAset,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list, color: Color(0xFF0A9C5D), size: 20),
                          SizedBox(width: 8),
                          Text('Filter Jenis'),
                        ],
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Semua Jenis'),
                      ),
                      ..._getJenisAsetList().map((jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(jenis),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterJenisAset = value;
                      });
                    },
                    underline: SizedBox(),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0A9C5D)),
                  ),
                ),
                SizedBox(width: 12),
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
                    elevation: 2,
                  ),
                ),
              ],
            ),
            // Filter tag jika ada filter aktif
            if (_filterJenisAset != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('Filter: $_filterJenisAset'),
                    onDeleted: () {
                      setState(() {
                        _filterJenisAset = null;
                      });
                    },
                    deleteIcon: Icon(Icons.close, size: 18),
                    backgroundColor: Color(0xFF0A9C5D).withOpacity(0.1),
                    labelStyle: TextStyle(color: Color(0xFF0A9C5D)),
                  ),
                ],
              ),
            ],
          ],
        ),
        SizedBox(height: 20),

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

  // Method untuk handle sort
  void _handleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  Widget _buildTableWithStickyHeader(BuildContext context) {
    final headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Colors.white,
    );
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
        _sortableHeaderCell("NO", colNo, rowHeight, headerStyle, null),
        _sortableHeaderCell("NAMA ASET", col1, rowHeight, headerStyle, "nama_aset"),
        _sortableHeaderCell("JENIS ASET", col2, rowHeight, headerStyle, "jenis_aset"),
        _sortableHeaderCell(
          "MAINTENANCE TERAKHIR",
          col3,
          rowHeight,
          headerStyle,
          "maintenance_terakhir",
        ),
        _sortableHeaderCell(
          "MAINTENANCE SELANJUTNYA",
          col4,
          rowHeight,
          headerStyle,
          "maintenance_selanjutnya",
        ),
        _sortableHeaderCell(
          "BAGIAN ASET",
          col5,
          rowHeight,
          headerStyle,
          null,
        ),
        _sortableHeaderCell(
          "KOMPONEN ASET",
          col6,
          rowHeight,
          headerStyle,
          null,
        ),
        _sortableHeaderCell(
          "SPESIFIKASI",
          col7,
          rowHeight,
          headerStyle,
          null,
        ),
        _sortableHeaderCell(
          "GAMBAR ASET",
          col8,
          rowHeight,
          headerStyle,
          null,
        ),
        _sortableHeaderCell("AKSI", col9, rowHeight, headerStyle, null),
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
              gradient: LinearGradient(
                colors: [Color(0xFF0A9C5D), Color(0xFF088A52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
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
    
    // Hitung total lebar kolom
    const double totalWidth = colNo + col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8 + col9;
    
    // Empty state
    if (grouped.isEmpty) {
      return Container(
        width: totalWidth,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Tidak ada data ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty || _filterJenisAset != null
                      ? 'Coba ubah kata kunci pencarian atau filter'
                      : 'Mulai dengan menambahkan data aset baru',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.isNotEmpty || _filterJenisAset != null) ...[
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _filterJenisAset = null;
                      });
                    },
                    icon: Icon(Icons.clear_all),
                    label: Text('Hapus Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0A9C5D),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> dataRows = [];

    // Data Rows dengan MERGED CELLS
    int globalNo = 1;
    int rowIndex = 0;
    grouped.forEach((namaAset, items) {
      int totalRows = items.length;
      double mergedHeight = rowHeight * totalRows;
      bool isEvenRow = rowIndex % 2 == 0;

      // Ambil data dari item pertama untuk kolom yang di-merge
      var firstItem = items[0];

      // Setup hover state
      String rowKey = namaAset;
      bool isHovered = _hoveredRowKey == rowKey;

      // Kelompokkan berdasarkan bagian
      Map<String, List<Map<String, dynamic>>> groupedByBagian = _groupByBagian(
        items,
      );
      List<Widget> bagianRows = [];
      int bagianRowIndex = 0;

      groupedByBagian.forEach((bagian, bagianItems) {
        int bagianRowCount = bagianItems.length;
        double bagianMergedHeight = rowHeight * bagianRowCount;
        bool isBagianEvenRow = (rowIndex + bagianRowIndex) % 2 == 0;

        if (bagianRowCount > 1) {
          // Jika bagian memiliki lebih dari 1 komponen, merge bagian
          bagianRows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian - merged untuk semua komponen dalam bagian ini
                _cellCenter(bagian, col5, bagianMergedHeight, null,
                    isEvenRow: isBagianEvenRow, isHovered: isHovered),

                // Data untuk setiap komponen dalam bagian (tanpa gambar dan aksi)
                Column(
                  children:
                      bagianItems.asMap().entries.map((entry) {
                        int itemIndex = entry.key;
                        var item = entry.value;
                        bool isItemEvenRow = (rowIndex + bagianRowIndex + itemIndex) % 2 == 0;
                        return Row(
                          children: [
                            _cellCenter(
                              item["komponen_aset"]!,
                              col6,
                              rowHeight,
                              null,
                              isEvenRow: isItemEvenRow,
                              isHovered: isHovered,
                            ),
                            _cellCenter(
                              item["produk_yang_digunakan"]!,
                              col7,
                              rowHeight,
                              null,
                              isEvenRow: isItemEvenRow,
                              isHovered: isHovered,
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
                _cellCenter(bagian, col5, rowHeight, null,
                    isEvenRow: isBagianEvenRow, isHovered: isHovered),
                _cellCenter(item["komponen_aset"]!, col6, rowHeight, null,
                    isEvenRow: isBagianEvenRow, isHovered: isHovered),
                _cellCenter(
                  item["produk_yang_digunakan"]!,
                  col7,
                  rowHeight,
                  null,
                  isEvenRow: isBagianEvenRow,
                  isHovered: isHovered,
                ),
              ],
            ),
          );
        }
        bagianRowIndex += bagianRowCount;
      });

      dataRows.add(
        MouseRegion(
          onEnter: (_) {
            setState(() {
              _hoveredRowKey = rowKey;
            });
          },
          onExit: (_) {
            setState(() {
              _hoveredRowKey = null;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom NO - merged untuk semua baris
              _cellCenter(globalNo.toString(), colNo, mergedHeight, null,
                  isEvenRow: isEvenRow, isHovered: isHovered),

              // Kolom NAMA ASET - merged untuk semua baris
              _cellCenter(namaAset, col1, mergedHeight, null,
                  isEvenRow: isEvenRow, isHovered: isHovered),

              // Kolom JENIS ASET - merged untuk semua baris
              _cellCenter(firstItem["jenis_aset"]!, col2, mergedHeight, null,
                  isEvenRow: isEvenRow, isHovered: isHovered),

              // Kolom MAINTENANCE TERAKHIR - merged untuk semua baris
              _cellCenter(
                firstItem["maintenance_terakhir"]!,
                col3,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),

              // Kolom MAINTENANCE SELANJUTNYA - merged untuk semua baris
              _cellCenter(
                firstItem["maintenance_selanjutnya"]!,
                col4,
                mergedHeight,
                null,
                isEvenRow: isEvenRow,
                isHovered: isHovered,
              ),

              // Kolom BAGIAN ASET, KOMPONEN ASET, PRODUK
              Column(children: bagianRows),

              // Kolom GAMBAR ASET - merged untuk semua baris dalam satu aset
              _imageCell(firstItem["gambar_aset"], col8, mergedHeight,
                  isEvenRow: isEvenRow, isHovered: isHovered, context: context),

              // Kolom AKSI - merged untuk semua baris dalam satu aset
              _actionCell(context, firstItem, col9, mergedHeight,
                  isEvenRow: isEvenRow, isHovered: isHovered),
            ],
          ),
        ),
      );
      globalNo++;
      rowIndex++;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(children: dataRows),
    );
  }

  Widget _sortableHeaderCell(
    String text,
    double width,
    double height,
    TextStyle style,
    String? sortColumn,
  ) {
    bool isSortable = sortColumn != null;
    bool isActive = _sortColumn == sortColumn;
    
    void handleTap() {
      if (sortColumn != null) {
        _handleSort(sortColumn);
      }
    }
    
    return MouseRegion(
      cursor: isSortable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isSortable ? handleTap : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: style,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSortable) ...[
                SizedBox(width: 4),
                Icon(
                  isActive
                      ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellCenter(
    String text,
    double width,
    double height,
    TextStyle? style, {
    bool isHeader = false,
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHeader) {
      backgroundColor = const Color(0xFFE0E0E0);
    } else if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = isEvenRow ? Colors.white : Colors.grey[50]!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        text,
        style: style ?? TextStyle(
          fontSize: 12,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.center,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _imageCell(String? imagePath, double width, double height, {
    bool isEvenRow = true,
    bool isHovered = false,
    BuildContext? context,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = isEvenRow ? Colors.grey[50]! : Colors.grey[100]!;
    }

    return GestureDetector(
      onTap: imagePath != null && context != null ? () => _showImagePreview(context, imagePath) : null,
      child: MouseRegion(
        cursor: imagePath != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              right: BorderSide(color: Colors.grey[300]!, width: 0.5),
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
            ),
          ),
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: imagePath != null
          ? (imagePath.startsWith('assets/')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    imagePath,
                    width: width - 12,
                    height: height - 12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey[600]),
                      );
                    },
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(imagePath),
                    width: width - 12,
                    height: height - 12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey[600]),
                      );
                    },
                  ),
                ))
          : Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.image, size: 24, color: Colors.grey[600]),
            ),
        ),
      ),
    );
  }

  Widget _actionCell(
    BuildContext context,
    Map<String, dynamic> item,
    double width,
    double height, {
    bool isEvenRow = true,
    bool isHovered = false,
  }) {
    Color backgroundColor;
    if (isHovered) {
      backgroundColor = Color(0xFF0A9C5D).withOpacity(0.1);
    } else {
      backgroundColor = isEvenRow ? Colors.white : Colors.grey[50]!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 0.5),
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Edit
          _iconButton(
            icon: Icons.edit,
            color: Color(0xFF2196F3),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Edit: ${item["nama_aset"]}"),
                  backgroundColor: Color(0xFF0A9C5D),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Tombol Hapus
          _iconButton(
            icon: Icons.delete,
            color: Color(0xFFF44336),
            onPressed: () {
              _showDeleteConfirmation(context, item);
            },
          ),
        ],
      ),
    );
  }

  // Method untuk menampilkan image preview
  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagePath.startsWith('assets/')
                      ? Image.asset(imagePath, fit: BoxFit.contain)
                      : Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method untuk menampilkan confirmation dialog sebelum hapus
  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus data aset ini?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Aset: ${item["nama_aset"]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item["jenis_aset"] != null)
                      Text('Jenis: ${item["jenis_aset"]}'),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implementasi hapus data
                setState(() {
                  _rawData.removeWhere((data) =>
                      data["nama_aset"] == item["nama_aset"] &&
                      data["bagian_aset"] == item["bagian_aset"] &&
                      data["komponen_aset"] == item["komponen_aset"]);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data aset berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: color.withOpacity(0.5),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

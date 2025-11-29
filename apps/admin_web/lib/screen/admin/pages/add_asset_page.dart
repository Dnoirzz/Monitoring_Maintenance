import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/asset.dart';
import 'package:shared/repositories/asset_repository.dart';

/// Add Asset Page
/// Form untuk admin menambahkan asset baru ke database
class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final _assetRepository = AssetRepository();
  final _imagePicker = ImagePicker();

  // Controllers untuk form asset
  final _kodeAsetController = TextEditingController();
  final _namaAsetController = TextEditingController();
  final _lokasiIdController = TextEditingController();

  String? _selectedJenisAset;
  String? _selectedStatus;
  DateTime? _maintenanceTerakhir;
  DateTime? _maintenanceSelanjutnya;
  XFile? _selectedImage;
  bool _isLoading = false;

  // List bagian aset - setiap bagian memiliki nama dan list komponen
  List<Map<String, dynamic>> _bagianAsetList = [
    {
      'namaBagian': TextEditingController(),
      'keterangan': TextEditingController(),
      'komponen': [
        {
          'namaKomponen': TextEditingController(),
          'spesifikasi': TextEditingController(),
        },
      ],
    },
  ];

  final List<String> _jenisAsetOptions = [
    'Mesin Produksi',
    'Alat Berat',
    'Listrik',
    'Kendaraan',
    'Peralatan',
    'Lainnya',
  ];

  final List<String> _statusOptions = [
    'Active',
    'Breakdown',
    'Perlu Maintenance',
    'Maintenance',
    'Non-Active',
  ];

  @override
  void dispose() {
    _kodeAsetController.dispose();
    _namaAsetController.dispose();
    _lokasiIdController.dispose();

    // Dispose all bagian and komponen controllers
    for (var bagian in _bagianAsetList) {
      (bagian['namaBagian'] as TextEditingController).dispose();
      (bagian['keterangan'] as TextEditingController).dispose();
      for (var komponen in bagian['komponen']) {
        (komponen['namaKomponen'] as TextEditingController).dispose();
        (komponen['spesifikasi'] as TextEditingController).dispose();
      }
    }

    super.dispose();
  }

  void _addBagianAset() {
    setState(() {
      _bagianAsetList.add({
        'namaBagian': TextEditingController(),
        'keterangan': TextEditingController(),
        'komponen': [
          {
            'namaKomponen': TextEditingController(),
            'spesifikasi': TextEditingController(),
          },
        ],
      });
    });
  }

  void _removeBagianAset(int index) {
    if (_bagianAsetList.length > 1) {
      setState(() {
        // Dispose controllers before removing
        var bagian = _bagianAsetList[index];
        (bagian['namaBagian'] as TextEditingController).dispose();
        (bagian['keterangan'] as TextEditingController).dispose();
        for (var komponen in bagian['komponen']) {
          (komponen['namaKomponen'] as TextEditingController).dispose();
          (komponen['spesifikasi'] as TextEditingController).dispose();
        }
        _bagianAsetList.removeAt(index);
      });
    }
  }

  void _addKomponenToBagian(int bagianIndex) {
    setState(() {
      _bagianAsetList[bagianIndex]['komponen'].add({
        'namaKomponen': TextEditingController(),
        'spesifikasi': TextEditingController(),
      });
    });
  }

  void _removeKomponenFromBagian(int bagianIndex, int komponenIndex) {
    if ((_bagianAsetList[bagianIndex]['komponen'] as List).length > 1) {
      setState(() {
        var komponen = _bagianAsetList[bagianIndex]['komponen'][komponenIndex];
        (komponen['namaKomponen'] as TextEditingController).dispose();
        (komponen['spesifikasi'] as TextEditingController).dispose();
        _bagianAsetList[bagianIndex]['komponen'].removeAt(komponenIndex);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isMaintenanceTerakhir,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0A9C5D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMaintenanceTerakhir) {
          _maintenanceTerakhir = picked;
        } else {
          _maintenanceSelanjutnya = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate at least one bagian has a name
    bool hasValidBagian = false;
    for (var bagian in _bagianAsetList) {
      final namaBagianController =
          bagian['namaBagian'] as TextEditingController;
      if (namaBagianController.text.trim().isNotEmpty) {
        hasValidBagian = true;
        break;
      }
    }

    if (!hasValidBagian) {
      _showErrorDialog('Minimal satu bagian aset harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create Asset object
      final asset = Asset(
        kodeAset:
            _kodeAsetController.text.trim().isEmpty
                ? null
                : _kodeAsetController.text.trim(),
        namaAset: _namaAsetController.text.trim(),
        jenisAset: _selectedJenisAset,
        lokasiId:
            _lokasiIdController.text.trim().isEmpty
                ? null
                : _lokasiIdController.text.trim(),
        status: _selectedStatus,
        maintenanceTerakhir: _maintenanceTerakhir,
        maintenanceSelanjutnya: _maintenanceSelanjutnya,
        gambarAset: _selectedImage?.path, // TODO: Upload to Supabase storage
      );

      // Prepare bagian list
      List<Map<String, dynamic>> bagianList = [];
      for (var bagian in _bagianAsetList) {
        final namaBagianController =
            bagian['namaBagian'] as TextEditingController;
        final keteranganController =
            bagian['keterangan'] as TextEditingController;

        if (namaBagianController.text.trim().isEmpty) {
          continue; // Skip empty bagian
        }

        List<Map<String, dynamic>> komponenList = [];
        for (var komponen in bagian['komponen']) {
          final namaKomponenController =
              komponen['namaKomponen'] as TextEditingController;
          final spesifikasiController =
              komponen['spesifikasi'] as TextEditingController;

          if (namaKomponenController.text.trim().isEmpty) {
            continue; // Skip empty komponen
          }

          komponenList.add({
            'namaKomponen': namaKomponenController.text.trim(),
            'spesifikasi':
                spesifikasiController.text.trim().isEmpty
                    ? null
                    : spesifikasiController.text.trim(),
          });
        }

        bagianList.add({
          'namaBagian': namaBagianController.text.trim(),
          'keterangan':
              keteranganController.text.trim().isEmpty
                  ? null
                  : keteranganController.text.trim(),
          'komponen': komponenList,
        });
      }

      // Save to database
      await _assetRepository.createAssetComplete(
        asset: asset,
        bagianList: bagianList,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showErrorDialog('Gagal menambahkan asset: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Asset Baru'),
        backgroundColor: const Color(0xFF0A9C5D),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAssetInfoSection(),
                      const SizedBox(height: 24),
                      _buildBagianAsetSection(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildAssetInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Asset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kodeAsetController,
              decoration: const InputDecoration(
                labelText: 'Kode Asset (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _namaAsetController,
              decoration: const InputDecoration(
                labelText: 'Nama Asset *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.precision_manufacturing),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama asset harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedJenisAset,
              decoration: const InputDecoration(
                labelText: 'Jenis Asset',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  _jenisAsetOptions.map((jenis) {
                    return DropdownMenuItem(value: jenis, child: Text(jenis));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenisAset = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items:
                  _statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lokasiIdController,
              decoration: const InputDecoration(
                labelText: 'Lokasi ID (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Maintenance Terakhir'),
              subtitle: Text(
                _maintenanceTerakhir != null
                    ? DateFormat('dd MMM yyyy').format(_maintenanceTerakhir!)
                    : 'Belum dipilih',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _selectDate(context, true),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Maintenance Selanjutnya'),
              subtitle: Text(
                _maintenanceSelanjutnya != null
                    ? DateFormat('dd MMM yyyy').format(_maintenanceSelanjutnya!)
                    : 'Belum dipilih',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _selectDate(context, false),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(
                _selectedImage != null ? 'Gambar dipilih' : 'Pilih Gambar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBagianAsetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bagian Asset',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addBagianAset,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Bagian'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A9C5D),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bagianAsetList.length,
              itemBuilder: (context, bagianIndex) {
                return _buildBagianCard(bagianIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBagianCard(int bagianIndex) {
    final bagian = _bagianAsetList[bagianIndex];
    final namaBagianController = bagian['namaBagian'] as TextEditingController;
    final keteranganController = bagian['keterangan'] as TextEditingController;
    final komponenList = bagian['komponen'] as List;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bagian ${bagianIndex + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_bagianAsetList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeBagianAset(bagianIndex),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: namaBagianController,
              decoration: const InputDecoration(
                labelText: 'Nama Bagian *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: keteranganController,
              decoration: const InputDecoration(
                labelText: 'Keterangan (Opsional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Komponen',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () => _addKomponenToBagian(bagianIndex),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Komponen'),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: komponenList.length,
              itemBuilder: (context, komponenIndex) {
                return _buildKomponenRow(bagianIndex, komponenIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKomponenRow(int bagianIndex, int komponenIndex) {
    final komponen = _bagianAsetList[bagianIndex]['komponen'][komponenIndex];
    final namaKomponenController =
        komponen['namaKomponen'] as TextEditingController;
    final spesifikasiController =
        komponen['spesifikasi'] as TextEditingController;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: namaKomponenController,
              decoration: const InputDecoration(
                labelText: 'Nama Komponen',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: spesifikasiController,
              decoration: const InputDecoration(
                labelText: 'Spesifikasi',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if ((_bagianAsetList[bagianIndex]['komponen'] as List).length > 1)
            IconButton(
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.red,
                size: 20,
              ),
              onPressed:
                  () => _removeKomponenFromBagian(bagianIndex, komponenIndex),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A9C5D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'SIMPAN ASSET',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

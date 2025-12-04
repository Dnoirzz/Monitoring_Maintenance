import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/repositories/asset_supabase_repository.dart';
import 'package:shared/providers/auth_provider.dart';
import '../../../services/maintenance_request_service.dart';
import 'package:intl/intl.dart';

class MaintenanceRequestListPage extends StatefulWidget {
  const MaintenanceRequestListPage({super.key});

  @override
  State<MaintenanceRequestListPage> createState() =>
      _MaintenanceRequestListPageState();
}

class _MaintenanceRequestListPageState
    extends State<MaintenanceRequestListPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _bgColor = const Color(0xFFF6F8F7);

  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final requests = await MaintenanceRequestService.getRequests();

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Maintenance Request',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRequests,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada request',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(_requests[index]);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormLaporanKerusakanPage(),
            ),
          );
          
          // Reload if form was submitted
          if (result == true) {
            _loadRequests();
          }
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> item) {
    // Extract data from database format
    final assetInfo = item['assets'] as Map<String, dynamic>?;
    final assetName = assetInfo?['nama_assets'] ?? 'Unknown Asset';
    
    final createdAtStr = item['created_at'] as String?;
    final formattedDate = createdAtStr != null 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(createdAtStr))
        : '-';
    
    final status = item['status'] ?? 'Pending';
    final priority = item['priority'] ?? 'Medium';
    final keterangan = item['keterangan'] ?? 'No description';
    final judul = item['judul'] ?? 'No title';

    Color statusColor;
    Color statusBgColor;

    switch (status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        break;
      case 'Approved':
      case 'Disetujui':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        break;
      case 'Completed':
      case 'Selesai':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Detail view if needed
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assetName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  keterangan,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color:
                          item['priority'] == 'Tinggi'
                              ? Colors.red
                              : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Prioritas: ${item['priority']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormLaporanKerusakanPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialAsset;

  const FormLaporanKerusakanPage({super.key, this.initialAsset});

  @override
  ConsumerState<FormLaporanKerusakanPage> createState() =>
      _FormLaporanKerusakanPageState();
}

class _FormLaporanKerusakanPageState extends ConsumerState<FormLaporanKerusakanPage> {
  final Color _primaryColor = const Color(0xFF0A9C5D);
  final Color _backgroundLight = const Color(0xFFF6F8F7);
  final AssetSupabaseRepository _assetRepository = AssetSupabaseRepository();

  // Form State
  String? _selectedAssetId;
  String _priority = 'Medium';
  String _requestType = 'Preventive';
  final TextEditingController _reportTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requesterNameController = TextEditingController();

  List<Map<String, dynamic>> _assets = [];
  bool _isLoadingAssets = true;
  bool _isSubmitting = false;
  String? _requesterId;

  @override
  void initState() {
    super.initState();
    _loadAssets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  void _loadUserInfo() {
    final authState = ref.read(authProvider);
    setState(() {
      _requesterId = authState.userId;
      _requesterNameController.text = authState.userFullName ?? 'Unknown User';
    });
  }

  Future<void> _loadAssets() async {
    try {
      final assets = await _assetRepository.getAllAssets();
      
      setState(() {
        _assets = assets;
        _isLoadingAssets = false;
        
        // Set initial asset if provided
        if (widget.initialAsset != null) {
          final exists = _assets.any((a) => a['id'] == widget.initialAsset!['id']);
          if (exists) {
            _selectedAssetId = widget.initialAsset!['id'];
          }
        }
      });
    } catch (e) {
      print('Error loading assets: $e');
      setState(() {
        _isLoadingAssets = false;
      });
    }
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _descriptionController.dispose();
    _requesterNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate
    if (_selectedAssetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih asset terlebih dahulu')),
      );
      return;
    }

    if (_reportTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul laporan tidak boleh kosong')),
      );
      return;
    }

    if (_requesterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak teridentifikasi')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await MaintenanceRequestService.submitRequest(
        requesterId: _requesterId!,
        assetsId: _selectedAssetId!,
        judul: _reportTitleController.text.trim(),
        requestType: _requestType,
        priority: _priority,
        keterangan: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        backgroundColor: _backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Maintenance Request',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMachineDropdown(),
            const SizedBox(height: 24),
            _buildRequesterNameField(),
            const SizedBox(height: 24),
            _buildReportTitleField(),
            const SizedBox(height: 24),
            _buildRequestTypeDropdown(),
            const SizedBox(height: 24),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildPhotoUpload(),
            const SizedBox(height: 24),
            _buildPrioritySelection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 16),
            const Text(
              'Laporan akan ditinjau oleh Kepala Teknisi untuk persetujuan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Asset',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingAssets
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Memuat data asset...'),
                  ],
                ),
              )
            : Autocomplete<Map<String, dynamic>>(
                initialValue: widget.initialAsset != null
                    ? TextEditingValue(
                        text: '${widget.initialAsset!['nama_assets']} (${widget.initialAsset!['kode_assets']})',
                      )
                    : null,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _assets;
                  }
                  final searchText = textEditingValue.text.toLowerCase();
                  return _assets.where((asset) {
                    final name = asset['nama_assets']?.toString().toLowerCase() ?? '';
                    final code = asset['kode_assets']?.toString().toLowerCase() ?? '';
                    return name.contains(searchText) || code.contains(searchText);
                  });
                },
                displayStringForOption: (Map<String, dynamic> option) =>
                    '${option['nama_assets']} (${option['kode_assets']})',
                onSelected: (Map<String, dynamic> selection) {
                  setState(() {
                    _selectedAssetId = selection['id'];
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    enabled: widget.initialAsset == null,
                    decoration: InputDecoration(
                      hintText: 'Ketik nama atau kode asset...',
                      filled: true,
                      fillColor: widget.initialAsset != null
                          ? Colors.grey.shade200
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    ),
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<Map<String, dynamic>> onSelected,
                  Iterable<Map<String, dynamic>> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['nama_assets'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kode: ${option['kode_assets'] ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildReportTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul Laporan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reportTitleController,
          decoration: InputDecoration(
            hintText: 'Masukkan judul laporan...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequesterNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Pelapor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _requesterNameController,
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Loading...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestTypeDropdown() {
    final List<String> requestTypes = [
      'Preventive',
      'Breakdown',
      'Inspection',
      'Upgrade',
      'Replacement',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _requestType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items:
              requestTypes.map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _requestType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Kerusakan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Jelaskan detail kerusakan di sini...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lampirkan Foto (Opsional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 128,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              style:
                  BorderStyle
                      .solid, // Dashed border is harder in basic Flutter, using solid for now or custom painter
            ),
          ),
          child: InkWell(
            onTap: () {
              // Handle photo upload
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Klik untuk mengunggah',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tingkat Prioritas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildPriorityOption('Low'),
              _buildPriorityOption('Medium'),
              _buildPriorityOption('High'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(String label) {
    final isSelected = _priority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _backgroundLight : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? _primaryColor : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Kirim Laporan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

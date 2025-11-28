import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/check_sheet_controller.dart';
import 'package:monitoring_maintenance/repositories/asset_supabase_repository.dart';
import 'package:monitoring_maintenance/repositories/check_sheet_template_repository.dart';

class ModalTambahChecksheet {
  static void show({
    required BuildContext context,
    required CheckSheetController checkSheetController,
    required VoidCallback onSuccess,
  }) {
    final formKey = GlobalKey<FormState>();
    final repository = CheckSheetTemplateRepository();
    String? selectedAssetId;
    String? selectedAssetName;
    bool isLoadingKomponen = false;
    final List<KomponenScheduleItem> komponenList = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Load assets untuk dropdown
            Future<List<Map<String, dynamic>>> loadAssets() async {
              try {
                final assetRepo = AssetSupabaseRepository();
                final assets = await assetRepo.getAllAssets();
                return assets;
              } catch (e) {
                print('Error loading assets: $e');
                return [];
              }
            }

            // Load komponen dari asset yang dipilih dan otomatis tambahkan ke list
            Future<void> loadKomponenFromAsset(String assetId) async {
              setModalState(() {
                isLoadingKomponen = true;
                komponenList.clear(); // Clear list sebelumnya
              });

              try {
                // Gunakan method khusus untuk mengambil komponen berdasarkan asset ID
                final filtered = await repository.getKomponenByAssetId(assetId);
                print('✅ Ditemukan ${filtered.length} komponen untuk asset $assetId');
                
                // Otomatis tambahkan semua komponen ke list
                setModalState(() {
                  for (var komponen in filtered) {
                    final komponenId = komponen['id']?.toString();
                    if (komponenId != null) {
                      final komponenItem = KomponenScheduleItem();
                      komponenItem.selectedKomponenId = komponenId;
                      komponenList.add(komponenItem);
                    }
                  }
                  isLoadingKomponen = false;
                });
              } catch (e) {
                print('❌ Error loading komponen: $e');
                setModalState(() {
                  isLoadingKomponen = false;
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF0A9C5D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.schedule,
                              color: Color(0xFF0A9C5D),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tambah Cek Sheet Schedule",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Isi form di bawah ini untuk menambahkan schedule baru",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dropdown Asset
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: loadAssets(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                  
                                  final assets = snapshot.data ?? [];
                                  
                                  return DropdownButtonFormField<String>(
                                    value: selectedAssetId,
                                    decoration: _modalInputDecoration(
                                      label: "Pilih Asset/Infrastruktur",
                                      icon: Icons.precision_manufacturing,
                                    ),
                                    hint: Text("Pilih asset"),
                                    items: assets.map((asset) {
                                      final id = asset['id']?.toString() ?? '';
                                      final nama = asset['nama_assets'] as String? ?? 
                                                   asset['nama_aset'] as String? ?? 
                                                   'Unknown';
                                      return DropdownMenuItem(
                                        value: id,
                                        child: Text(nama),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      if (value != null) {
                                        final asset = assets.firstWhere(
                                          (a) => a['id']?.toString() == value,
                                        );
                                        final nama = asset['nama_assets'] as String? ?? 
                                                     asset['nama_aset'] as String? ?? 
                                                     'Unknown';
                                        setModalState(() {
                                          selectedAssetId = value;
                                          selectedAssetName = nama;
                                          komponenList.clear();
                                        });
                                        await loadKomponenFromAsset(value);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Asset wajib dipilih";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Komponen List (muncul setelah asset dipilih)
                              if (selectedAssetId != null) ...[
                                if (isLoadingKomponen)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(color: Color(0xFF0A9C5D)),
                                          SizedBox(height: 12),
                                          Text(
                                            'Memuat komponen dari asset...',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (komponenList.isEmpty)
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.orange[700]),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Asset ini belum memiliki komponen. Silakan tambahkan komponen terlebih dahulu di menu Data Assets.',
                                            style: TextStyle(color: Colors.orange[900]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Komponen dan Detail Pekerjaan (${komponenList.length} komponen)",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // FutureBuilder untuk load nama komponen
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: repository.getKomponenAssets(),
                                    builder: (context, komponenSnapshot) {
                                      if (!komponenSnapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      
                                      final allKomponen = komponenSnapshot.data ?? [];
                                      
                                      return Column(
                                        children: komponenList.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          KomponenScheduleItem komponenItem = entry.value;
                                          
                                          // Cari data komponen berdasarkan ID
                                          final komponenData = allKomponen.firstWhere(
                                            (k) => k['id']?.toString() == komponenItem.selectedKomponenId,
                                            orElse: () => <String, dynamic>{},
                                          );
                                          
                                          // Ambil nama komponen dari komponen_assets
                                          // Field di komponen_assets adalah 'nama_bagian' (bukan 'nama_komponen')
                                          final namaKomponen = komponenData['nama_bagian'] as String? ?? 
                                                               komponenData['nama_komponen'] as String? ?? 
                                                               'Unknown';
                                          final bgMesin = komponenData['bg_mesin'] as Map<String, dynamic>?;
                                          final namaBagianMesin = bgMesin?['nama_bagian'] as String? ?? '';
                                          
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF7F9FB),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF0A9C5D),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        "Komponen ${index + 1}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    if (komponenList.length > 1)
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          setModalState(() {
                                                            komponenItem.dispose();
                                                            komponenList.removeAt(index);
                                                          });
                                                        },
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(height: 12),

                                                // Display Nama Komponen (read-only)
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.grey[300]!),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.category, color: Colors.grey[600], size: 20),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Nama Komponen',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey[600],
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              namaBagianMesin.isNotEmpty 
                                                                  ? '$namaBagianMesin - $namaKomponen'
                                                                  : namaKomponen,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.grey[800],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 12),

                                                DropdownButtonFormField<String>(
                                                  value: komponenItem.selectedPeriode,
                                                  decoration: _modalInputDecoration(
                                                    label: "Periode",
                                                    icon: Icons.calendar_today,
                                                  ),
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: "Harian",
                                                      child: Text("Harian"),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: "Mingguan",
                                                      child: Text("Mingguan"),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: "Bulanan",
                                                      child: Text("Bulanan"),
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      komponenItem.selectedPeriode = value;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return "Periode wajib dipilih";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 12),

                                                if (komponenItem.selectedPeriode != null) ...[
                                                  _buildIntervalSpinBox(
                                                    bagian: komponenItem,
                                                    setModalState: setModalState,
                                                  ),
                                                  SizedBox(height: 12),
                                                ],

                                                _modalTextField(
                                                  controller: komponenItem.jenisPekerjaanController,
                                                  label: "Jenis Pekerjaan",
                                                  icon: Icons.work_outline,
                                                  validator: (value) {
                                                    if (value == null || value.trim().isEmpty) {
                                                      return "Jenis pekerjaan wajib diisi";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 12),

                                                _modalTextField(
                                                  controller: komponenItem.standarPerawatanController,
                                                  label: "Standar Perawatan",
                                                  icon: Icons.checklist,
                                                  maxLines: 2,
                                                  validator: (value) {
                                                    if (value == null || value.trim().isEmpty) {
                                                      return "Standar perawatan wajib diisi";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 12),

                                                _modalTextField(
                                                  controller: komponenItem.alatBahanController,
                                                  label: "Alat dan Bahan",
                                                  icon: Icons.build,
                                                  maxLines: 2,
                                                  validator: (value) {
                                                    if (value == null || value.trim().isEmpty) {
                                                      return "Alat dan bahan wajib diisi";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Divider(),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text("Batal"),
                          ),
                          const SizedBox(width: 12),
                          isLoadingKomponen
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text("Menyimpan..."),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () async {
                                    if (!(formKey.currentState?.validate() ?? false)) {
                                      return;
                                    }

                                    if (selectedAssetId == null || selectedAssetName == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Pilih asset terlebih dahulu'),
                                          backgroundColor: Color(0xFFF44336),
                                        ),
                                      );
                                      return;
                                    }

                                    // Set loading state
                                    setModalState(() {
                                      isLoadingKomponen = true;
                                    });

                                    try {
                                      int savedCount = 0;
                                      // Simpan setiap komponen sebagai cek sheet template terpisah
                                      for (var komponenItem in komponenList) {
                                        if (komponenItem.selectedKomponenId == null) {
                                          continue;
                                        }
                                        
                                        final interval = int.tryParse(komponenItem.intervalController.text.trim()) ?? 1;
                                        final periodeEnum = komponenItem.selectedPeriode ?? 'Harian';

                                        try {
                                          await checkSheetController.addCheckSheetTemplate(
                                            komponenAssetsId: komponenItem.selectedKomponenId!,
                                            periode: periodeEnum,
                                            intervalPeriode: interval,
                                            jenisPekerjaan: komponenItem.jenisPekerjaanController.text.trim(),
                                            stdPrwtn: komponenItem.standarPerawatanController.text.trim(),
                                            alatBahan: komponenItem.alatBahanController.text.trim(),
                                          );
                                          savedCount++;
                                          print('✅ Komponen ${savedCount} berhasil disimpan');
                                        } catch (e) {
                                          print('❌ Error menyimpan komponen: $e');
                                          // Continue dengan komponen berikutnya
                                        }
                                      }

                                      // Close dialog first before reloading data
                                      if (context.mounted) {
                                        Navigator.of(dialogContext).pop();
                                        
                                        // Show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Cek sheet untuk ${selectedAssetName} berhasil ditambahkan dengan $savedCount komponen",
                                            ),
                                            backgroundColor: Color(0xFF0A9C5D),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        // Reload data after a short delay to avoid freeze
                                        Future.delayed(Duration(milliseconds: 300), () {
                                          onSuccess();
                                        });
                                      }
                                    } catch (e, stackTrace) {
                                      print('❌ Error menyimpan cek sheet: $e');
                                      print('Stack trace: $stackTrace');
                                      
                                      setModalState(() {
                                        isLoadingKomponen = false;
                                      });
                                      
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Gagal menyimpan: ${e.toString()}'),
                                            backgroundColor: Color(0xFFF44336),
                                            duration: Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A9C5D),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: Icon(Icons.save),
                                  label: const Text("Simpan"),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      for (var komponen in komponenList) {
        komponen.dispose();
      }
    });
  }

  static Widget _buildIntervalSpinBox({
    required dynamic bagian,
    required StateSetter setModalState,
  }) {
    if (bagian.intervalController.text.isEmpty) {
      bagian.intervalController.text = "1";
    }

    String getIntervalLabel(String? periode) {
      switch (periode) {
        case "Harian":
          return "Hari";
        case "Mingguan":
          return "Minggu";
        case "Bulanan":
          return "Bulan";
        default:
          return periode ?? "";
      }
    }

    return FormField<int>(
      initialValue: int.tryParse(bagian.intervalController.text) ?? 1,
      validator: (value) {
        if (bagian.intervalController.text.isEmpty) {
          return "Interval wajib diisi";
        }
        int? val = int.tryParse(bagian.intervalController.text);
        if (val == null) {
          return "Harus berupa angka";
        }
        if (val <= 0) {
          return "Harus lebih dari 0";
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      formFieldState.hasError
                          ? Colors.red.shade300
                          : Colors.grey.shade300,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.repeat, color: const Color(0xFF0A9C5D)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interval (${bagian.selectedPeriode ?? 'Harian'})",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Per ${bagian.intervalController.text.isEmpty ? '1' : bagian.intervalController.text} ${getIntervalLabel(bagian.selectedPeriode)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color:
                            (int.tryParse(bagian.intervalController.text) ?? 1) > 1
                                ? Color(0xFFF44336)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap:
                              (int.tryParse(bagian.intervalController.text) ?? 1) > 1
                                  ? () {
                                    setModalState(() {
                                      int currentValue =
                                          int.tryParse(
                                            bagian.intervalController.text,
                                          ) ??
                                          1;
                                      bagian.intervalController.text =
                                          (currentValue - 1).toString();
                                      formFieldState.didChange(currentValue - 1);
                                    });
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.remove,
                              color:
                                  (int.tryParse(bagian.intervalController.text) ??
                                              1) >
                                          1
                                      ? Colors.white
                                      : Colors.grey[500],
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 60,
                        height: 40,
                        child: TextFormField(
                          controller: bagian.intervalController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A9C5D),
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
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
                              borderSide: BorderSide(
                                color: Color(0xFF0A9C5D),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              formFieldState.didChange(int.tryParse(value));
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Material(
                        color: Color(0xFF0A9C5D),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              int currentValue =
                                  int.tryParse(bagian.intervalController.text) ?? 1;
                              bagian.intervalController.text =
                                  (currentValue + 1).toString();
                              formFieldState.didChange(currentValue + 1);
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  formFieldState.errorText ?? '',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  static Widget _modalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label wajib diisi";
            }
            return null;
          },
      decoration: _modalInputDecoration(label: label, icon: icon),
    );
  }

  static InputDecoration _modalInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0A9C5D)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0A9C5D), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class KomponenScheduleItem {
  String? selectedKomponenId;
  String? selectedPeriode;
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController jenisPekerjaanController = TextEditingController();
  final TextEditingController standarPerawatanController = TextEditingController();
  final TextEditingController alatBahanController = TextEditingController();

  void dispose() {
    intervalController.dispose();
    jenisPekerjaanController.dispose();
    standarPerawatanController.dispose();
    alatBahanController.dispose();
  }
}
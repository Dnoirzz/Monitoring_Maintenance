import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../model/mt_schedule_model.dart';
import '../../../model/mt_template_model.dart';
import '../../../services/supabase_service.dart';
import '../../../controller/maintenance_schedule_page_controller.dart';

  class ModalTambahMaintenanceSchedule {
  static void show(
    BuildContext context, {
      required MaintenanceSchedulePageController pageController,
      required int selectedYear,
      required VoidCallback onSuccess,
  }) {
    final formKey = GlobalKey<FormState>();
    final currentUser = SupabaseService.instance.currentUser;

    String? selectedAssetId;
    String? selectedBgMesinId;
    String? selectedPeriode;
    DateTime? startDate;
    DateTime? selectedTglJadwal;
    String selectedStatus = 'Perlu Maintenance';
    final catatanController = TextEditingController();
    final intervalController = TextEditingController();

    List<Map<String, dynamic>> assetsList = [];
    List<Map<String, dynamic>> bgMesinList = [];
    bool isLoadingData = true;
    bool isLoadingBgMesin = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Load assets
            Future<void> loadData() async {
              try {
                final assetsOptions = await pageController.getAssetsOptions();

                setModalState(() {
                  assetsList = assetsOptions;
                  isLoadingData = false;
                });
              } catch (e) {
                setModalState(() {
                  isLoadingData = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memuat data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            // Load bagian mesin berdasarkan asset yang dipilih
            Future<void> loadBagianMesin(String assetId) async {
              try {
                setModalState(() {
                  isLoadingBgMesin = true;
                  bgMesinList = [];
                });

                final bagianOptions = await pageController.getBagianMesinOptions(assetId);

                setModalState(() {
                  bgMesinList = bagianOptions;
                  isLoadingBgMesin = false;
                });
              } catch (e) {
                setModalState(() {
                  isLoadingBgMesin = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memuat bagian mesin: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            // Load data on first build
            if (isLoadingData && assetsList.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                loadData();
              });
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
                                  "Tambah Maintenance Schedule",
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
                        child: isLoadingData
                            ? Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Asset Dropdown
                                    _modalDropdownField(
                                      context: context,
                                      label: "Nama Mesin",
                                      icon: Icons.precision_manufacturing,
                                      value: selectedAssetId,
                                      items: assetsList.map<DropdownMenuItem<String>>((asset) {
                                        return DropdownMenuItem<String>(
                                          value: asset['id'] as String?,
                                          child: Text(asset['nama'] as String? ?? ''),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setModalState(() {
                                          selectedAssetId = value;
                                          selectedBgMesinId = null;
                                          bgMesinList = [];
                                          if (value != null) {
                                            loadBagianMesin(value);
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Asset wajib dipilih";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Bagian Mesin Dropdown (muncul setelah asset dipilih)
                                    // Sesuai schema: mt_template.bg_mesin_id (FK ke bg_mesin)
                                    if (selectedAssetId != null) ...[
                                      isLoadingBgMesin
                                          ? Center(child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: CircularProgressIndicator(),
                                            ))
                                          : bgMesinList.isEmpty
                                              ? Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Colors.orange.shade200),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Asset ini belum memiliki bagian mesin. Silakan tambahkan bagian mesin terlebih dahulu.',
                                                          style: TextStyle(color: Colors.orange.shade700),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : _modalDropdownField(
                                                  context: context,
                                                  label: "Bagian Mesin",
                                                  icon: Icons.precision_manufacturing,
                                                  value: selectedBgMesinId,
                                                  items: bgMesinList.map<DropdownMenuItem<String>>((bgMesin) {
                                                    return DropdownMenuItem<String>(
                                                      value: bgMesin['id'] as String?,
                                                      child: Text(bgMesin['nama'] as String? ?? ''),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      selectedBgMesinId = value;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return "Bagian mesin wajib dipilih";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                      const SizedBox(height: 20),

                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "LIFT TIME MESIN / HARI",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _modalTextField(
                                                    context: context,
                                                    controller: intervalController,
                                                    label: "Interval",
                                                    icon: Icons.repeat,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      final iv = int.tryParse(value);
                                                      if (startDate != null && iv != null && iv > 0 && selectedPeriode != null) {
                                                        final next = pageController.computeNextOccurrenceInYear(
                                                          startDate: startDate!,
                                                          interval: iv,
                                                          periode: selectedPeriode!,
                                                          targetYear: selectedYear,
                                                        );
                                                        setModalState(() {
                                                          selectedTglJadwal = next ?? startDate;
                                                        });
                                                      }
                                                    },
                                                    validator: (value) {
                                                      if (value == null || value.trim().isEmpty) {
                                                        return "Interval wajib diisi";
                                                      }
                                                      final intValue = int.tryParse(value);
                                                      if (intValue == null || intValue <= 0) {
                                                        return "Harus angka positif";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: _modalDropdownField(
                                                    context: context,
                                                    label: "Periode",
                                                    icon: Icons.calendar_today,
                                                    value: selectedPeriode,
                                                    items: [
                                                      DropdownMenuItem(value: 'Hari', child: Text('Harian')),
                                                      DropdownMenuItem(value: 'Minggu', child: Text('Mingguan')),
                                                      DropdownMenuItem(value: 'Bulan', child: Text('Bulanan')),
                                                    ],
                                                    onChanged: (value) {
                                                      setModalState(() {
                                                        selectedPeriode = value;
                                                        final iv = int.tryParse(intervalController.text);
                                                        if (startDate != null && iv != null && iv > 0 && selectedPeriode != null) {
                                                          final next = pageController.computeNextOccurrenceInYear(
                                                            startDate: startDate!,
                                                            interval: iv,
                                                            periode: selectedPeriode!,
                                                            targetYear: selectedYear,
                                                          );
                                                          selectedTglJadwal = next ?? startDate;
                                                        }
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return "Periode wajib dipilih";
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Tanggal (gabungan start_date template dan tgl_jadwal schedule)
                                      _modalDateField(
                                        context: dialogContext,
                                        dialogContext: dialogContext,
                                        label: "Tanggal",
                                        icon: Icons.event,
                                        selectedDate: selectedTglJadwal,
                                        onDateSelected: (date) {
                                          setModalState(() {
                                            selectedTglJadwal = date;
                                            startDate = date;
                                          });
                                        },
                                        validator: (value) {
                                          if (selectedTglJadwal == null) {
                                            return "Tanggal wajib dipilih";
                                          }
                                          if (selectedTglJadwal!.year != selectedYear) {
                                            return "Tanggal harus di tahun $selectedYear";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    // (Tanggal selesai dihapus dari form tambah)

                                    // Status Dropdown
                                    // Sesuai schema: mt_schedule.status (USER-DEFINED enum: 'Perlu Maintenance', 'Sedang Maintenance', 'Selesai', 'Dibatalkan')
                                    _modalDropdownField(
                                      context: context,
                                      label: "Status",
                                      icon: Icons.info,
                                      value: selectedStatus,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'Perlu Maintenance',
                                          child: Text('Perlu Maintenance'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Sedang Maintenance',
                                          child: Text('Sedang Maintenance'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Selesai',
                                          child: Text('Selesai'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Dibatalkan',
                                          child: Text('Dibatalkan'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setModalState(() {
                                          selectedStatus = value ?? 'Perlu Maintenance';
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Catatan
                                    // Sesuai schema: mt_schedule.catatan (text, nullable)
                                    _modalTextField(
                                      context: context,
                                      controller: catatanController,
                                      label: "Catatan (Opsional)",
                                      icon: Icons.note,
                                      maxLines: 3,
                                    ),
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
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }

                              try {
                                // Parse interval periode
                                final interval = int.tryParse(intervalController.text.trim());
                                if (interval == null || interval <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Interval periode harus berupa angka positif'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Validasi: Pastikan field template dan tanggal sudah diisi
                                if (selectedBgMesinId == null || 
                                    selectedPeriode == null || 
                                    selectedTglJadwal == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Semua field wajib diisi'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Buat template baru terlebih dahulu
                                // Sesuai schema mt_template: bg_mesin_id, periode, interval_periode, start_date
                                final newTemplate = MtTemplate(
                                  bgMesinId: selectedBgMesinId,
                                  periode: selectedPeriode,
                                  intervalPeriode: interval,
                                  startDate: selectedTglJadwal,
                                );

                                final createdTemplate = await pageController.createTemplate(newTemplate);

                                // Validasi: Pastikan template berhasil dibuat
                                if (createdTemplate.id == null) {
                                  throw Exception('Gagal membuat template: ID tidak tersedia');
                                }

                                // Generate dan insert jadwal berulang sesuai interval & periode untuk tahun terpilih
                                List<DateTime> occurrenceDates = [];
                                DateTime cursor = selectedTglJadwal!;
                                while (cursor.year == selectedYear) {
                                  occurrenceDates.add(cursor);
                                  switch (selectedPeriode) {
                                    case 'Hari':
                                      cursor = cursor.add(Duration(days: interval));
                                      break;
                                    case 'Minggu':
                                      cursor = cursor.add(Duration(days: interval * 7));
                                      break;
                                    case 'Bulan':
                                      cursor = DateTime(cursor.year, cursor.month + interval, cursor.day);
                                      break;
                                    default:
                                      throw Exception('Periode tidak valid: $selectedPeriode');
                                  }
                                }

                                for (final date in occurrenceDates) {
                                  final schedule = MtSchedule(
                                    templateId: createdTemplate.id,
                                    assetsId: selectedAssetId,
                                    tglJadwal: date,
                                    status: selectedStatus,
                                    catatan: catatanController.text.trim().isEmpty
                                        ? null
                                        : catatanController.text.trim(),
                                    createdBy: currentUser?.id,
                                  );
                                  await pageController.createSchedule(schedule);
                                }

                                if (context.mounted) {
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Schedule berhasil ditambahkan'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  onSuccess();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menambahkan schedule: $e'),
                                      backgroundColor: Colors.red,
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
      catatanController.dispose();
      intervalController.dispose();
    });
  }
}

  Widget _modalDropdownField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _modalInputDecoration(context: context, label: label, icon: icon),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _modalDateField({
    required BuildContext context,
    required BuildContext dialogContext,
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return TextFormField(
      readOnly: true,
      decoration: _modalInputDecoration(
        context: context,
        label: label,
        icon: icon,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: selectedDate != null
            ? DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)
            : '',
      ),
      validator: isOptional
          ? null
          : (value) {
              if (selectedDate == null) {
                return "$label wajib dipilih";
              }
              return null;
            },
      onTap: () async {
        // Gunakan rootNavigator untuk mendapatkan context yang memiliki MaterialLocalizations
        final pickedDate = await showDatePicker(
          context: dialogContext,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
    );
  }

  Widget _modalTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: _modalInputDecoration(context: context, label: label, icon: icon),
    );
  }

  InputDecoration _modalInputDecoration({
    required BuildContext context,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0A9C5D)),
      suffixIcon: suffixIcon,
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


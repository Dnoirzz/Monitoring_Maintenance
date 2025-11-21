import 'package:flutter/material.dart';

class BagianScheduleItem {
  final TextEditingController bagianController = TextEditingController();
  String? selectedPeriode;
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController jenisPekerjaanController = TextEditingController();
  final TextEditingController standarPerawatanController = TextEditingController();
  final TextEditingController alatBahanController = TextEditingController();

  void dispose() {
    bagianController.dispose();
    intervalController.dispose();
    jenisPekerjaanController.dispose();
    standarPerawatanController.dispose();
    alatBahanController.dispose();
  }
}

class ModalTambahChecksheet {
  static void show(
    BuildContext context,
    Function(String namaInfrastruktur, List<Map<String, dynamic>> bagianList) onSave,
  ) {
    final formKey = GlobalKey<FormState>();
    final namaInfrastrukturController = TextEditingController();
    final List<BagianScheduleItem> bagianList = [BagianScheduleItem()];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                              _modalTextField(
                                controller: namaInfrastrukturController,
                                label: "Nama Infrastruktur",
                                icon: Icons.precision_manufacturing,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama infrastruktur wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Bagian dan Detail Pekerjaan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        bagianList.add(BagianScheduleItem());
                                      });
                                    },
                                    icon: Icon(Icons.add_circle, size: 20),
                                    label: Text("Tambah Bagian"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF0A9C5D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ...bagianList.asMap().entries.map((entry) {
                                int index = entry.key;
                                BagianScheduleItem bagian = entry.value;

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
                                              "Bagian ${index + 1}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          if (bagianList.length > 1)
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setModalState(() {
                                                  bagian.dispose();
                                                  bagianList.removeAt(index);
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      _modalTextField(
                                        controller: bagian.bagianController,
                                        label: "Nama Bagian",
                                        icon: Icons.category,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Nama bagian wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      DropdownButtonFormField<String>(
                                        value: bagian.selectedPeriode,
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
                                            bagian.selectedPeriode = value;
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

                                      if (bagian.selectedPeriode != null) ...[
                                        _buildIntervalSpinBox(
                                          bagian: bagian,
                                          setModalState: setModalState,
                                        ),
                                        SizedBox(height: 12),
                                      ],

                                      _modalTextField(
                                        controller: bagian.jenisPekerjaanController,
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
                                        controller: bagian.standarPerawatanController,
                                        label: "Standar Perawatan",
                                        icon: Icons.checklist,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return "Standar perawatan wajib diisi";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      _modalTextField(
                                        controller: bagian.alatBahanController,
                                        label: "Alat dan Bahan",
                                        icon: Icons.build,
                                        maxLines: 1,
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
                            onPressed: () {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }

                              List<Map<String, dynamic>> savedBagianList = [];
                              for (var bagian in bagianList) {
                                String intervalUnit = "";
                                switch (bagian.selectedPeriode) {
                                  case "Harian":
                                    intervalUnit = "Hari";
                                    break;
                                  case "Mingguan":
                                    intervalUnit = "Minggu";
                                    break;
                                  case "Bulanan":
                                    intervalUnit = "Bulan";
                                    break;
                                }
                                String periodeText =
                                    "Per ${bagian.intervalController.text.trim()} $intervalUnit";
                                
                                savedBagianList.add({
                                  "bagian": bagian.bagianController.text.trim(),
                                  "periode": periodeText,
                                  "jenis_pekerjaan": bagian.jenisPekerjaanController.text.trim(),
                                  "standar_perawatan": bagian.standarPerawatanController.text.trim(),
                                  "alat_bahan": bagian.alatBahanController.text.trim(),
                                });
                              }

                              onSave(
                                namaInfrastrukturController.text.trim(),
                                savedBagianList,
                              );
                              Navigator.of(dialogContext).pop();
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
      namaInfrastrukturController.dispose();
      for (var bagian in bagianList) {
        bagian.dispose();
      }
    });
  }

  static Widget _buildIntervalSpinBox({
    required BagianScheduleItem bagian,
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
                          "Interval (${bagian.selectedPeriode})",
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
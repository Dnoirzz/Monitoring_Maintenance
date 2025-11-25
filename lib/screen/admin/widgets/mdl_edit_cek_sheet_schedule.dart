import 'package:flutter/material.dart';

class ModalEditCekSheetSchedule {
  static void show(
    BuildContext context,
    Map<String, dynamic> item,
    Function(Map<String, dynamic>) onSave,
  ) {
    final formKey = GlobalKey<FormState>();
    final bagianController = TextEditingController(text: item["bagian"]);
    
    // Parse periode untuk mendapatkan interval dan tipe periode
    String periodeText = item["periode"] ?? "Per 1 Hari";
    RegExp regExp = RegExp(r'Per (\d+) (Hari|Minggu|Bulan)');
    Match? match = regExp.firstMatch(periodeText);
    
    int initialInterval = 1;
    String initialPeriode = "Harian";
    
    if (match != null) {
      initialInterval = int.tryParse(match.group(1) ?? "1") ?? 1;
      String unit = match.group(2) ?? "Hari";
      switch (unit) {
        case "Hari":
          initialPeriode = "Harian";
          break;
        case "Minggu":
          initialPeriode = "Mingguan";
          break;
        case "Bulan":
          initialPeriode = "Bulanan";
          break;
      }
    }
    
    String? selectedPeriode = initialPeriode;
    final intervalController = TextEditingController(text: initialInterval.toString());
    final jenisPekerjaanController = TextEditingController(text: item["jenis_pekerjaan"]);
    final standarPerawatanController = TextEditingController(text: item["standar_perawatan"]);
    final alatBahanController = TextEditingController(text: item["alat_bahan"]);

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
                width: MediaQuery.of(context).size.width * 0.6,
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
                              color: Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Color(0xFF2196F3),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Edit Bagian Mesin",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Edit detail bagian dari ${item["nama_infrastruktur"]}",
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
                              // Nama Infrastruktur (Read-only)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.precision_manufacturing,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Infrastruktur",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            item["nama_infrastruktur"],
                                            style: TextStyle(
                                              fontSize: 16,
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
                              const SizedBox(height: 20),

                              _modalTextField(
                                controller: bagianController,
                                label: "Nama Bagian",
                                icon: Icons.category,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama bagian wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              DropdownButtonFormField<String>(
                                value: selectedPeriode,
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
                                    selectedPeriode = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Periode wajib dipilih";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              if (selectedPeriode != null) ...[
                                _buildEditIntervalSpinBox(
                                  selectedPeriode: selectedPeriode,
                                  intervalController: intervalController,
                                  setModalState: setModalState,
                                ),
                                SizedBox(height: 16),
                              ],

                              _modalTextField(
                                controller: jenisPekerjaanController,
                                label: "Jenis Pekerjaan",
                                icon: Icons.work_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Jenis pekerjaan wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              _modalTextField(
                                controller: standarPerawatanController,
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
                              SizedBox(height: 16),

                              _modalTextField(
                                controller: alatBahanController,
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

                              String intervalUnit = "";
                              switch (selectedPeriode) {
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
                                  "Per ${intervalController.text.trim()} $intervalUnit";

                              item["bagian"] = bagianController.text.trim();
                              item["periode"] = periodeText;
                              item["jenis_pekerjaan"] =
                                  jenisPekerjaanController.text.trim();
                              item["standar_perawatan"] =
                                  standarPerawatanController.text.trim();
                              item["alat_bahan"] = alatBahanController.text.trim();

                              onSave(item);
                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: Icon(Icons.save),
                            label: const Text("Update"),
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
      bagianController.dispose();
      intervalController.dispose();
      jenisPekerjaanController.dispose();
      standarPerawatanController.dispose();
      alatBahanController.dispose();
    });
  }

  static Widget _buildEditIntervalSpinBox({
    required String? selectedPeriode,
    required TextEditingController intervalController,
    required StateSetter setModalState,
  }) {
    if (intervalController.text.isEmpty) {
      intervalController.text = "1";
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
      initialValue: int.tryParse(intervalController.text) ?? 1,
      validator: (value) {
        if (intervalController.text.isEmpty) {
          return "Interval wajib diisi";
        }
        int? val = int.tryParse(intervalController.text);
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
                          "Interval (${selectedPeriode})",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Per ${intervalController.text.isEmpty ? '1' : intervalController.text} ${getIntervalLabel(selectedPeriode)}",
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
                            (int.tryParse(intervalController.text) ?? 1) > 1
                                ? Color(0xFFF44336)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap:
                              (int.tryParse(intervalController.text) ?? 1) > 1
                                  ? () {
                                    setModalState(() {
                                      int currentValue =
                                          int.tryParse(
                                            intervalController.text,
                                          ) ??
                                          1;
                                      intervalController.text =
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
                                  (int.tryParse(intervalController.text) ??
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
                          controller: intervalController,
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
                                  int.tryParse(intervalController.text) ?? 1;
                              intervalController.text =
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


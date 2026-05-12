import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final githubController = TextEditingController();
  
  final api = ApiService();
  bool isLoading = false;

  Future<void> handleSubmit() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descController.text.isEmpty ||
        githubController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom wajib diisi!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    int? price = int.tryParse(priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harga harus berupa angka yang valid!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    String? error = await api.submitTugas(
      nameController.text,
      price,
      descController.text,
      githubController.text,
    );

    setState(() => isLoading = false);

    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tugas Akhir berhasil dikirim! ✨"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); 
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KIRIM TUGAS AKHIR", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Pengiriman data bersifat final. Pastikan data produk dan Link GitHub sudah benar.",
                      style: TextStyle(fontSize: 13, color: Colors.purple[100]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: nameController,
              label: "Nama Produk Akhir",
              icon: Icons.memory_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: priceController,
              label: "Harga Produk",
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: descController,
              label: "Deskripsi Produk",
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: githubController,
              label: "Link Repository GitHub",
              icon: Icons.link_rounded,
              hintText: "https://github.com/username/repo",
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shadowColor: const Color(0xFF8B5CF6).withOpacity(0.5),
                ),
                onPressed: isLoading ? null : handleSubmit,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "KIRIM TUGAS SEKARANG",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.0 : 0),
          child: Icon(icon),
        ),
      ),
    );
  }
}

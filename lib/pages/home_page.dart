import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'add_product_page.dart';
import 'submit_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    products = await api.getProducts();
    setState(() => isLoading = false);
  }

  Future<void> handleDelete(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Hapus Item?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan.", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("BATAL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("HAPUS"),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      String? error = await api.deleteProduct(id);
      if (error == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil dihapus."), backgroundColor: Colors.green),
        );
        loadProducts(); 
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void handleLogout() async {
    await api.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  String formatRupiah(String priceStr) {
    try {
      int price = int.parse(priceStr);
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
    } catch (e) {
      return 'Rp $priceStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rofiq Tech Store", 
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Color(0xFF06B6D4)),
            tooltip: "Kirim Tugas Akhir",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded),
            tooltip: "Logout",
            color: Colors.white54,
            onPressed: handleLogout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.memory, size: 100, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 24),
                      const Text(
                        "KATALOG KOSONG", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54),
                      ),
                      const SizedBox(height: 8),
                      const Text("Silakan tambah produk baru", style: TextStyle(color: Colors.white30)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF06B6D4),
                  backgroundColor: const Color(0xFF1E293B),
                  onRefresh: loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {}, 
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cyberpunk-ish Avatar
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF06B6D4).withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.devices, color: Colors.white, size: 32),
                                  ),
                                  const SizedBox(width: 20),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16, 
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          p.description,
                                          style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.4),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF06B6D4).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            formatRupiah(p.price),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF22D3EE),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => handleDelete(p.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
          loadProducts(); 
        },
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 8,
        child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
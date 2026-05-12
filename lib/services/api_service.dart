import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id/api';
  final storage = const FlutterSecureStorage();

  // Helper method for headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      String? token = await storage.read(key: 'token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // LOGIN (Returns null if success, String error message if failed)
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(requireAuth: false),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['data']['token'];
        await storage.write(key: 'token', value: token);
        return null; // Success
      } else {
        return data['message'] ?? 'Login gagal. Periksa username dan password.';
      }
    } catch (e) {
      return 'Terjadi kesalahan jaringan: $e';
    }
  }

  // GET PRODUCTS
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List products = data['data']?['products'] ?? [];
        return products.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error getProducts: $e');
      return [];
    }
  }

  // ADD PRODUCT
  Future<String?> addProduct(String name, int price, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Gagal menambahkan produk.';
      }
    } catch (e) {
      return 'Terjadi kesalahan jaringan: $e';
    }
  }

  // SUBMIT TUGAS
  Future<String?> submitTugas(String name, int price, String description, String githubUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/submit'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'github_url': githubUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Gagal melakukan submit tugas.';
      }
    } catch (e) {
      return 'Terjadi kesalahan jaringan: $e';
    }
  }

  // DELETE PRODUCT
  Future<String?> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Gagal menghapus produk.';
      }
    } catch (e) {
      return 'Terjadi kesalahan jaringan: $e';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
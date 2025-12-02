import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanProvider>(context);
    final result = provider.currentResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil')),
        body: const Center(child: Text('Tidak ada hasil')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi & Ekstraksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cropped Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(result.imagePath),
              ),
            ),
            const SizedBox(height: 16),
            
            // Edit Title Button
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController(text: result.name);
                    return AlertDialog(
                      title: const Text('Ubah Nama'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama baru',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              provider.updateScanName(controller.text);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(
                result.name.isEmpty ? 'klik untuk menamai...' : result.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Nutrition Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildRow(context, 'Energi Total', result.nutrition.energy, true),
                  _buildDivider(),
                  _buildRow(context, 'Lemak Total', result.nutrition.fat, false),
                  _buildDivider(),
                  _buildRow(context, 'Protein', result.nutrition.protein, true),
                  _buildDivider(),
                  _buildRow(context, 'Karbohidrat Total', result.nutrition.carbs, false),
                  _buildDivider(),
                  _buildRow(context, 'Gula', result.nutrition.sugar, true),
                  _buildDivider(),
                  _buildRow(context, 'Garam', result.nutrition.salt, false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: () async {
                await provider.saveCurrentScan();
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isEven ? Colors.grey.shade50 : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    } else if (path.startsWith('data:image')) {
      try {
        final base64String = path.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
        );
      } catch (e) {
        return const Icon(Icons.broken_image, size: 50);
      }
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    }
  }
}

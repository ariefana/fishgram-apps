import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/gradient_button.dart';
import 'dart:io';

/// Create a new fishing catch post.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _weightController = TextEditingController();
  XFile? _selectedImage;
  String? _selectedFishType;
  String? _selectedBait;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (image != null) setState(() => _selectedImage = image);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.dividerColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('Pilih Sumber Foto', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue)),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto langsung'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library, color: AppTheme.accentGreen)),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri foto'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih foto tangkapan terlebih dahulu')));
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<FeedProvider>().createCatch(
      fishType: _selectedFishType!,
      weight: double.tryParse(_weightController.text) ?? 0,
      bait: _selectedBait!,
      caption: _captionController.text.trim(),
      photo: File(_selectedImage!.path),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tangkapan berhasil dibagikan! 🎣'), backgroundColor: AppTheme.successGreen));
      Navigator.pop(context);
    } else {
      final error = context.read<FeedProvider>().errorMessage ?? 'Gagal membagikan tangkapan';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.likeRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bagikan Tangkapan'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor, width: 1.5),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 48, color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text('Tambah Foto Tangkapan', style: TextStyle(color: AppTheme.primaryBlue.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Ketuk untuk ambil atau pilih foto', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Fish type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedFishType,
                decoration: const InputDecoration(labelText: 'Jenis Ikan', prefixIcon: Icon(Icons.phishing)),
                items: AppConstants.fishSpecies.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedFishType = v),
                validator: (v) => v == null ? 'Pilih jenis ikan' : null,
              ),
              const SizedBox(height: 16),
              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Berat (kg)', prefixIcon: Icon(Icons.scale), hintText: 'Contoh: 2.5'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Masukkan berat ikan' : null,
              ),
              const SizedBox(height: 16),
              // Bait dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedBait,
                decoration: const InputDecoration(labelText: 'Umpan', prefixIcon: Icon(Icons.restaurant)),
                items: AppConstants.commonBaits.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _selectedBait = v),
                validator: (v) => v == null ? 'Pilih umpan' : null,
              ),
              const SizedBox(height: 16),
              // Caption
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption', prefixIcon: Icon(Icons.edit), hintText: 'Ceritakan pengalaman memancingmu...'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              GradientButton(text: 'Bagikan 🎣', isLoading: _isLoading, onPressed: _isLoading ? null : _submit),
            ],
          ),
        ),
      ),
    );
  }
}

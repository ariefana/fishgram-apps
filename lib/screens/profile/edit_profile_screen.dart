import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';

/// Edit profile screen.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppTheme.successGreen),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AvatarWidget(
                imageUrl: user?.avatar,
                name: user?.name ?? '',
                radius: 50,
                showEditIcon: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ganti foto akan menggunakan kamera/galeri')),
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nama',
                prefixIcon: Icons.person_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                prefixIcon: Icons.alternate_email,
                validator: (v) => v == null || v.isEmpty ? 'Username wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bioController,
                labelText: 'Bio',
                prefixIcon: Icons.info_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              GradientButton(text: 'Simpan', isLoading: _isLoading, onPressed: _isLoading ? null : _save),
            ],
          ),
        ),
      ),
    );
  }
}

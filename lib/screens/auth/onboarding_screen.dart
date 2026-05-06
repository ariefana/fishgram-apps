import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';

/// Onboarding screen — select fishing type and location.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  String? _selectedFishingType;
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_selectedFishingType == null || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')));
      return;
    }
    await context.read<AuthProvider>().completeOnboarding(
          fishingType: _selectedFishingType!,
          location: _locationController.text.trim(),
        );
  }

  void _nextPage() {
    if (_currentPage == 0 && _selectedFishingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih jenis memancing favorit')));
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(2, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppTheme.primaryBlue : AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [_buildFishingTypePage(), _buildLocationPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishingTypePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.phishing, size: 64, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text('Jenis Memancing Favorit', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Pilih jenis memancing yang paling kamu sukai', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ...AppConstants.fishingTypes.map((type) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FishingTypeCard(
              type: type,
              icon: _fishingIcon(type),
              isSelected: _selectedFishingType == type,
              onTap: () => setState(() => _selectedFishingType = type),
            ),
          )),
          const SizedBox(height: 24),
          GradientButton(text: 'Lanjut', onPressed: _nextPage),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.location_on, size: 64, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text('Domisili Kamu', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Beritahu kami kota tempat tinggalmu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Contoh: Jakarta, Surabaya, Bandung',
              prefixIcon: const Icon(Icons.location_city),
            ),
          ),
          const SizedBox(height: 40),
          GradientButton(text: 'Mulai Mancing! 🎣', onPressed: _complete, icon: Icons.arrow_forward),
        ],
      ),
    );
  }

  IconData _fishingIcon(String type) {
    switch (type) {
      case 'Laut': return Icons.waves;
      case 'Sungai': return Icons.water;
      case 'Danau': return Icons.landscape;
      case 'Rawa': return Icons.grass;
      case 'Waduk': return Icons.water_damage;
      default: return Icons.phishing;
    }
  }
}

class _FishingTypeCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FishingTypeCard({required this.type, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.dividerColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary),
            const SizedBox(width: 16),
            Text(type, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}

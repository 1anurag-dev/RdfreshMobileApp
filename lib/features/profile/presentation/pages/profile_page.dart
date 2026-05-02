import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoadingAddress = true;
  bool _isSavingAddress = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadShippingAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadShippingAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _addressController.text = data['shippingAddress'] as String? ?? '';
        _cityController.text = data['shippingCity'] as String? ?? '';
        _stateController.text = data['shippingState'] as String? ?? '';
        _zipController.text = data['shippingZip'] as String? ?? '';
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingAddress = false);
  }

  Future<void> _saveShippingAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSavingAddress = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'shippingAddress': _addressController.text.trim(),
        'shippingCity': _cityController.text.trim(),
        'shippingState': _stateController.text.trim(),
        'shippingZip': _zipController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shipping address saved'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isSavingAddress = false);
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both password fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _currentPasswordController.clear();
      _newPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to change password'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) setState(() => _isChangingPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'RD Fresh User';
    final email = user?.email ?? '';
    final initials = name
        .split(RegExp(r'\s+|@'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildProfileHeader(context, name, email, initials),
            const SizedBox(height: AppSpacing.xl),
            _buildShippingAddressSection(context),
            const SizedBox(height: AppSpacing.xl),
            _buildChangePasswordSection(context),
            const SizedBox(height: AppSpacing.xxxl),
            _buildLogoutButton(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String email,
    String initials,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            child: Text(
              initials.isEmpty ? 'RD' : initials,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            name,
            style: AppTypography.headlineSmall.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: AppTypography.headlineMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_isLoadingAddress)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildField('Address', _addressController),
            const SizedBox(height: AppSpacing.base),
            _buildField('City', _cityController),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(child: _buildField('State', _stateController)),
                const SizedBox(width: AppSpacing.base),
                Expanded(child: _buildField('ZIP', _zipController)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.mdBr,
                ),
                child: ElevatedButton(
                  onPressed: _isSavingAddress ? null : _saveShippingAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdBr,
                    ),
                  ),
                  child: _isSavingAddress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'SAVE ADDRESS',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: AppRadius.baseBr,
        border: Border.all(color: context.borderColor),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: AppTypography.headlineMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildField(
            'Current Password',
            _currentPasswordController,
            obscure: true,
          ),
          const SizedBox(height: AppSpacing.base),
          _buildField(
            'New Password',
            _newPasswordController,
            obscure: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBr,
                ),
              ),
              child: _isChangingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Text(
                      'UPDATE PASSWORD',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());
        },
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          'LOG OUT',
          style: AppTypography.button.copyWith(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            constraints: const BoxConstraints(minHeight: 48),
            hintText: label,
          ),
        ),
      ],
    );
  }
}

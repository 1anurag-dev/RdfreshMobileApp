import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/models/designated_contact.dart';

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
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoadingAddress = true;
  bool _isSavingAddress = false;
  bool _isChangingPassword = false;
  bool _editingProfile = false;
  List<DesignatedContact> _designatedContacts = [];
  bool _isLoadingContacts = true;
  String? _profilePhotoUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadShippingAddress();
    _loadDesignatedContacts();
    _loadProfilePhoto();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
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
        final data = doc.data() ?? {};
        _addressController.text = data['shippingAddress'] as String? ?? '';
        _cityController.text = data['shippingCity'] as String? ?? '';
        _stateController.text = data['shippingState'] as String? ?? '';
        _zipController.text = data['shippingZip'] as String? ?? '';
        _phoneController.text = data['phone'] as String? ?? '';
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingAddress = false);
  }

  Future<void> _loadProfilePhoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final url = doc.data()?['profilePhotoUrl'] as String?;
      if (mounted && url != null && url.isNotEmpty) {
        setState(() => _profilePhotoUrl = url);
      }
    } catch (_) {}
  }

  Future<void> _pickProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    if (picked == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'profilePhotoUrl': url},
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() {
          _profilePhotoUrl = url;
          _isUploadingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        AppToast.show(context, message: 'Failed to update photo. Please try again.', type: ToastType.error);
      }
    }
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
        'phone': _phoneController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() => _editingProfile = false);
        AppToast.show(context, message: 'Profile updated');
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(context, message: 'Unable to save. Check your connection.', type: ToastType.error);
      }
    }
    if (mounted) setState(() => _isSavingAddress = false);
  }

  Future<void> _loadDesignatedContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final rawContacts = data['designatedContacts'] as List<dynamic>? ?? [];
        _designatedContacts = rawContacts
            .map((c) =>
                DesignatedContact.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList();
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingContacts = false);
  }

  Future<void> _saveDesignatedContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'designatedContacts':
            _designatedContacts.map((c) => c.toJson()).toList(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (mounted) {
        AppToast.show(context,
            message: 'Failed to save contacts', type: ToastType.error);
      }
    }
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Escalation Contact',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final email = emailCtrl.text.trim();
              if (name.isEmpty || email.isEmpty) {
                AppToast.show(context,
                    message: 'Please fill in both fields',
                    type: ToastType.error);
                return;
              }
              Navigator.of(ctx).pop();
              setState(() {
                _designatedContacts
                    .add(DesignatedContact(name: name, email: email));
              });
              _saveDesignatedContacts();
              AppToast.show(context, message: 'Contact added');
            },
            child: const Text('Add',
                style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _removeContact(int index) {
    setState(() => _designatedContacts.removeAt(index));
    _saveDesignatedContacts();
    AppToast.show(context, message: 'Contact removed');
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      AppToast.show(context, message: 'Please fill in both password fields', type: ToastType.error);
      return;
    }

    if (newPassword.length < 6) {
      AppToast.show(context, message: 'New password must be at least 6 characters', type: ToastType.error);
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        if (mounted) {
          AppToast.show(context, message: 'Please sign in again to change your password', type: ToastType.error);
        }
        if (mounted) setState(() => _isChangingPassword = false);
        return;
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _currentPasswordController.clear();
      _newPasswordController.clear();

      if (mounted) {
        AppToast.show(context, message: 'Password changed successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'wrong-password':
            message = 'Current password is incorrect';
            break;
          case 'weak-password':
            message = 'New password is too weak';
            break;
          case 'requires-recent-login':
            message = 'Please sign out and sign in again first';
            break;
          default:
            message = 'Failed to change password';
        }
        AppToast.show(context, message: message, type: ToastType.error);
      }
    }

    if (mounted) setState(() => _isChangingPassword = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text(
              'Yes, Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated || state is AccountDeleted) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: AutoSizeText(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
          centerTitle: false,
          iconTheme: IconThemeData(color: context.textPrimary),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            children: [
              _buildProfileHeader(name, email, initials),
              const SizedBox(height: 24),
              if (_editingProfile) ...[
                _buildEditProfileSection(),
                const SizedBox(height: 20),
              ],
              _buildMenuSection(),
              const SizedBox(height: 20),
              _buildAccountManagementSection(),
              const SizedBox(height: 20),
              _buildEscalationContactsSection(),
              const SizedBox(height: 20),
              _buildPasswordSection(),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 20),
              if (email == 'devanurag96@gmail.com' || email == 'mike@rdfresh.com')
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildAdminSection(),
                ),
              _buildLegalSection(),
              const SizedBox(height: 28),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickProfilePhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      AppColors.primaryGreen.withValues(alpha: 0.1),
                  backgroundImage: _profilePhotoUrl != null
                      ? NetworkImage(_profilePhotoUrl!)
                      : null,
                  child: _profilePhotoUrl != null
                      ? null
                      : AutoSizeText(
                          initials.isEmpty ? 'RD' : initials,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                          maxLines: 1,
                          minFontSize: 14,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AutoSizeText(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
            minFontSize: 14,
          ),
          const SizedBox(height: 2),
          AutoSizeText(
            email,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
            ),
            maxLines: 1,
            minFontSize: 10,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AutoSizeText(
              'Business Account',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => setState(() => _editingProfile = !_editingProfile),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: AutoSizeText(
                _editingProfile ? 'Cancel Editing' : 'Edit Profile',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Shipping Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          if (_isLoadingAddress)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildField('Address', _addressController),
            const SizedBox(height: 12),
            _buildField('City', _cityController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField('State', _stateController)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('ZIP', _zipController)),
              ],
            ),
            const SizedBox(height: 12),
            _buildField('Phone', _phoneController),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isSavingAddress ? null : _saveShippingAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : const AutoSizeText(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            label: 'My Orders',
            onTap: () => context.push(AppRoutes.activeOrders),
          ),
          Divider(height: 1, color: context.borderColor.withValues(alpha: 0.3)),
          _MenuTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationContactsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Escalation Contacts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Notified if bags aren\'t changed within 5 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_designatedContacts.length < 5)
                GestureDetector(
                  onTap: _showAddContactDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: AppColors.primaryGreen, size: 20),
                  ),
                ),
            ],
          ),
          if (_isLoadingContacts)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primaryGreen),
                ),
              ),
            )
          else if (_designatedContacts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.group_add_rounded,
                        color: context.textTertiary, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'No contacts added yet',
                      style: TextStyle(
                          fontSize: 13, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_designatedContacts.length, (i) {
              final contact = _designatedContacts[i];
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.1),
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              contact.email,
                              style: TextStyle(
                                  fontSize: 12, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeContact(i),
                        child: Icon(Icons.close_rounded,
                            color: context.textTertiary, size: 20),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Change Password',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          _buildField('Current Password', _currentPasswordController,
              obscure: true),
          const SizedBox(height: 12),
          _buildField('New Password', _newPasswordController, obscure: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
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
                  : const AutoSizeText(
                      'Update Password',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'About RD Fresh',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          Text(
            'RD Fresh provides natural zeolite mineral packs for commercial refrigeration. '
            'Our FDA-approved technology absorbs ethylene gas, extending food shelf life by up to 50% '
            'in walk-in coolers, produce drawers, and prep stations.',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Admin Tools',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _runUserMigration,
              icon: const Icon(Icons.sync_rounded,
                  color: AppColors.warning, size: 18),
              label: const Text('Migrate Users to Firebase Auth'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.warning),
                foregroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runUserMigration() async {
    AppToast.show(context, message: 'Running migration...', type: ToastType.info);
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('migrateUsersToFirebaseAuth');
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? [];
      final created =
          results.where((r) => r['status'] == 'created').length;
      final existing =
          results.where((r) => r['status'] == 'already_exists').length;

      if (mounted) {
        AppToast.show(context,
            message:
                'Migration done: $created created, $existing already existed');
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context,
            message: 'Migration failed: $e', type: ToastType.error);
      }
    }
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: _showLogoutDialog,
        child: const AutoSizeText(
          'Log Out',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.privacy_tip_rounded,
            label: 'Privacy Policy',
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          Divider(height: 1, color: context.borderColor.withValues(alpha: 0.3)),
          _MenuTile(
            icon: Icons.description_rounded,
            label: 'Terms of Service',
            onTap: () => context.push(AppRoutes.termsOfService),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: AutoSizeText(
            'Account Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            maxLines: 1,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever_rounded, size: 22),
            label: const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AccountDeleted) {
            Navigator.of(ctx).pop();
            GoRouter.of(context).go(AppRoutes.login);
          }
          if (state is AuthError) {
            AppToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (ctx, state) {
          final isLoading = state is AuthLoading;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This will permanently delete your account and all associated data. This action cannot be undone.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Enter your password to confirm',
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          AppToast.show(context, message: 'Please enter your password', type: ToastType.error);
                          return;
                        }
                        context.read<AuthBloc>().add(DeleteAccountRequested(password: password));
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Delete My Account', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            constraints: const BoxConstraints(minHeight: 44),
            hintText: label,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: AutoSizeText(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
        maxLines: 1,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

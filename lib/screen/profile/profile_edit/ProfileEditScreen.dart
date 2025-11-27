import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_cubit.dart';
import 'profile_edit_cubit.dart';

class ProfileEditScreen extends StatefulWidget {
  static const String route = "ProfileEditScreen";

  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem ProfileCubit đã được cung cấp chưa
    // Nếu chưa có, tạo mới (fallback cho trường hợp navigate bằng route name mà routes.dart không wrap)
    try {
      // Thử đọc ProfileCubit từ context
      context.read<ProfileCubit>();
      // Nếu có sẵn, dùng trực tiếp
      return const _ProfileEditContent();
    } catch (e) {
      // Nếu không có, tạo mới (fallback)
      return BlocProvider(
        create: (_) => ProfileCubit()..loadProfile(),
        child: const _ProfileEditContent(),
      );
    }
  }
}

// Tách phần content ra widget riêng để tránh lỗi context
class _ProfileEditContent extends StatefulWidget {
  const _ProfileEditContent();

  @override
  State<_ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends State<_ProfileEditContent> {
  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    bioCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        // Update controllers khi state thay đổi
        if (profileState is ProfileLoaded) {
          // Update ngay lập tức nếu cần
          if (nameCtrl.text != profileState.user.name) {
            nameCtrl.text = profileState.user.name;
          }
          if (bioCtrl.text != (profileState.user.bio ?? "")) {
            bioCtrl.text = profileState.user.bio ?? "";
          }
        }

        return BlocProvider(
          create: (_) => ProfileEditCubit(),
          child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
            listener: (context, state) {
              if (state is ProfileEditSuccess) {
                // Refresh profile và quay lại
                context.read<ProfileCubit>().loadProfile();
                Navigator.pop(context);
              } else if (state is ProfileEditError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 8),
                    action: SnackBarAction(
                      label: 'Đóng',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<ProfileEditCubit>();
              final currentProfileState = context.read<ProfileCubit>().state;

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Chỉnh sửa thông tin",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark 
                                  ? const Color(0xFF2F2F2F)
                                  : const Color(0xFFDBDBDB),
                              width: 2,
                            ),
                          ),
                            child: ClipOval(
                            child: cubit.selectedImage != null
                                ? Image.file(
                                    cubit.selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (currentProfileState is ProfileLoaded &&
                                        currentProfileState.user.avatarUrl != null &&
                                        currentProfileState.user.avatarUrl!.isNotEmpty)
                                    ? Image.network(
                                        currentProfileState.user.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 60,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 60,
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (picked != null) {
                                cubit.pickImage(File(picked.path));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Input
                  _InputBox(
                    controller: nameCtrl,
                    label: "Tên hiển thị",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Bio Input
                  _InputBox(
                    controller: bioCtrl,
                    label: "Giới thiệu",
                    maxLines: 4,
                    icon: Icons.description_outlined,
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state is ProfileEditSaving
                          ? null
                          : () {
                              if (nameCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Vui lòng nhập tên"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              cubit.saveProfile(
                                name: nameCtrl.text.trim(),
                                bio: bioCtrl.text.trim(),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      child: state is ProfileEditSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Lưu thay đổi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
            },
          ),
        );
      },
    );
  }
}

// --- Custom Input UI ---
class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final IconData? icon;

  const _InputBox({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF2F2F2F)
              : const Color(0xFFDBDBDB),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

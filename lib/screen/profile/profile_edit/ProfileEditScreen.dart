import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../profile_cubit.dart';
import 'profile_edit_cubit.dart';

class ProfileEditScreen extends StatelessWidget {
  static const String route = "ProfileEditScreen";

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController bioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      nameCtrl.text = profileState.user.name;
      bioCtrl.text = profileState.user.bio ?? "";
    }

    return BlocProvider(
      create: (_) => ProfileEditCubit(),
      child: BlocConsumer<ProfileEditCubit, ProfileEditState>(
        listener: (context, state) {
          if (state is ProfileEditSuccess) {
            Navigator.pop(context);
            context.read<ProfileCubit>().loadProfile();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileEditCubit>();

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: Text("Chỉnh sửa thông tin"),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // --- Avatar ZALO Style ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: cubit.selectedImage != null
                              ? FileImage(cubit.selectedImage!)
                              : (profileState is ProfileLoaded && profileState.user.avatarUrl != null
                              ? NetworkImage(profileState.user.avatarUrl!) as ImageProvider
                              : null),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) cubit.pickImage(File(picked.path));
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- Input ZALO Style ---
                  _InputBox(
                    controller: nameCtrl,
                    label: "Tên hiển thị",
                  ),
                  SizedBox(height: 16),

                  _InputBox(
                    controller: bioCtrl,
                    label: "Giới thiệu",
                    maxLines: 3,
                  ),

                  SizedBox(height: 30),

                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is ProfileEditSaving
                          ? null
                          : () => cubit.saveProfile(name: nameCtrl.text, bio: bioCtrl.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: state is ProfileEditSaving
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Lưu thay đổi", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Custom Input UI ---
class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _InputBox({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

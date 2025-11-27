import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_cubit.dart';
import 'profile_edit/ProfileEditScreen.dart';

class ProfileScreen extends StatefulWidget {
  static const String route = "ProfileScreen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // Có thể thêm snackbar nếu cần
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            
            if (state is ProfileLoading) {
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.surface,
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            }
            if (state is ProfileError) {
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.surface,
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                body: Center(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            if (state is ProfileLoaded) {
              final user = state.user;
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: theme.colorScheme.surface,
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () async {
                        // Pass ProfileCubit qua BlocProvider.value
                        final profileCubit = context.read<ProfileCubit>();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (editContext) => BlocProvider.value(
                              value: profileCubit,
                              child: const ProfileEditScreen(),
                            ),
                          ),
                        );
                        // Refresh profile sau khi quay lại
                        if (mounted) {
                          context.read<ProfileCubit>().loadProfile();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      // Avatar
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
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
                            child: user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Center(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              user.bio!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

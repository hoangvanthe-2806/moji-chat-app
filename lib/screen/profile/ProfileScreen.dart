import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_cubit.dart';
import 'profile_edit/ProfileEditScreen.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = "ProfileScreen";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            return Scaffold(
              appBar: AppBar(
                title: Text("Profile"),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(context, ProfileEditScreen.route),
                  )
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 50, backgroundImage: user.avatarUrl?.isNotEmpty == true
                      ? NetworkImage(user.avatarUrl!)
                      : null),
                  SizedBox(height: 16),
                  Text(user.name, style: TextStyle(fontSize: 22)),
                  if (user.bio != null) Text(user.bio!),
                ],
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}

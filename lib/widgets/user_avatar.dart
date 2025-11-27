import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final bool isOnline;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.size = 56,
    this.isOnline = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBorderColor = isDark 
        ? const Color(0xFF2F2F2F)
        : const Color(0xFFDBDBDB);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor ?? defaultBorderColor,
              width: 0.5,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark 
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          color: isDark 
                              ? Colors.grey.shade400
                              : Colors.grey,
                          size: size * 0.6,
                        ),
                      );
                    },
                  )
                : Container(
                    color: isDark 
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: isDark 
                          ? Colors.grey.shade400
                          : Colors.grey,
                      size: size * 0.6,
                    ),
                  ),
          ),
        ),
        // Online indicator
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Green for online
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


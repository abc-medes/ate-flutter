// ... existing code ...
import 'package:flutter/material.dart';
import 'package:ate_project/theme/colors.dart';

class EmailSentStep extends StatelessWidget {
  final String title;
  final String description;
  final String nextStepsTitle;
  final List<String> nextSteps;
  final String resendButtonText;
  final VoidCallback? onResend;
  final String backToLoginText;
  final VoidCallback? onBackToLogin;
  final bool isLoading;
  final String? email;

  const EmailSentStep({
    super.key,
    required this.title,
    required this.description,
    required this.nextStepsTitle,
    required this.nextSteps,
    required this.resendButtonText,
    required this.onResend,
    required this.backToLoginText,
    required this.onBackToLogin,
    this.isLoading = false,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Icon(
            Icons.email_outlined,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextStepsTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...nextSteps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$idx. ',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      Expanded(
                        child: Text(
                          step,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : onResend,
            child: Text(
              resendButtonText,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: onBackToLogin,
            child: Text(
              backToLoginText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

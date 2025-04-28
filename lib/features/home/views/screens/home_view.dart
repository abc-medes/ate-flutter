import 'package:ate_project/core/widgets/chat_input.dart';
import 'package:ate_project/core/widgets/typewriter_animated_text.dart';
import 'package:ate_project/features/home/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: state.messages.isEmpty
            ? _buildEmptyChatView(context, viewModel)
            : _buildChatView(context, state, viewModel),
      ),
    );
  }

  Widget _buildEmptyChatView(BuildContext context, HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated typing text
          const TypewriterAnimatedText(
            [
              "AI-Powered Health Intelligence",
              "Personal Health Assistant",
              "Get Smart Insights",
            ],
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          // Search bar
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const ChatInput(),
          ),

          const SizedBox(height: 40),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChatView(
      BuildContext context, HomeViewState state, HomeViewModel viewModel) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: viewModel.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: message.isUser
                    ? _buildUserMessage(context, message.text)
                    : _buildAIMessage(context, message.text),
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ChatInput(),
        ),
      ],
    );
  }

  Widget _buildUserMessage(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Text(
                text,
                style: const TextStyle(height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

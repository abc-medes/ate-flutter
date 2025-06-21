import 'package:ate_project/common_libs.dart';
import 'package:ate_project/core/routes/route_names.dart';
import 'package:ate_project/theme/app_theme.dart';
import 'package:ate_project/core/widgets/chat_input.dart';
import 'package:ate_project/core/widgets/typewriter_animated_text.dart';
import 'package:ate_project/features/home/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider.notifier);
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuint,
                )),
                child: child,
              ),
            );
          },
          child: state.messages.isEmpty
              ? _buildEmptyChatView(context, state, viewModel)
              : _buildChatView(context, state, viewModel, ref),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final prefs = await SharedPreferences.getInstance();
      //     await prefs.remove('health_metrics');
      //     // context.go(RouteNames.settings);
      //   },
      //   child: const Icon(Icons.bug_report),
      // ),
    );
  }

  Widget _buildEmptyChatView(
      BuildContext context, HomeViewState state, HomeViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated typing text
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 40,
            child: TypewriterAnimatedText(
              [
                "AI-Powered Health Intelligence",
                "Personal Health Assistant",
                "Get Smart Insights",
              ],
              textStyle: $styles.text.body,
            ),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 8.0, 16.0, 8.0), // Added padding
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                minimumSize: const Size(double.infinity, 48), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                context.go(RouteNames.bodySimulator);
              },
              child: const Text('Check Body Simulator',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

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
            child: ChatInput(
              shouldSaveAsContext: state.isSaveMode,
              onSaveModeToggle: () => viewModel.onSaveModeToggle(),
              onSubmit: (text, images) {
                if (text.isNotEmpty) {
                  viewModel.textController.text = text;
                  if (state.isSaveMode) {
                    viewModel.handleMemorize(context);
                  } else {
                    viewModel.handleChatSubmit();
                  }
                }
              },
              onChanged: (_) => viewModel.scrollToBottom(),
            ),
          ),

          const SizedBox(height: 40),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChatView(BuildContext context, HomeViewState state,
      HomeViewModel viewModel, WidgetRef ref) {
    return Column(
      children: [
        // Message list
        Expanded(
          child: ListView.builder(
            controller: viewModel.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              if (state.isProcessing && index == state.messages.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTypingIndicator(context),
                );
              }
              final message = state.messages[index];
              bool isLatestUserMessage = message.isUser &&
                  index ==
                      state.messages.length -
                          2 && // User message before AI placeholder
                  state.messages.length >
                      1 && // Ensure there's at least a user and AI placeholder
                  !state.messages.last.isUser;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: message.isUser
                    ? _buildUserMessage(
                        context,
                        message.text,
                        isLatestUserMessage
                            ? viewModel.userCurrentMessageKey
                            : null,
                      )
                    : _buildAIMessage(context, message.text),
              );
            },
          ),
        ),

        if (state.messages.isNotEmpty &&
            !state.messages.last.isUser &&
            !state.isProcessing)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 8.0, 16.0, 8.0), // Added padding
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                minimumSize: const Size(double.infinity, 48), // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                context.go(RouteNames.bodySimulator);
              },
              child: const Text('Check Body Simulator',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ChatInput(
            shouldSaveAsContext: state.isSaveMode,
            onSaveModeToggle: () => viewModel.onSaveModeToggle(),
            controller: viewModel.textController,
            onChanged: (_) => viewModel.scrollToBottom(),
            onSubmit: (text, images) {
              if (text.isNotEmpty) {
                viewModel.textController.text = text;
                if (state.isSaveMode) {
                  viewModel.handleMemorize(context);
                } else {
                  viewModel.handleChatSubmit();
                }
              }
            },
            isDisabled: state.isProcessing,
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(BuildContext context, String text, Key? messageKey) {
    return Align(
      alignment: Alignment.centerRight,
      key: messageKey,
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
        child: Text(
          text,
          style: const TextStyle(height: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            _buildDot(context, 0),
            _buildDot(context, 1),
            _buildDot(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: ((value + (index * 0.33)) % 1) < 0.5 ? 0.4 : 1.0,
            child: child,
          );
        },
        child: Container(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String, List<String>)? onSubmit;

  const ChatInput({
    super.key,
    this.onSubmit,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _chatInputController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  bool _isFocused = false;
  List<String> _selectedImages = [];

  // Animation controller for more control
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _chatFocusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100), // Slow animation
      vsync: this,
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Smooth curve
      ),
    );
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _chatFocusNode.removeListener(_onFocusChange);
    _chatFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _chatFocusNode.hasFocus;
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleImageSelection() async {
    setState(() {
      _selectedImages.add("image_${_selectedImages.length + 1}");
    });
  }

  void _handleSubmit() {
    final text = _chatInputController.text;
    if (text.trim().isEmpty && _selectedImages.isEmpty) return;

    if (widget.onSubmit != null) {
      widget.onSubmit!(text, _selectedImages);
    }

    _chatInputController.clear();
    setState(() {
      _selectedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected images preview
        if (_isFocused && _selectedImages.isNotEmpty)
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Text(
                          "Image ${index + 1}",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Animated chat input with border transition
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            final containerBorderWidth = _borderAnimation.value * 2.0;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: containerBorderWidth,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input field
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, _borderAnimation.value > 0.5 ? 0 : 8),
                    child: TextField(
                      controller: _chatInputController,
                      focusNode: _chatFocusNode,
                      maxLines: null, // Allow multiple lines
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Ask a health question...',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                        contentPadding: EdgeInsets.zero,
                        // Remove all borders
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                  ),

                  // Animated bottom action buttons
                  ClipRect(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: _borderAnimation.value *
                          56.0, // Expand height when focused
                      child: Opacity(
                        opacity: _borderAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.image,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: _handleImageSelection,
                                tooltip: 'Add image',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: _handleSubmit,
                                tooltip: 'Send message',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

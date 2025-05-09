import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String, List<String>)? onSubmit;
  final Function(String)? onChanged;
  final bool isDisabled;
  final TextEditingController? controller;

  const ChatInput({
    super.key,
    this.onSubmit,
    this.onChanged,
    this.controller,
    this.isDisabled = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _chatInputController;
  final FocusNode _chatFocusNode = FocusNode();
  List<String> _selectedImages = [];
  bool _shouldSaveAsContext = false;

  @override
  void initState() {
    super.initState();
    _chatInputController = widget.controller ?? TextEditingController();
    _chatInputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_chatInputController.text);
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _chatInputController.removeListener(_onTextChanged);
      _chatInputController.dispose();
    }
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _handleImageSelection() async {
    setState(() {
      _selectedImages.add("image_${_selectedImages.length + 1}");
    });
  }

  void _handleSubmit() {
    if (widget.isDisabled) return;
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
        if (_selectedImages.isNotEmpty)
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

        // Chat input (always expanded)
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _shouldSaveAsContext
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text input field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _chatInputController,
                  focusNode: _chatFocusNode,
                  maxLines: 5,
                  minLines: 1,
                  cursorColor: _shouldSaveAsContext
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: _shouldSaveAsContext
                        ? 'Tell me what you want to remember...'
                        : 'How was your health day?',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                    contentPadding: EdgeInsets.zero,
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

              // Action buttons (always visible)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _shouldSaveAsContext
                                ? Icons.save
                                : Icons.save_outlined,
                            color: _shouldSaveAsContext
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() {
                              _shouldSaveAsContext = !_shouldSaveAsContext;
                            });
                          },
                          tooltip: _shouldSaveAsContext
                              ? 'Saving as context'
                              : 'Save as temporary chat',
                        ),
                        if (!_shouldSaveAsContext)
                          IconButton(
                            icon: Icon(
                              Icons.image,
                              color: _shouldSaveAsContext
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _handleImageSelection,
                            tooltip: 'Add image',
                          ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _shouldSaveAsContext
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _handleSubmit,
                      tooltip: 'Send message',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

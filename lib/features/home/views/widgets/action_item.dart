import 'package:flutter/material.dart';

class ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showInputOnTap;

  const ActionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.showInputOnTap = false,
  });

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  bool _isExpanded = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(widget.label),
          onTap: widget.showInputOnTap
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                }
              : widget.onTap,
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Enter ${widget.label.toLowerCase()} details',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Later can handle the input
                      if (widget.onTap != null) {
                        widget.onTap!();
                      }
                      setState(() {
                        _isExpanded = false;
                      });
                      _textController.clear();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:bodai/common_libs.dart';
import 'package:bodai/features/home/view_models/home_view_model.dart';

class ChatHelper extends StatelessWidget {
  final ChatHelperType? selectedChip;
  final Function(ChatHelperType) onChipSelected;

  const ChatHelper({
    super.key,
    required this.selectedChip,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.md,
        vertical: $styles.insets.xs,
      ),
      child: Row(
        children: [
          _HelperChip(
            icon: Icons.auto_awesome_outlined,
            label: 'AI suggestions',
            isSelected: selectedChip == ChatHelperType.ai,
            onTap: () => onChipSelected(ChatHelperType.ai),
          ),
          SizedBox(width: $styles.insets.sm),
          _HelperChip(
            icon: Icons.warning_amber_rounded,
            label: 'Body Alerts',
            isSelected: selectedChip == ChatHelperType.alerts,
            onTap: () => onChipSelected(ChatHelperType.alerts),
            color: $styles.colors.accent3,
          ),
          SizedBox(width: $styles.insets.sm),
          _HelperChip(
            icon: Icons.hourglass_empty_outlined,
            label: '', // Empty label as requested
            isSelected: selectedChip == ChatHelperType.waitlist,
            onTap: () => onChipSelected(ChatHelperType.waitlist),
          ),
          SizedBox(width: $styles.insets.sm),
          _HelperChip(
            icon: Icons.health_and_safety_outlined,
            label: '신체 계통 선택',
            isSelected: selectedChip == ChatHelperType.system,
            onTap: () => onChipSelected(ChatHelperType.system),
          ),
          SizedBox(width: $styles.insets.sm),
          _HelperChip(
            icon: Icons.biotech_outlined,
            label: 'Current health context',
            isSelected: selectedChip == ChatHelperType.context,
            onTap: () => onChipSelected(ChatHelperType.context),
          ),
        ],
      ),
    );
  }
}

/// A private reusable chip widget for the ChatHelper.
class _HelperChip extends StatelessWidget {
  const _HelperChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? $styles.colors.accent1;

    // Determine colors based on selection state
    final bgColor = isSelected ? chipColor : chipColor.withOpacity(0.1);
    final contentColor = isSelected ? $styles.colors.white : chipColor;
    final borderColor = isSelected ? chipColor : chipColor.withOpacity(0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: $styles.insets.sm,
          vertical: $styles.insets.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: contentColor, size: 18),
            if (label.isNotEmpty) ...[
              SizedBox(width: $styles.insets.xs),
              Text(
                label,
                style: $styles.text.bodySmall.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

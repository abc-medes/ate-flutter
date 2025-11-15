import 'package:bodido/common_libs.dart';
import 'package:bodido/core/widgets/app_button.dart';
import 'package:bodido/features/auth/views/widgets/_policy_viewer_sheet.dart';

class TermsConsentSheet extends StatefulWidget {
  final Uri termsUrl;
  final Uri privacyUrl;
  final String title;
  final String description;
  final String confirmLabel;

  const TermsConsentSheet({
    super.key,
    required this.termsUrl,
    required this.privacyUrl,
    this.title = 'Terms & Privacy',
    this.description =
        'Before continuing, please review and accept our Terms of Service and Privacy Policy.',
    this.confirmLabel = 'Accept and Continue',
  });

  static Future<bool?> show(
    BuildContext context, {
    required Uri termsUrl,
    required Uri privacyUrl,
    String? title,
    String? description,
    String? confirmLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular($styles.corners.md)),
      ),
      builder: (_) => TermsConsentSheet(
        termsUrl: termsUrl,
        privacyUrl: privacyUrl,
        title: title ?? $strings.termsTitle,
        description: description ?? $strings.termsDescription,
        confirmLabel: confirmLabel ?? $strings.termsAcceptAndContinue,
      ),
    );
  }

  @override
  State<TermsConsentSheet> createState() => _TermsConsentSheetState();
}

class _TermsConsentSheetState extends State<TermsConsentSheet> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    final canContinue = _acceptedTerms && _acceptedPrivacy;

    return SafeArea(
      top: false,
      child: Container(
        color: $styles.colors.background,
        padding: EdgeInsets.all($styles.insets.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.title,
              style: $styles.text.h3.copyWith(color: $styles.colors.accent1),
            ),
            SizedBox(height: $styles.insets.sm),

            // Description
            Text(
              widget.description,
              style:
                  $styles.text.bodySmall.copyWith(color: $styles.colors.body),
            ),
            SizedBox(height: $styles.insets.lg),

            // Terms checkbox + link
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    checkboxTheme: const CheckboxThemeData(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                    ),
                  ),
                  child: Transform.scale(
                    scale: 1.25,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) =>
                          setState(() => _acceptedTerms = v ?? false),
                      activeColor: $styles.colors.accent1,
                      checkColor: $styles.colors.white,
                      side: BorderSide(
                          color: $styles.colors.greyMedium, width: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                SizedBox(width: $styles.insets.xs),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: $styles.text.bodySmall.copyWith(
                        fontSize: ($styles.text.bodySmall.fontSize ?? 16) + 2,
                        color: $styles.colors.black,
                      ),
                      children: [
                        TextSpan(text: $strings.iAgreeTo),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () => PolicyViewerSheet.show(
                              context,
                              title: $strings.termsOfService,
                              assetPath: 'assets/legal/terms_en.txt',
                            ),
                            child: Text(
                              $strings.termsOfService, // or 'Privacy Policy'
                              style: $styles.text.bodySmall.copyWith(
                                fontSize:
                                    ($styles.text.bodySmall.fontSize ?? 16) + 2,
                                color: $styles.colors.accent1,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: $styles.insets.md),

            // Privacy checkbox + link
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    checkboxTheme: const CheckboxThemeData(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                    ),
                  ),
                  child: Transform.scale(
                    scale: 1.25,
                    child: Checkbox(
                      value: _acceptedPrivacy,
                      onChanged: (v) =>
                          setState(() => _acceptedPrivacy = v ?? false),
                      activeColor: $styles.colors.accent1,
                      checkColor: $styles.colors.white,
                      side: BorderSide(
                          color: $styles.colors.greyMedium, width: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                SizedBox(width: $styles.insets.xs),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: $styles.text.bodySmall
                          .copyWith(color: $styles.colors.black),
                      children: [
                        TextSpan(text: $strings.iAgreeTo),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () => PolicyViewerSheet.show(
                              context,
                              title: $strings.privacyPolicy,
                              assetPath: 'assets/legal/privacy_en.txt',
                            ),
                            child: Text(
                              $strings.privacyPolicy,
                              style: $styles.text.bodySmall.copyWith(
                                color: $styles.colors.accent1,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: $styles.insets.md),

            AppButton(
              label: widget.confirmLabel,
              onPressed:
                  canContinue ? () => Navigator.of(context).pop(true) : null,
            ),
          ],
        ),
      ),
    );
  }
}

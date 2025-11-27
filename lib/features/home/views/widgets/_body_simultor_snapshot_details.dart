import 'dart:async';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/services/api_service.dart';
import 'package:bodido/core/services/session_service.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/insight_model.dart';
import 'package:bodido/features/home/views/widgets/_animated_metric_value.dart';
import 'package:bodido/features/home/views/widgets/insight_card.dart';
import 'package:bodido/features/home/views/widgets/medical_disclaimer_banner.dart';

class BodySimulatorSnapshotDetails extends ConsumerStatefulWidget {
  final String userId;
  final List<InsightItem> insights;
  const BodySimulatorSnapshotDetails(
      {super.key, required this.userId, required this.insights});

  @override
  ConsumerState<BodySimulatorSnapshotDetails> createState() =>
      _BodySimulatorSnapshotDetailsState();
}

class _BodySimulatorSnapshotDetailsState
    extends ConsumerState<BodySimulatorSnapshotDetails> {
  StreamSubscription<BodySimulatorStateSnapshotDTO?>? _subscription;
  BodySimulatorStateSnapshotDTO? _bodyState;
  bool _isLoading = true;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _initializeBodyStateStream();
  }

  void _initializeBodyStateStream() {
    final sessionId = ref.read(sessionIdProvider);

    try {
      _subscription = ApiService.bodyStateStream(sessionId: sessionId).listen(
        (state) {
          debugPrint('  Body-state update → ${state.toJson()}');
          if (mounted) {
            setState(() {
              _bodyState = state;
              _isLoading = false;
              _errorMessage = null;
              _retryCount = 0; // Reset retry count on success
            });
          }
        },
        onError: (err) {
          debugPrint('WS error: $err');
          if (mounted) {
            setState(() {
              _errorMessage = '연결 오류: ${err.toString()}';
              _isLoading = false;
            });

            // Attempt to retry with exponential backoff
            if (_retryCount < _maxRetries) {
              _retryCount++;
              Future.delayed(Duration(seconds: _retryCount * 2), () {
                if (mounted) {
                  _initializeBodyStateStream();
                }
              });
            }
          }
        },
        onDone: () {
          debugPrint('WS connection closed');
          if (mounted && _bodyState == null) {
            setState(() {
              _isLoading = false;
              _errorMessage = '연결이 종료되었습니다.';
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize body state stream: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '스트림 초기화 실패: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: $styles.colors.background,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular($styles.insets.lg),
        topRight: Radius.circular($styles.insets.lg),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: $styles.colors.caption,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all($styles.insets.lg),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            $styles.colors.accent1),
                      ),
                      SizedBox(height: $styles.insets.md),
                      Text(
                        $strings.bs_loading,
                        style: $styles.text.body,
                      ),
                    ],
                  ),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.all($styles.insets.lg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: $styles.colors.error,
                      ),
                      SizedBox(height: $styles.insets.md),
                      Text(
                        _errorMessage!,
                        style: $styles.text.body,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: $styles.insets.md),
                      if (_retryCount < _maxRetries)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _initializeBodyStateStream();
                          },
                          child: Text($strings.action_retry),
                        ),
                    ],
                  ),
                )
              else if (_bodyState != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: $styles.insets.md),
                  child: TabBar(
                    labelColor: $styles.colors.accent1,
                    unselectedLabelColor: $styles.colors.caption,
                    labelStyle: $styles.text.bodyBold.copyWith(fontSize: 16),
                    unselectedLabelStyle:
                        $styles.text.body.copyWith(fontSize: 16),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: $styles.colors.accent1,
                    tabs: [
                      Tab(text: $strings.tab_overview, height: 24),
                      Tab(text: $strings.tab_highlights, height: 24),
                      Tab(text: $strings.tab_metrics, height: 24),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: $styles.insets.md,
                    vertical: $styles.insets.sm,
                  ),
                  child: const MedicalDisclaimerBanner(),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Overview
                      SingleChildScrollView(
                        controller: controller,
                        child: _buildOverviewPage(_bodyState!),
                      ),
                      // Highlights
                      SingleChildScrollView(
                        controller: controller,
                        child: _buildHighlightsPage(_bodyState!.healthScore),
                      ),
                      // Metrics
                      SingleChildScrollView(
                        controller: controller,
                        child: _buildMetricsPage(_bodyState!),
                      ),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: EdgeInsets.all($styles.insets.lg),
                  child: Text(
                    '데이터를 불러올 수 없습니다.',
                    style: $styles.text.body,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers --------------------------------------------------------

  Widget _sectionHeader(String title) => Padding(
        padding:
            EdgeInsets.only(top: $styles.insets.md, bottom: $styles.insets.xs),
        child: Text(title, style: $styles.text.bodyBold.copyWith(fontSize: 18)),
      );

  // removed old sliver-based analysis list (replaced with non-sliver pages)

  // removed old sliver-based organ section (replaced with non-sliver pages)

  Widget _sectionTitle(String text, double? score) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Row(
          children: [
            Text(text, style: $styles.text.bodyBold.copyWith(fontSize: 18)),
            SizedBox(width: $styles.insets.sm),
            if (score != null)
              AnimatedMetricValue(
                value: score,
              ),
          ],
        ),
      );

  Widget _metricTable(List<(String, double, bool, String)> rows) => Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth()},
        border: TableBorder(
          horizontalInside:
              BorderSide(color: $styles.colors.caption.withOpacity(.15)),
        ),
        children: rows
            .map(
              (r) => TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(r.$1), // label
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedMetricValue(
                    value: r.$2, // current number
                    isIncreaseGood: r.$3, // true/false
                    suffix: r.$4, // unit
                  ),
                ),
              ]),
            )
            .toList(),
      );

  // ---------- per-organ tables ----------------------------------------------
  Widget _brainTable(BrainData d) => _metricTable([
        ($strings.brain_stress_level, d.stressLevel, false, '%'),
        ($strings.brain_serotonin, d.serotonin, true, ''),
        ($strings.brain_sleep_rhythm, d.sleepRhythm, true, ' h'),
        ($strings.brain_cortisol, d.cortisol, false, ''),
      ]);

  Widget _heartTable(HeartData d) => _metricTable([
        ($strings.heart_blood_sugar, d.bloodSugar, false, ' mg/dL'),
        ($strings.heart_blood_pressure, d.bloodPressure, false, ' mmHg'),
        ($strings.heart_heart_rate, d.heartRate, false, ' bpm'),
        ($strings.heart_hrv, d.hrv, true, ' ms'),
      ]);

  Widget _lungsTable(LungsData d) => _metricTable([
        ($strings.lungs_o2_saturation, d.oxygenSaturation, true, '%'),
        ($strings.lungs_health_index, d.lungHealth, true, ''),
        ($strings.lungs_pm_exposure, d.pmExposure, false, ' μg/m³'),
        ($strings.lungs_respiratory_rate, d.respiratoryRate, false, ' bpm'),
      ]);

  Widget _liverTable(LiverData d) => _metricTable([
        ($strings.liver_detox_capacity, d.detoxCapacity, true, '%'),
        ($strings.liver_enzymes, d.liverEnzymes, false, ''),
        ($strings.liver_fat_processing, d.fatProcessing, true, '%'),
        ($strings.liver_alcohol_load, d.alcoholLoad, false, '%'),
      ]);

  Widget _stomachTable(StomachData d) => _metricTable([
        ($strings.stomach_digestion_speed, d.digestionSpeed, true, '%'),
        ($strings.stomach_acidity, d.acidity, false, ''),
        ($strings.stomach_nausea_risk, d.nauseaRisk, false, '%'),
        ($strings.stomach_food_retention, d.foodRetention, false, '%'),
      ]);

  Widget _intestinesTable(IntestinesData d) => _metricTable([
        (
          $strings.intestines_bacteria_diversity,
          d.gutBacteriaDiversity,
          true,
          '%'
        ),
        ($strings.intestines_inflammation, d.inflammation, false, '%'),
        ($strings.intestines_absorption_rate, d.absorptionRate, true, '%'),
        ($strings.intestines_gas_level, d.gasLevel, false, '%'),
      ]);

  Widget _kidneysTable(KidneysData d) => _metricTable([
        ($strings.kidneys_hydration, d.hydration, true, '%'),
        ($strings.kidneys_electrolyte_balance, d.electrolyteBalance, true, '%'),
        ($strings.kidneys_urea_clearance, d.ureaClearance, true, '%'),
        ($strings.kidneys_toxicity_load, d.toxicityLoad, false, '%'),
      ]);

  Widget _endocrineTable(EndocrineData d) => _metricTable([
        (
          $strings.endocrine_insulin_sensitivity,
          d.insulinSensitivity,
          true,
          '%'
        ),
        ($strings.endocrine_thyroid_function, d.thyroidFunction, true, '%'),
        ($strings.endocrine_et_ratio, d.estrogenTestosteroneRatio, false, ''),
      ]);

  Widget _nervousTable(NervousData d) => _metricTable([
        ($strings.nervous_focus_level, d.focusLevel, true, '%'),
        ($strings.nervous_mood_stability, d.moodStability, true, '%'),
        ($strings.nervous_anxiety_level, d.anxietyLevel, false, '%'),
        ($strings.nervous_neuro_flexibility, d.neuroFlexibility, true, '%'),
      ]);
}

// ------------------ Report Pages (non-sliver) --------------------------------
extension _ReportPages on _BodySimulatorSnapshotDetailsState {
  Widget _buildOverviewPage(BodySimulatorStateSnapshotDTO dto) {
    final hs = dto.healthScore;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text($strings.label_overall_score,
                  style: $styles.text.bodyBold.copyWith(fontSize: 18)),
              SizedBox(width: $styles.insets.sm),
              AnimatedMetricValue(value: hs.overallScore),
            ],
          ),
          SizedBox(height: $styles.insets.md),
          Text($strings.label_insights,
              style: $styles.text.bodyBold.copyWith(fontSize: 18)),
          SizedBox(height: $styles.insets.xs),
          Column(
            children: widget.insights
                .map((i) => Padding(
                      padding: EdgeInsets.only(bottom: $styles.insets.xs),
                      child: InsightCard(
                        icon: i.iconData,
                        title: i.title,
                        value: i.value,
                        advice: i.advice,
                        isGood: _isGoodValue(i.value),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: $styles.insets.md),
          Text($strings.label_organ_scores,
              style: $styles.text.bodyBold.copyWith(fontSize: 18)),
          SizedBox(height: $styles.insets.xs),
          Wrap(
            spacing: $styles.insets.xs,
            runSpacing: $styles.insets.xs,
            children: hs.organScores.entries
                .map((e) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: $styles.insets.xs,
                          vertical: $styles.insets.xxs),
                      decoration: BoxDecoration(
                        color: $styles.colors.backgroundDark,
                        borderRadius: BorderRadius.circular($styles.corners.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.key,
                              style: $styles.text.caption
                                  .copyWith(color: $styles.colors.body)),
                          SizedBox(width: $styles.insets.xs),
                          AnimatedMetricValue(value: e.value),
                        ],
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: $styles.insets.lg),
        ],
      ),
    );
  }

  Widget _buildHighlightsPage(BodyOverallScore hs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hs.strengths.isNotEmpty) ...[
            _sectionHeader($strings.label_strengths),
            SizedBox(height: $styles.insets.xs),
            _analysisListView(hs.strengths, accent: $styles.colors.accent1),
            SizedBox(height: $styles.insets.md),
          ],
          if (hs.concerns.isNotEmpty) ...[
            _sectionHeader($strings.label_concerns),
            SizedBox(height: $styles.insets.xs),
            _analysisListView(hs.concerns, accent: $styles.colors.warning),
          ],
          SizedBox(height: $styles.insets.lg),
        ],
      ),
    );
  }

  Widget _buildMetricsPage(BodySimulatorStateSnapshotDTO sbs) {
    final s = sbs.bodyState;
    final scores = sbs.healthScore.organScores;
    Widget block(String label, double? score, Widget? table) {
      if (table == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: $styles.insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(label, score),
            table,
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block($strings.organ_brain, scores['Brain'],
              s.brain != null ? _brainTable(s.brain!) : null),
          block($strings.organ_heart, scores['Heart'],
              s.heart != null ? _heartTable(s.heart!) : null),
          block($strings.organ_lungs, scores['Lungs'],
              s.lungs != null ? _lungsTable(s.lungs!) : null),
          block($strings.organ_liver, scores['Liver'],
              s.liver != null ? _liverTable(s.liver!) : null),
          block($strings.organ_stomach, scores['Stomach'],
              s.stomach != null ? _stomachTable(s.stomach!) : null),
          block($strings.organ_intestines, scores['Intestines'],
              s.intestines != null ? _intestinesTable(s.intestines!) : null),
          block($strings.organ_kidneys, scores['Kidneys'],
              s.kidneys != null ? _kidneysTable(s.kidneys!) : null),
          block($strings.organ_endocrine, scores['Endocrine'],
              s.endocrine != null ? _endocrineTable(s.endocrine!) : null),
          block($strings.organ_nervous, scores['Nervous'],
              s.nervous != null ? _nervousTable(s.nervous!) : null),
          SizedBox(height: $styles.insets.lg),
        ],
      ),
    );
  }

  Widget _analysisListView(List<HealthAnalysisItem> items,
      {required Color accent}) {
    return Column(
      children: items
          .map((item) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: $styles.insets.xs),
                padding: EdgeInsets.all($styles.insets.sm),
                decoration: BoxDecoration(
                  color: $styles.colors.backgroundDark,
                  borderRadius: BorderRadius.circular($styles.corners.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(right: $styles.insets.xs),
                          decoration: BoxDecoration(
                              color: accent, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(
                            '${item.organ} • ${item.score.toStringAsFixed(1)}',
                            style: $styles.text.bodyBold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: $styles.insets.xxs),
                    Text(item.summary,
                        style: $styles.text.bodySmall
                            .copyWith(color: $styles.colors.body)),
                    if (item.keyMetrics.isNotEmpty) ...[
                      SizedBox(height: $styles.insets.xxs),
                      Wrap(
                        spacing: $styles.insets.xs,
                        runSpacing: $styles.insets.xs,
                        children: item.keyMetrics
                            .map((m) => Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: $styles.insets.xs,
                                      vertical: $styles.insets.xxs),
                                  decoration: BoxDecoration(
                                    color: $styles.colors.backgroundDark,
                                    borderRadius: BorderRadius.circular(
                                        $styles.corners.sm),
                                  ),
                                  child: Text(m,
                                      style: $styles.text.caption.copyWith(
                                          color: $styles.colors.body)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ))
          .toList(),
    );
  }

  bool _isGoodValue(String v) {
    final s = v.toLowerCase();
    return s.contains('좋음') ||
        s.contains('양호') ||
        s.contains('good') ||
        s.contains('great') ||
        s.contains('excellent');
  }
}

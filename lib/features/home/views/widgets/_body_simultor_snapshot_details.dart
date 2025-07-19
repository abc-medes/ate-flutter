import 'dart:async';

import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/features/home/views/widgets/_animated_metric_value.dart';

class BodySimulatorSnapshotDetails extends ConsumerStatefulWidget {
  final String userId;
  const BodySimulatorSnapshotDetails({super.key, required this.userId});

  @override
  ConsumerState<BodySimulatorSnapshotDetails> createState() =>
      _BodySimulatorSnapshotDetailsState();
}

class _BodySimulatorSnapshotDetailsState
    extends ConsumerState<BodySimulatorSnapshotDetails> {
  StreamSubscription<SBBodySimulatorStateSnapshot?>? _subscription;
  SBBodySimulatorStateSnapshot? _bodyState;

  @override
  void initState() {
    super.initState();
    _subscription = ApiService.bodyStateStream().listen(
      (state) {
        debugPrint(
            '🩺  Body-state update → ${state.toJson()}'); // ← shows the model
        setState(() => _bodyState = state);
      },
      onError: (err) => debugPrint('WS error: $err'),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bodyState == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Material(
      color: $styles.colors.background,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular($styles.insets.lg),
        topRight: Radius.circular($styles.insets.lg),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.2,
        maxChildSize: 0.95,
        builder: (_, controller) => Padding(
          padding: EdgeInsets.symmetric(horizontal: $styles.insets.md),
          child: CustomScrollView(
            controller: controller,
            slivers: [
              // small grab-handle
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: $styles.colors.caption,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ---------- sections ----------
              ..._organSlivers(_bodyState!),

              // bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers --------------------------------------------------------
  List<Widget> _organSlivers(SBBodySimulatorStateSnapshot sbs) {
    final slivers = <Widget>[];
    final s = sbs.bodyState;
    final scores = sbs.overallScore.organScores;

    void add(String key, Widget? table) {
      if (table == null) return;
      final score = scores[key]; // 🆕 organ score
      slivers
        ..add(SliverToBoxAdapter(child: _sectionTitle(key, score)))
        ..add(SliverToBoxAdapter(child: table));
    }

    add('Brain', s.brain != null ? _brainTable(s.brain!) : null);
    add('Heart', s.heart != null ? _heartTable(s.heart!) : null);
    add('Lungs', s.lungs != null ? _lungsTable(s.lungs!) : null);
    add('Liver', s.liver != null ? _liverTable(s.liver!) : null);
    add('Stomach', s.stomach != null ? _stomachTable(s.stomach!) : null);
    add('Intestines',
        s.intestines != null ? _intestinesTable(s.intestines!) : null);
    add('Kidneys', s.kidneys != null ? _kidneysTable(s.kidneys!) : null);
    add('Endocrine',
        s.endocrine != null ? _endocrineTable(s.endocrine!) : null);
    add('Nervous', s.nervous != null ? _nervousTable(s.nervous!) : null);

    return slivers;
  }

  Widget _sectionTitle(String text, double? score) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: $styles.text.bodyBold.copyWith(fontSize: 18)),
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
        ('Stress level', d.stressLevel, false, '%'),
        ('Serotonin', d.serotonin, true, ''),
        ('Sleep rhythm', d.sleepRhythm, true, ' h'),
        ('Cortisol', d.cortisol, false, ''),
      ]);

  Widget _heartTable(HeartData d) => _metricTable([
        ('Blood sugar', d.bloodSugar, false, ' mg/dL'),
        ('Blood pressure', d.bloodPressure, false, ' mmHg'),
        ('Heart rate', d.heartRate, false, ' bpm'),
        ('HRV', d.hrv, true, ' ms'),
      ]);

  Widget _lungsTable(LungsData d) => _metricTable([
        ('O₂ saturation', d.oxygenSaturation, true, '%'),
        ('Health index', d.lungHealth, true, ''),
        ('PM exposure', d.pmExposure, false, ' μg/m³'),
        ('Respiratory rate', d.respiratoryRate, false, ' bpm'),
      ]);

  Widget _liverTable(LiverData d) => _metricTable([
        ('Detox capacity', d.detoxCapacity, true, '%'),
        ('Liver enzymes', d.liverEnzymes, false, ''),
        ('Fat processing', d.fatProcessing, true, '%'),
        ('Alcohol load', d.alcoholLoad, false, '%'),
      ]);

  Widget _stomachTable(StomachData d) => _metricTable([
        ('Digestion speed', d.digestionSpeed, true, '%'),
        ('Acidity', d.acidity, false, ''),
        ('Nausea risk', d.nauseaRisk, false, '%'),
        ('Food retention', d.foodRetention, false, '%'),
      ]);

  Widget _intestinesTable(IntestinesData d) => _metricTable([
        ('Bacteria diversity', d.gutBacteriaDiversity, true, '%'),
        ('Inflammation', d.inflammation, false, '%'),
        ('Absorption rate', d.absorptionRate, true, '%'),
        ('Gas level', d.gasLevel, false, '%'),
      ]);

  Widget _kidneysTable(KidneysData d) => _metricTable([
        ('Hydration', d.hydration, true, '%'),
        ('Electrolyte balance', d.electrolyteBalance, true, '%'),
        ('Urea clearance', d.ureaClearance, true, '%'),
        ('Toxicity load', d.toxicityLoad, false, '%'),
      ]);

  Widget _endocrineTable(EndocrineData d) => _metricTable([
        ('Insulin sensitivity', d.insulinSensitivity, true, '%'),
        ('Thyroid function', d.thyroidFunction, true, '%'),
        ('E/T ratio', d.estrogenTestosteroneRatio, false, ''),
      ]);

  Widget _nervousTable(NervousData d) => _metricTable([
        ('Focus level', d.focusLevel, true, '%'),
        ('Mood stability', d.moodStability, true, '%'),
        ('Anxiety level', d.anxietyLevel, false, '%'),
        ('Neuro flexibility', d.neuroFlexibility, true, '%'),
      ]);
}

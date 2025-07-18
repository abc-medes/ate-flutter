import 'dart:async';

import 'package:regene/common_libs.dart';
import 'package:regene/core/services/api_service.dart';
import 'package:regene/data/models/body_simulator_model.dart';

class BodySimulatorSnapshotDetails extends ConsumerStatefulWidget {
  final String userId;
  const BodySimulatorSnapshotDetails({super.key, required this.userId});

  @override
  ConsumerState<BodySimulatorSnapshotDetails> createState() =>
      _BodySimulatorSnapshotDetailsState();
}

class _BodySimulatorSnapshotDetailsState
    extends ConsumerState<BodySimulatorSnapshotDetails> {
  StreamSubscription<BodySimulatorState?>? _subscription;
  BodySimulatorState? _bodyState;

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
  List<Widget> _organSlivers(BodySimulatorState s) {
    final slivers = <Widget>[];

    void add(String title, Widget? table) {
      if (table == null) return;
      slivers
        ..add(SliverToBoxAdapter(child: _sectionTitle(title)))
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

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          text,
          style: $styles.text.bodyBold.copyWith(fontSize: 18),
        ),
      );

  Widget _metricTable(List<(String, String)> rows) => Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth()},
        border: TableBorder(
          horizontalInside: BorderSide(
            color: $styles.colors.caption.withOpacity(.15),
          ),
        ),
        children: rows
            .map(
              (r) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(r.$1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(r.$2, textAlign: TextAlign.right),
                  ),
                ],
              ),
            )
            .toList(),
      );

  // ---------- per-organ tables ----------------------------------------------
  Widget _brainTable(BrainData d) => _metricTable([
        ('Stress level', '${d.stressLevel}%'),
        ('Serotonin', '${d.serotonin}'),
        ('Sleep rhythm', '${d.sleepRhythm} h'),
        ('Cortisol', '${d.cortisol}'),
      ]);

  Widget _heartTable(HeartData d) => _metricTable([
        ('Blood sugar', '${d.bloodSugar} mg/dL'),
        ('Blood pressure', '${d.bloodPressure} mmHg'),
        ('Heart rate', '${d.heartRate} bpm'),
        ('HRV', '${d.hrv} ms'),
      ]);

  Widget _lungsTable(LungsData d) => _metricTable([
        ('O₂ saturation', '${d.oxygenSaturation}%'),
        ('Health index', '${d.lungHealth}'),
        ('PM exposure', '${d.pmExposure} μg/m³'),
        ('Respiratory rate', '${d.respiratoryRate} bpm'),
      ]);

  Widget _liverTable(LiverData d) => _metricTable([
        ('Detox capacity', '${d.detoxCapacity}%'),
        ('Liver enzymes', '${d.liverEnzymes}'),
        ('Fat processing', '${d.fatProcessing}%'),
        ('Alcohol load', '${d.alcoholLoad}%'),
      ]);

  Widget _stomachTable(StomachData d) => _metricTable([
        ('Digestion speed', '${d.digestionSpeed}%'),
        ('Acidity', '${d.acidity}'),
        ('Nausea risk', '${d.nauseaRisk}%'),
        ('Food retention', '${d.foodRetention}%'),
      ]);

  Widget _intestinesTable(IntestinesData d) => _metricTable([
        ('Bacteria diversity', '${d.gutBacteriaDiversity}%'),
        ('Inflammation', '${d.inflammation}%'),
        ('Absorption rate', '${d.absorptionRate}%'),
        ('Gas level', '${d.gasLevel}%'),
      ]);

  Widget _kidneysTable(KidneysData d) => _metricTable([
        ('Hydration', '${d.hydration}%'),
        ('Electrolyte balance', '${d.electrolyteBalance}%'),
        ('Urea clearance', '${d.ureaClearance}%'),
        ('Toxicity load', '${d.toxicityLoad}%'),
      ]);

  Widget _endocrineTable(EndocrineData d) => _metricTable([
        ('Insulin sensitivity', '${d.insulinSensitivity}%'),
        ('Thyroid function', '${d.thyroidFunction}%'),
        ('E/T ratio', '${d.estrogenTestosteroneRatio}'),
      ]);

  Widget _nervousTable(NervousData d) => _metricTable([
        ('Focus level', '${d.focusLevel}%'),
        ('Mood stability', '${d.moodStability}%'),
        ('Anxiety level', '${d.anxietyLevel}%'),
        ('Neuro flexibility', '${d.neuroFlexibility}%'),
      ]);
}

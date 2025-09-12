import 'dart:async';

import 'package:bodai/common_libs.dart';
import 'package:bodai/core/services/api_service.dart';
import 'package:bodai/core/services/session_service.dart';
import 'package:bodai/data/models/body_simulator_model.dart';
import 'package:bodai/features/home/views/widgets/_animated_metric_value.dart';

class BodySimulatorSnapshotDetails extends ConsumerStatefulWidget {
  final String userId;
  const BodySimulatorSnapshotDetails({super.key, required this.userId});

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

              // Show loading, error, or content
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all($styles.insets.xl),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                $styles.colors.accent1),
                          ),
                          SizedBox(height: $styles.insets.md),
                          Text(
                            '신체 시뮬레이터 데이터를 불러오는 중...',
                            style: $styles.text.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all($styles.insets.xl),
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
                              child: Text('다시 시도'),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_bodyState != null)
                ..._organSlivers(_bodyState!)
              else
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all($styles.insets.xl),
                      child: Text(
                        '데이터를 불러올 수 없습니다.',
                        style: $styles.text.body,
                      ),
                    ),
                  ),
                ),

              // bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers --------------------------------------------------------
  List<Widget> _organSlivers(BodySimulatorStateSnapshotDTO sbs) {
    final slivers = <Widget>[];
    final s = sbs.bodyState;
    final scores = sbs.healthScore.organScores;

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

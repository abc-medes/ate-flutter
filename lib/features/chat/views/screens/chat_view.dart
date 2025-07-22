import 'package:regene/common_libs.dart';
import 'package:regene/core/widgets/circular_icon_button.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:regene/features/chat/view_models/chat_view_model.dart';
import 'package:regene/core/routes/route_names.dart';

/// 매우 단순한 채팅 UI – 실시간 스트림 텍스트만 표시
class ChatView extends ConsumerWidget {
  final ChatMessage cm;
  const ChatView({super.key, required this.cm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatViewModelProvider(cm));

    return Scaffold(
      backgroundColor: $styles.colors.background,
      body: Column(
        children: [
          // ───── 상단 헤더 (HomeView와 동일 레이아웃) ─────
          Builder(
            builder: (context) {
              final mq = MediaQuery.of(context);
              return Container(
                padding: EdgeInsets.fromLTRB(
                  $styles.insets.md,
                  mq.padding.top,
                  $styles.insets.md,
                  $styles.insets.md,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular($styles.insets.lg),
                    bottomRight: Radius.circular($styles.insets.lg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ← menu → back button 으로 교체
                    CircularIconButton(
                      icon: Icons.arrow_back,
                      size: 48,
                      iconColor: $styles.colors.black,
                      backgroundColor: Colors.transparent,
                      onTap: () => context.go(RouteNames.home),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        SizedBox(width: $styles.insets.sm),
                        Text('SAT, 25 JUN 2025', style: $styles.text.bodySmall),
                      ],
                    ),
                    const SizedBox(width: 48), // 오른쪽 맞춤용 placeholder
                  ],
                ),
              );
            },
          ),

          // ───── 메시지 리스트 ─────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all($styles.insets.md),
              itemCount: state.messages.length,
              itemBuilder: (_, i) {
                final m = state.messages[i];
                final align =
                    m.isUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor = m.isUser
                    ? $styles.colors.accent1.withOpacity(.15)
                    : $styles.colors.accent3;

                return Align(
                  alignment: align,
                  child: Container(
                    margin: EdgeInsets.only(bottom: $styles.insets.sm),
                    padding: EdgeInsets.all($styles.insets.sm),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.message),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

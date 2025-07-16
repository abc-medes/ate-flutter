import 'package:regene/common_libs.dart';

class SystemDetailSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: $styles.colors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      // **FIXED**: Wrapped the content in a Material widget to provide
      // the necessary ancestor for ListTile and ExpansionTile.
      child: Column(
        children: [
          Text('System Detail'),
        ],
      ),
    );
  }
}

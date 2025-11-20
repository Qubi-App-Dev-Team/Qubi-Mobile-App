import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/components/circuit_section.dart';

class CircuitBottomDrawer extends StatefulWidget {
  const CircuitBottomDrawer({super.key});

  @override
  State<CircuitBottomDrawer> createState() => _CircuitBottomDrawerState();
}

class _CircuitBottomDrawerState extends State<CircuitBottomDrawer> with TickerProviderStateMixin {
  double _sheetPosition = 0.05; // start peek
  final double _dragSensitivity = 600;

  static const double _peek = 0.05;
  static const double _mid = 0.48;
  static const double _full = 0.75;

  late final AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _anim = Tween<double>(begin: _sheetPosition, end: _sheetPosition).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          _sheetPosition = _anim.value;
        });
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // 🟢 Toggle order: peek → full → mid → peek
  void _toggleDrawer() {
    double target;
    if ((_sheetPosition - _peek).abs() < 0.02) {
      target = _full;
    } else if ((_sheetPosition - _full).abs() < 0.02) {
      target = _mid;
    } else {
      target = _peek;
    }

    // Animate smoothly
    _anim = Tween<double>(begin: _sheetPosition, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetPosition,
      minChildSize: _peek,
      maxChildSize: _full,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(35, 0, 0, 0),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🟣 Top handle (tap + drag)
              GestureDetector(
                onTap: _toggleDrawer,
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _sheetPosition -= details.delta.dy / _dragSensitivity;
                    _sheetPosition = _sheetPosition.clamp(_peek, _full);
                  });
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7DDF0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),

              // 🧩 Scrollable drawer body
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: const [
                      SizedBox(height: 8),
                      CircuitSection(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qubi_app/pages/home/components/circuit_section.dart';

class CircuitBottomDrawer extends StatefulWidget {
  const CircuitBottomDrawer({super.key});

  @override
  State<CircuitBottomDrawer> createState() => _CircuitBottomDrawerState();
}

class _CircuitBottomDrawerState extends State<CircuitBottomDrawer> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  bool _isExpanded = false;

  void _toggleDrawer() {
    setState(() => _isExpanded = !_isExpanded);
    print("toggle pressed");
    _controller.animateTo(
      _isExpanded ? 0.75 : _peekHeight, //  drawer expands or collapses
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  static const double _peekHeight = 0.04;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _peekHeight, // initial visible height
      minChildSize: _peekHeight,     // prevents hiding completely
      maxChildSize: 0.75,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
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
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Top tab
                SizedBox(height: 2),
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFC7DDF0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Drawer Content
                SizedBox(height: 2),
                const CircuitSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

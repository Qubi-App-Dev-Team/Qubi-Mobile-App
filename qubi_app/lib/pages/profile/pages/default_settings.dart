import 'package:flutter/material.dart';
import 'package:qubi_app/components/app_colors.dart';
import 'package:qubi_app/pages/profile/components/theme_selector.dart';

class DefaultSettingsPage extends StatefulWidget {
  const DefaultSettingsPage({super.key});

  @override
  State<DefaultSettingsPage> createState() => _DefaultSettingsPageState();
}

class _DefaultSettingsPageState extends State<DefaultSettingsPage> {
  final List<String> roundingOptions = [
    "Major and half axes",
    "Major axes",
    "Half axes",
  ];
  String selectedRounding = "Major and half axes";
  double brightness = 0.27;
  int selectedColorIndex = 0;
  bool _showRoundingOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.saltWhite,
      appBar: AppBar(
        backgroundColor: AppColors.saltWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.richBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.richBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListView(
            children: [
              /// === Measurement Rounding Module ===
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Measurement Rounding",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.richBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Does the qubi auto-adjust your shake to the nearest axis?",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.black.withOpacity(0.1)),
                    const SizedBox(height: 8),

                    // Main "selected" box
                    GestureDetector(
                      onTap: () => setState(
                        () => _showRoundingOptions = !_showRoundingOptions,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.saltWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedRounding,
                              style: const TextStyle(
                                color: AppColors.richBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              _showRoundingOptions
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.richBlack,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Animated dropdown list
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _showRoundingOptions ? 1.0 : 0.0,
                        child: _showRoundingOptions
                            ? Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  children: roundingOptions.map((option) {
                                    final bool isSelected =
                                        option == selectedRounding;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          selectedRounding = option;
                                          _showRoundingOptions = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.saltWhite
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              option,
                                              style: TextStyle(
                                                color: AppColors.richBlack,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check,
                                                color: AppColors.skyBlue,
                                                size: 18,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),

              /// === Brightness Module ===
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Brightness",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.richBlack,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // use custom icons from assets/icons/
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/low_brightness.png',
                          width: 22,
                          height: 22,
                          color:
                              Colors.black54, // optional tint for consistency
                        ),
                        const Spacer(),
                        Image.asset(
                          'assets/icons/high_brightness.png',
                          width: 22,
                          height: 22,
                          color: Colors.black54, // optional tint
                        ),
                      ],
                    ),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: brightness,
                        onChanged: (v) => setState(() => brightness = v),
                        activeColor: AppColors.skyBlue,
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                    Center(
                      child: Text(
                        "${(brightness * 100).round()}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// === Screensaver Module ===
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Screensaver",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.richBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ThemeSelector(
                      selectedIndex: selectedColorIndex,
                      onSelect: (i) => setState(() => selectedColorIndex = i),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Saved changes will apply to two connected qubis.",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// === Save Button (Gradient) ===
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.electricIndigo, AppColors.skyBlue],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "Save changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

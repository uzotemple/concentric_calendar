import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Slower animation
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _updateDate(DateTime newDate) {
    if (newDate != _selectedDate) {
      setState(() {
        _selectedDate = newDate;
      });
      _animationController.reset(); // Reset animation
      _animationController.forward(); // Start animation
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concentric Calendar'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.calendar_today),
        //     onPressed: () async {
        //       final DateTime? picked = await showDatePicker(
        //         context: context,
        //         initialDate: _selectedDate,
        //         firstDate: DateTime(2000),
        //         lastDate: DateTime(2100),
        //       );
        //       if (picked != null) {
        //         _updateDate(picked);
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Center(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: DateCirclePainter(
                      date: _selectedDate,
                      animationValue: _animation.value,
                    ),
                  ),
                );
              },
            ),
          ),
          // Instruction Text
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              "Tap the calendar icon to change or select a date.",
              style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  _updateDate(picked);
                }
              },
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}

class DateCirclePainter extends CustomPainter {
  final List<String> days = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  final List<String> months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final List<String> dates = List.generate(31, (index) => '${index + 1}');

  final DateTime date;
  final double animationValue;

  DateCirclePainter({required this.date, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Define radii for each concentric circle
    double dayCircleRadius = size.width * .25;
    double monthCircleRadius = size.width * .35;
    double dateCircleRadius = size.width * .45;

    // Define ring thickness
    const double ringThickness = 30;

    // Define colors for the rings
    final List<Color> ringColors = [
      Colors.blue.withOpacity(.5),
      Colors.green.withOpacity(.5),
      Colors.orange.withOpacity(.5)
    ];

    // Paint the concentric rings
    _drawConcentricRings(canvas, center, [
      CircleInfo(dayCircleRadius, ringThickness, ringColors[0]),
      CircleInfo(monthCircleRadius, ringThickness, ringColors[1]),
      CircleInfo(dateCircleRadius, ringThickness, ringColors[2]),
    ]);

    // Get the current day, month, and date
    final int currentDayIndex = date.weekday - 1; // Monday = 1 (0-based)
    final int currentMonthIndex = date.month - 1; // January = 1 (0-based)
    final int currentDayOfMonthIndex = date.day - 1; // Date 1 to 31 (0-based)

    // Set the base angle to 90 degrees (π/2 radians)
    const double baseAngle = -pi / 2;

    // Calculate the offset angle for animation
    final double angleOffset = 2 * pi * animationValue;

    // Paint Days (Mon to Sun) - aligned at 90 degrees (bottom)
    _drawTextAroundCircle(
      canvas,
      center,
      dayCircleRadius,
      days,
      currentDayIndex, // Index of the current day
      baseAngle + angleOffset,
    );

    // Paint Months (January to December) - aligned with the current month at 90 degrees
    _drawTextAroundCircle(
      canvas,
      center,
      monthCircleRadius,
      months,
      currentMonthIndex, // Index of the current month
      baseAngle + angleOffset,
    );

    // Paint Dates (1 to 31) - aligned with the current date at 90 degrees
    _drawTextAroundCircle(
      canvas,
      center,
      dateCircleRadius,
      dates,
      currentDayOfMonthIndex, // Index of the current date
      baseAngle + angleOffset,
    );
  }

  void _drawConcentricRings(
      Canvas canvas, Offset center, List<CircleInfo> circles) {
    final Paint paint = Paint()..style = PaintingStyle.stroke;

    for (CircleInfo circle in circles) {
      paint
        ..color = circle.color
        ..strokeWidth = circle.thickness;
      canvas.drawCircle(center, circle.radius, paint);
    }
  }

  void _drawTextAroundCircle(
    Canvas canvas,
    Offset center,
    double radius,
    List<String> texts,
    int highlightIndex, // Index of the current text to highlight
    double baseAngle, // The fixed angle (90 degrees for alignment)
  ) {
    final double anglePerText = (2 * pi) / texts.length; // Angle between texts

    for (int i = 0; i < texts.length; i++) {
      // Calculate the angle for the current text
      final double angle = baseAngle + (i - highlightIndex) * anglePerText;
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);

      // TextStyle for normal and highlighted text
      final textStyle = TextStyle(
        color: i == highlightIndex ? Colors.red : Colors.black,
        fontSize: i == highlightIndex ? 18 : 16,
        fontWeight: i == highlightIndex ? FontWeight.bold : FontWeight.normal,
      );

      // Create a TextSpan and TextPainter
      final textSpan = TextSpan(text: texts[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout();

      // Save canvas state, rotate, and paint the text
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2); // Rotate text to face outward
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is DateCirclePainter &&
        (oldDelegate.date != date ||
            oldDelegate.animationValue != animationValue);
  }
}

class CircleInfo {
  final double radius;
  final double thickness;
  final Color color;

  CircleInfo(this.radius, this.thickness, this.color);
}

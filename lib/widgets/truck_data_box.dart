import 'package:flutter/material.dart';

class TruckDataBox extends StatefulWidget {
  final String truckId;
  final Offset position;
  final Function(String, Offset) onPositionChanged;
  final Function(String)? onTap;
  final Function(String)? onDelete;
  final Function(String, String)? onDataChanged; // New callback for data changes
  final bool isSelected;
  final String? initialUserData; // Initial data to restore

  const TruckDataBox({
    super.key,
    required this.truckId,
    required this.position,
    required this.onPositionChanged,
    this.onTap,
    this.onDelete,
    this.onDataChanged,
    this.isSelected = false,
    this.initialUserData,
  });

  @override
  State<TruckDataBox> createState() => _TruckDataBoxState();
}

class _TruckDataBoxState extends State<TruckDataBox> {
  bool _isDragging = false;
  final TextEditingController _freqController = TextEditingController();
  Offset? _startPosition;
  Offset? _initialTouchPosition;

  @override
  void initState() {
    super.initState();
    // Initialize with default frequency value
    _freqController.text = '';
    
    // Restore initial user data if provided
    if (widget.initialUserData != null) {
      setUserData(widget.initialUserData);
    }
    
    // Add listener to notify when data changes
    _freqController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _freqController.removeListener(_onDataChanged);
    _freqController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    // Notify the canvas when user data changes
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(widget.truckId, getUserData());
    }
  }

  // Method to get current user data as JSON string
  String getUserData() {
    return '{"frequency":"${_freqController.text}"}';
  }

  // Method to set user data from JSON string
  void setUserData(String? userData) {
    if (userData == null || userData.isEmpty) return;
    
    try {
      // Simple parsing since we know the format
      final data = userData.replaceAll('{', '').replaceAll('}', '').split(',');
      for (final item in data) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final key = parts[0].replaceAll('"', '').trim();
          final value = parts[1].replaceAll('"', '').trim();
          
          if (key == 'frequency') {
            _freqController.text = value;
          }
        }
      }
    } catch (e) {
      // Silently ignore parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.truckId),
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _startPosition = widget.position;
            _initialTouchPosition = details.globalPosition;
          });
        },
        onPanUpdate: (details) {
          if (_startPosition != null && _initialTouchPosition != null) {
            final delta = details.globalPosition - _initialTouchPosition!;
            final newPosition = _startPosition! + delta;
            widget.onPositionChanged(widget.truckId, newPosition);
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _startPosition = null;
            _initialTouchPosition = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 120, // Increased width for better text space
          height: 90,  // Increased height for better proportions
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.black,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: _isDragging || widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Truck shape (lowered and trailer heightened for text space)
              Positioned(
                left: 10,
                top: 25, // Lowered from 15 to 25
                child: CustomPaint(
                  size: Size(100, 55), // Increased height for taller trailer
                  painter: TruckPainter(),
                ),
              ),
              
              // Freq. label and input field inside trailer area
              Positioned(
                left: 20, // Positioned inside the trailer
                top: 35,  // Adjusted to match new trailer position
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freq.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1),
                    SizedBox(
                      width: 45, // Fit nicely in trailer
                      height: 18,
                      child: TextField(
                        controller: _freqController,
                        style: const TextStyle(fontSize: 9),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 2,
                          ),
                          isDense: true,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete button when selected
              if (widget.isSelected && widget.onDelete != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => widget.onDelete?.call(widget.truckId),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;

    // Draw truck trailer (left rectangle - taller for text space)
    final trailerRect = Rect.fromLTWH(0, 5, 65, 35); // Increased height from 25 to 35
    canvas.drawRect(trailerRect, fillPaint);
    canvas.drawRect(trailerRect, paint);

    // Draw truck cab (right rectangle) - aligned so bottom left meets bottom right of trailer
    final cabRect = Rect.fromLTWH(65, 9, 25, 31); // Moved to x:65 and y:9 to align bottoms
    canvas.drawRect(cabRect, fillPaint);
    canvas.drawRect(cabRect, paint);

    // Draw wheels (circles) - lowered to match new truck position
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Front wheels (under trailer)
    canvas.drawCircle(Offset(15, 45), 6, wheelPaint); // Lowered from 40 to 45
    canvas.drawCircle(Offset(30, 45), 6, wheelPaint); // Lowered from 40 to 45
    
    // Rear wheel (under cab) - adjusted for new cab position
    canvas.drawCircle(Offset(77, 45), 6, wheelPaint); // Moved from 72 to 77 to center under cab
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../logic/app_database.dart';
import '../database_provider.dart';

class CustomerDataBox extends StatefulWidget {
  final String customerId;
  final Offset position;
  final Function(String, Offset) onPositionChanged;
  final Function(String)? onTap;
  final Function(String)? onDelete;
  final bool isSelected;
  final int valueStreamId;

  const CustomerDataBox({
    super.key,
    required this.customerId,
    required this.position,
    required this.onPositionChanged,
    required this.valueStreamId,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<CustomerDataBox> createState() => _CustomerDataBoxState();
}

class _CustomerDataBoxState extends State<CustomerDataBox> {
  bool _isDragging = false;
  ValueStream? _valueStreamData;
  bool _isLoading = true;
  Offset? _startPosition;
  Offset? _initialTouchPosition;

  @override
  void initState() {
    super.initState();
    _loadValueStreamData();
  }

  Future<void> _loadValueStreamData() async {
    try {
      final db = await DatabaseProvider.getInstance();
      final valueStream = await (db.select(db.valueStreams)
            ..where((vs) => vs.id.equals(widget.valueStreamId)))
          .getSingleOrNull();
      
      setState(() {
        _valueStreamData = valueStream;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get _monthlyDemand {
    if (_valueStreamData?.mDemand != null) {
      return _valueStreamData!.mDemand.toString();
    }
    return 'N/A';
  }

  String get _taktTime {
    return _valueStreamData?.taktTime ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.customerId),
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
            widget.onPositionChanged(widget.customerId, newPosition);
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
          width: 180,
          height: 150, // Increased height further to prevent any overflow
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.black,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: _isDragging || widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(6.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important: minimize column size
                  children: [
                    // Factory roof design
                    CustomPaint(
                      size: const Size(168, 18), // Adjusted size
                      painter: FactoryRoofPainter(),
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    
                    // Title
                    const Center(
                      child: Text(
                        'All Customers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    
                    // Divider line
                    Container(
                      height: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    
                    // Data fields
                    if (_isLoading)
                      const Expanded(
                        child: Center(child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )),
                      )
                    else
                      Expanded( // Wrap in Expanded to prevent overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Monthly Demand row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Monthly Demand:',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _monthlyDemand,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // TT(takt) row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TT(takt):',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _taktTime,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              
              // Delete button when selected
              if (widget.isSelected && widget.onDelete != null)
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => widget.onDelete?.call(widget.customerId),
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
                        size: 14,
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

class FactoryRoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Draw sawtooth roof pattern
    final double segmentWidth = size.width / 3;
    
    // Start from bottom left
    path.moveTo(0, size.height);
    
    // First triangle
    path.lineTo(segmentWidth * 0.8, 0);
    path.lineTo(segmentWidth, size.height);
    
    // Second triangle
    path.lineTo(segmentWidth * 1.8, 0);
    path.lineTo(segmentWidth * 2, size.height);
    
    // Third triangle
    path.lineTo(segmentWidth * 2.8, 0);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

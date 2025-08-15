import 'package:flutter/material.dart';
import '../models/process_object.dart';
import '../utils/unified_canvas_drag.dart';

class DraggableProcessWidget extends StatelessWidget with UnifiedCanvasDrag {
  final ProcessObject process;
  final VoidCallback? onTap;
  final Function(ProcessObject, Offset)? onDragEnd;
  final bool isSelected;

  const DraggableProcessWidget({
    super.key,
    required this.process,
    this.onTap,
    this.onDragEnd,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return createUnifiedDraggable<ProcessObject>(
      data: process,
      position: process.position,
      size: process.size,
      childBuilder: (isDragging, isGhost) => _buildProcessContainer(
        isDragging: isDragging,
        isGhost: isGhost,
      ),
      onDragEnd: (processData, globalOffset) {
        if (onDragEnd != null) {
          onDragEnd!(processData, globalOffset);
        }
      },
      onTap: onTap,
    );
  }

  Widget _buildProcessContainer(
      {bool isDragging = false, bool isGhost = false}) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        width: process.size.width,
        height: process.size.height,
        decoration: BoxDecoration(
          color: isGhost ? process.color.withOpacity(0.3) : process.color,
          border: Border.all(
            color: isSelected
                ? Colors.blue[700]!
                : isDragging
                    ? Colors.blue[500]!
                    : Colors.grey[400]!,
            width: isSelected
                ? 3
                : isDragging
                    ? 2
                    : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging || isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDragging ? 0.4 : 0.2),
                    blurRadius: isDragging ? 10 : 5,
                    offset: Offset(0, isDragging ? 6 : 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4), // Reduced from 6 to 4
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Process name at top center
              Text(
                process.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11, // Reduced from 12 to 11
                  color: _getTextColor(process.color),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3), // Reduced from 4 to 3

              // Divider line
              Container(
                height: 1,
                color: _getTextColor(process.color).withOpacity(0.3),
              ),
              const SizedBox(height: 3), // Reduced from 4 to 3

              // Data rows with labels and values
              Column(
                mainAxisSize: MainAxisSize.min, // Minimize height
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDataRow('Staffing:', process.staffingDisplay),
                  _buildDataRow('Daily Demand:', process.dailyDemandDisplay),
                  _buildDataRow('TT (takt):', process.taktTimeDisplay),
                  _buildDataRow('CT (cycle):', process.cycleTimeDisplay),
                  _buildDataRow('WIP:', process.wipDisplay),
                  _buildDataRow('LT (leadtime):', process.leadTimeDisplay),
                  _buildDataRow('Uptime%:', process.uptimeDisplay),
                  _buildDataRow('FPY%:', process.fpyDisplay),
                  _buildDataRow('Changeover:', process.changeoverDisplay),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 0.2), // Reduced from 0.5 to 0.2
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9, // Increased from 7 to 9
                fontWeight: FontWeight.w500,
                color: _getTextColor(process.color),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 9, // Increased from 7 to 9
                color: _getTextColor(process.color).withOpacity(0.9),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if text should be dark or light
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

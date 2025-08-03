import 'package:flutter/material.dart';
import '../models/canvas_icon.dart';
import 'fifo_icon.dart';

class FloatingIconToolbar extends StatefulWidget {
  final Function(CanvasIconTemplate) onIconSelected;
  final VoidCallback? onToggle;

  const FloatingIconToolbar({
    super.key,
    required this.onIconSelected,
    this.onToggle,
  });

  @override
  State<FloatingIconToolbar> createState() => _FloatingIconToolbarState();
}

class _FloatingIconToolbarState extends State<FloatingIconToolbar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleToolbar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main toggle button
          FloatingActionButton(
            heroTag: "toolbar_toggle",
            onPressed: _toggleToolbar,
            backgroundColor: Colors.deepPurple,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          
          // Expandable toolbar
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: _animation.value,
                  child: _isExpanded ? _buildExpandedToolbar() : const SizedBox(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedToolbar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: 280,
      height: 320,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'VSM Icons',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Icon grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: CanvasIconTemplate.templates.length,
              itemBuilder: (context, index) {
                final template = CanvasIconTemplate.templates[index];
                return _buildIconButton(template);
              },
            ),
          ),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Tap an icon to add it to the canvas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(CanvasIconTemplate template) {
    return Tooltip(
      message: template.label,
      child: InkWell(
        onTap: () {
          // For customer icon, create a special data box
          if (template.type == CanvasIconType.customer) {
            final specialTemplate = CanvasIconTemplate(
              type: CanvasIconType.customerDataBox,
              label: 'Customer Data Box',
              iconData: template.iconData,
              color: template.color,
            );
            widget.onIconSelected(specialTemplate);
          } 
          // For supplier icon, create a special data box
          else if (template.type == CanvasIconType.supplier) {
            final specialTemplate = CanvasIconTemplate(
              type: CanvasIconType.supplierDataBox,
              label: 'Supplier Data Box',
              iconData: template.iconData,
              color: template.color,
            );
            widget.onIconSelected(specialTemplate);
          } 
          // For production control icon, create a special data box
          else if (template.type == CanvasIconType.productionControl) {
            final specialTemplate = CanvasIconTemplate(
              type: CanvasIconType.productionControlDataBox,
              label: 'Production Control Data Box',
              iconData: template.iconData,
              color: template.color,
            );
            widget.onIconSelected(specialTemplate);
          } 
          // For truck icon, create a special data box
          else if (template.type == CanvasIconType.truck) {
            final specialTemplate = CanvasIconTemplate(
              type: CanvasIconType.truckDataBox,
              label: 'Truck Data Box',
              iconData: template.iconData,
              color: template.color,
            );
            widget.onIconSelected(specialTemplate);
          } 
          else {
            widget.onIconSelected(template);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: template.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: template.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use custom FIFO icon for FIFO type, standard icon for others
              template.type == CanvasIconType.fifo
                  ? FifoIcon(
                      color: template.color,
                      size: 24, // Keep toolbar icon at normal size
                    )
                  : Icon(
                      template.iconData,
                      color: template.color,
                      size: 24,
                    ),
              const SizedBox(height: 2),
              Text(
                template.label,
                style: TextStyle(
                  fontSize: 8,
                  color: template.color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

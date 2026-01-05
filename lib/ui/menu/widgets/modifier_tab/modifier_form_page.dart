import 'package:flutter/material.dart';
import 'package:street_cart_pos/ui/core/widgets/dashed_border_painter.dart';

class ModifierFormPage extends StatefulWidget {
  const ModifierFormPage({
    super.key,
    required this.isEditing,
    required this.onSave,
    this.initialName,
  });

  final bool isEditing;
  final void Function(String name, int optionCount) onSave;
  final String? initialName;

  @override
  State<ModifierFormPage> createState() => _ModifierFormPageState();
}

class _ModifierFormPageState extends State<ModifierFormPage> {
  final _groupNameController = TextEditingController();
  String? _priceBehavior;
  String? _selectionType;
  int _defaultSelectionIndex = -1; // -1 represents 'None'

  final List<_ModifierOptionController> _optionControllers = [];

  static const _maxOptions = 10;
  static const _priceBehaviorPriceChange = 'Price Change';
  static const _priceBehaviorNoPriceChange = 'No Price Change';

  bool get _canAddOption => _optionControllers.length < _maxOptions;
  bool get _hasPriceChange => _priceBehavior == _priceBehaviorPriceChange;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // Mock data for editing
      _groupNameController.text = widget.initialName ?? "";
      _selectionType = "Single Selection";
      _priceBehavior = _priceBehaviorPriceChange;
      _addOption(); // Add mock option
    } else {
      _selectionType = "Single Selection";
      _priceBehavior = _priceBehaviorPriceChange;
      // Start with one empty option for convenience
      _addOption();
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (!_canAddOption) return;
    setState(() {
      _optionControllers.add(_ModifierOptionController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);

      // Adjust default selection index
      if (_defaultSelectionIndex == index) {
        _defaultSelectionIndex = -1;
      } else if (_defaultSelectionIndex > index) {
        _defaultSelectionIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Modifier Group' : 'Add Modifier Group',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name
            const Text(
              'Group Name',
              style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Size',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBCBCB),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Price Behavior
            const Text(
              'Price Behavior',
              style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 357,
              height: 44,
              child: DropdownButtonFormField<String>(
                value: _priceBehavior,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                hint: const Text(
                  'Select',
                  style: TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: const [
                  DropdownMenuItem(
                    value: _priceBehaviorPriceChange,
                    child: Text(_priceBehaviorPriceChange),
                  ),
                  DropdownMenuItem(
                    value: _priceBehaviorNoPriceChange,
                    child: Text(_priceBehaviorNoPriceChange),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _priceBehavior = val;
                    if (!_hasPriceChange) {
                      for (final c in _optionControllers) {
                        c.price.clear();
                      }
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Selection Type
            const Text(
              'Selection Type',
              style: TextStyle(fontSize: 10, color: Color(0xFF393838)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 357,
              height: 44,
              child: DropdownButtonFormField<String>(
                value: _selectionType,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                hint: const Text(
                  'Select',
                  style: TextStyle(fontSize: 14, color: Color(0xFFCBCBCB)),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Single Selection',
                    child: Text('Single Selection'),
                  ),
                  DropdownMenuItem(
                    value: 'Multi Selection',
                    child: Text('Multi Selection'),
                  ),
                ],
                onChanged: (val) => setState(() => _selectionType = val),
              ),
            ),
            const SizedBox(height: 24),

            // Options Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Select as default',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // None Option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'None',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Radio<int>(
                  value: -1,
                  groupValue: _defaultSelectionIndex,
                  activeColor: const Color(0xFF5EAF41),
                  onChanged: (val) =>
                      setState(() => _defaultSelectionIndex = val!),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Options List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _optionControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    // X Button
                    GestureDetector(
                      onTap: () => _removeOption(index),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.close, color: Colors.black, size: 20),
                      ),
                    ),
                    // Option Label
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _optionControllers[index].label,
                          decoration: InputDecoration(
                            hintText: 'Option Label',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFCBCBCB),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_hasPriceChange) ...[
                      const SizedBox(width: 8),
                      // Price Field
                      SizedBox(
                        width: 85,
                        height: 44,
                        child: TextField(
                          controller: _optionControllers[index].price,
                          decoration: InputDecoration(
                            hintText: '+ \$ 0.00',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFCBCBCB),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    // Default Radio
                    Radio<int>(
                      value: index,
                      groupValue: _defaultSelectionIndex,
                      activeColor: const Color(0xFF5EAF41),
                      onChanged: (val) =>
                          setState(() => _defaultSelectionIndex = val!),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Add Another Option Button
            CustomPaint(
              foregroundPainter: DashedBorderPainter(
                color: const Color(0xFF696969),
                strokeWidth: 1,
                dashWidth: 4,
                dashSpace: 4,
                borderRadius: 8,
              ),
              child: InkWell(
                onTap: _canAddOption ? _addOption : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 357,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canAddOption
                        ? const Color(0xFFECEBEB)
                        : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ Add Another Option',
                    style: TextStyle(
                      fontSize: 14,
                      color: _canAddOption
                          ? const Color(0xFF393838)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
            ),
            if (!_canAddOption) ...[
              const SizedBox(height: 8),
              const Text(
                'Maximum 10 options per modifier group.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
            const SizedBox(height: 40),

            // Create/Save Button
            SizedBox(
              width: 357,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  if (_groupNameController.text.trim().isNotEmpty) {
                    widget.onSave(
                      _groupNameController.text.trim(),
                      _optionControllers.length,
                    );
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5EAF41),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'Save' : 'Create Item',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ModifierOptionController {
  final label = TextEditingController();
  final price = TextEditingController();

  void dispose() {
    label.dispose();
    price.dispose();
  }
}

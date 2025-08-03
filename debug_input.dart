import 'package:flutter/services.dart';

// Exact copy of the current formatter
class NumberWithCommasFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only digits - no commas in input
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If empty, allow it
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Just return the digits - no formatting during input
    // The display formatting will be handled by the controller update
    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

void main() {
  final formatter = NumberWithCommasFormatter();
  
  print('Testing input sequence for "1000":');
  
  // Simulate typing "1"
  var result = formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    const TextEditingValue(text: '1'),
  );
  print('Type "1": "${result.text}" (cursor at ${result.selection.start})');
  
  // Simulate typing "10"
  result = formatter.formatEditUpdate(
    result,
    const TextEditingValue(text: '10'),
  );
  print('Type "10": "${result.text}" (cursor at ${result.selection.start})');
  
  // Simulate typing "100"  
  result = formatter.formatEditUpdate(
    result,
    const TextEditingValue(text: '100'),
  );
  print('Type "100": "${result.text}" (cursor at ${result.selection.start})');
  
  // Simulate typing "1000"
  result = formatter.formatEditUpdate(
    result,
    const TextEditingValue(text: '1000'),
  );
  print('Type "1000": "${result.text}" (cursor at ${result.selection.start})');
}

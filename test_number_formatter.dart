import 'package:flutter/services.dart';

// Define NumberWithCommasFormatter class for testing
class NumberWithCommasFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add commas
    String formatted = _addCommas(digitsOnly);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String value) {
    if (value.isEmpty) return value;
    
    // Add commas every 3 digits from right to left
    return value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

void main() {
  // Test the NumberWithCommasFormatter
  final formatter = NumberWithCommasFormatter();
  
  // Test case 1: Enter "1000"
  print('Test 1: Entering "1000"');
  var result = formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    const TextEditingValue(text: '1000'),
  );
  print('Result: "${result.text}" - Expected: "1,000"');
  
  // Test case 2: Entering digits one by one: "1", then "10", then "100", then "1000"
  print('\nTest 2: Entering digits step by step');
  
  result = formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    const TextEditingValue(text: '1'),
  );
  print('Step 1 - Enter "1": "${result.text}" - Expected: "1"');
  
  result = formatter.formatEditUpdate(
    TextEditingValue(text: result.text),
    const TextEditingValue(text: '10'),
  );
  print('Step 2 - Enter "10": "${result.text}" - Expected: "10"');
  
  result = formatter.formatEditUpdate(
    TextEditingValue(text: result.text),
    const TextEditingValue(text: '100'),
  );
  print('Step 3 - Enter "100": "${result.text}" - Expected: "100"');
  
  result = formatter.formatEditUpdate(
    TextEditingValue(text: result.text),
    const TextEditingValue(text: '1000'),
  );
  print('Step 4 - Enter "1000": "${result.text}" - Expected: "1,000"');
  
  // Test case 3: Large numbers
  print('\nTest 3: Large numbers');
  result = formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    const TextEditingValue(text: '1234567'),
  );
  print('Enter "1234567": "${result.text}" - Expected: "1,234,567"');
}

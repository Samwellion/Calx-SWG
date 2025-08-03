void testNumberFormatting() {
  String formatNumberWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // Test cases
  print('Testing number formatting:');
  print('1000 -> ${formatNumberWithCommas(1000)}'); // Should be "1,000"
  print('1234567 -> ${formatNumberWithCommas(1234567)}'); // Should be "1,234,567"
  print('100 -> ${formatNumberWithCommas(100)}'); // Should be "100"
  print('1 -> ${formatNumberWithCommas(1)}'); // Should be "1"
  print('25500 -> ${formatNumberWithCommas(25500)}'); // Should be "25,500"
}

void main() {
  testNumberFormatting();
}

import 'package:flutter_test/flutter_test.dart';

import 'package:focus_companion/ui/components.dart';

void main() {
  test('fractional settlement displays are explicitly approximate', () {
    const spent = Duration(minutes: 14, seconds: 26, microseconds: 500000);
    final balance = const Duration(minutes: 30) - spent;
    expect(durationLabel(spent), '约 14 分钟 26 秒');
    expect(durationLabel(balance), '约 15 分钟 33 秒');
    expect(durationLabel(const Duration(minutes: 30)), '30 分钟');
    expect(durationLabel(spent, roundUp: true), '14 分钟 27 秒');
  });
}

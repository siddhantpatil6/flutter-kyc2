
import 'package:flutter_test/flutter_test.dart';
import 'package:kyc2/utils/navigation_utils.dart';

void main(){

  test('navHistory list push and pop test', () async {
    expect(NavigationUtils.navHistory.length, 0);
    NavigationUtils.navHistory.add('PUSH-test');
    expect(NavigationUtils.navHistory.length, 1);
    expect(NavigationUtils.navHistory[0], 'PUSH-test');
    NavigationUtils.navHistory.add('POP-test');
    expect(NavigationUtils.navHistory.length, 2);
    expect(NavigationUtils.navHistory[0], 'PUSH-test');
    expect(NavigationUtils.navHistory[1], 'POP-test');

  });


}
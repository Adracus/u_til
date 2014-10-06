import 'package:unittest/unittest.dart';
import 'package:u_til/u_til.dart';
import 'dart:mirrors';

class ATest {
  
}

main() {
  group("\$-Tests", () {
    expect($.rootLibrary.getClasses().values, contains(reflectClass(ATest)));
  });
  
  group("\$list-Tests", () {
    
    test("List equality", () {
      var l1 = [1, 2, 3, 4];
      var l2 = [1, 2, 3, 4];
      expect(l1 == l2, equals(false));
      expect($(l1) == l2, equals(true));
    });
    
    test("List extraction", () {
      var l1 = [1, 2, .1, "test"];
      expect($(l1).extract(String), contains("test"));
      expect($(l1).extract(double), contains(.1));
    });
  });
  
  group("\$map-Tests", () {
    test("Where function", () {
      var test = {0: 0, 1: 1, -1: -1, 100: 100, 10: 20};
      expect($(test).whereKey((key) => key < 0), equals({-1: -1}));
      expect($(test).whereKey((key) => key > 0), equals({1: 1, 100: 100, 10: 20}));
      expect($(test).whereValue((val) => val == 20), equals({10: 20}));
      expect($(test).whereValue((val) => val == "w"), equals({}));
    });
  });
  
  group("\$object-Tests", () {
    
    test("Null-Function", () {
      var test = null;
      expect($(test).ifNull("Default value"), equals("Default value"));
      test = "Not null";
      expect($(test).ifNotNull(1), equals(1));
      expect($().ifNull(true), equals(true));
      expect($().isNull(), equals(true));
    });
    
  });
  
  group("\$num-Tests",() {
    
    test("Times-Function", () {
      int test = 0;
      $(4).times((index) => test += index);
      expect(test, equals(6));
      $(4).times((index) => test -= index, reverse: true);
      expect(test, equals(0));
    });
    
  });
  
  group("\$function-Test", () {
    
    test("Function calling", () {
      var test = (int i) => i;
      test = $(test);
      expect(test(5), equals(5));
    });
    
  });
}
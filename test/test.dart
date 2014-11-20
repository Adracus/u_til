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
    
    test("List minimum and maximum", () {
      var l1 = [1, 2, 3, .1, .2];
      expect($(l1).min(), equals(.1));
      expect($(l1).max(), equals(3));
      expect($([]).max, throwsException);
      expect($([]).min, throwsException);
      expect($([1]).max(), equals(1));
      expect($([1]).min(), equals(1));
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
    
    test("Equality", () {
      var m1 = {"test": 123, 1314: "otherTest"};
      var m2 = {"test": 123, 1314: "otherTest"};
      var m3 = {"test": 234, 1314: "otherTest"};
      var m4 = {"i don't": 13, 213: "have the same keys"};
      expect($(m1) == m2, equals(true));
      expect($(m1) == m3, equals(false));
      expect($(m1) == m4, equals(false));
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
}
library u_til;

import "dart:mirrors";
import "dart:math" show Random;
import "dart:io" show Platform;


const _$ $ = const _$();

class Range<C extends Comparable> {
  final C start, end;
  
  Range(this.start, this.end) {
    if(start.compareTo(end) > 0)
      throw new ArgumentError("Start cannot be > end");
  }
  
  bool insideRange(C arg) =>
      arg.compareTo(start) >= 0 && arg.compareTo(end) <=0;
}


class NumericRange extends Range<num> {
  NumericRange(num start, num end) : super(start, end);
  
  List map(f(num i), {num stepWidth: 1}) {
    var result = [];
    for (num i = start; i < end; i += stepWidth) {
      result.add(f(i));
    }
    return result;
  }
  
  void forEach(f(num i), {num stepWidth: 1}) {
    for (num i = start; i < end; i += stepWidth) {
      f(i);
    }
  }
}


class NumericRangeBuilder {
  final num start;
  
  NumericRangeBuilder(this.start);
  
  NumericRange to(num end) {
    if (start > end) throw new ArgumentError("Start cannot be > end");
    return new NumericRange(start, end);
  }
}



@proxy
class _$ {
  const _$();
  
  $object call([arg]) {
    if (arg is $object) return arg;
    if (arg is String) return new $string(arg);
    if (arg is num || arg is int || arg is double) return new $num(arg);
    if (arg is List) return new $list(arg);
    if (arg is Iterable) return new $iterable(arg);
    if (arg is Map) return new $map(arg);
    if (arg is Symbol) return new $symbol(arg);
    if (arg is ClassMirror) return new $classMirror(arg);
    if (arg is LibraryMirror) return new $libraryMirror(arg);
    if (arg is Function) return new $function(arg);
    if (arg is Type) return new $type(arg);
    return new $object(arg);
  }
  
  $libraryMirror get rootLibrary =>
      $(currentMirrorSystem().libraries[Platform.script]);
  
  NumericRangeBuilder from(num start) => new NumericRangeBuilder(start);
}



@proxy
class $random extends $object<Random> {
  $random(Random target) : super(target);
  
  
  int nextIntBetween(int min, int max) {
    return min + target.nextInt(max - min);
  }
  
  
  List<int> nextInts(int n, int max) {
    return new List.generate(n, (_) => target.nextInt(max));
  }
  
  
  List<int> nextIntsBetween(int n, int min, int max) {
    return new List.generate(n, (_) => nextIntBetween(min, max));
  }
  
  
  Set<int> nextDistinctInts(int n, int max) {
    var result = new Set();
    while (result.length < n) {
      result.add(target.nextInt(max));
    }
    return result;
  }
  
  
  Set<int> nextDistinctIntsBetween(int n, int min, int max) {
    var result = new Set();
    while (result.length < n) {
      result.add(nextIntBetween(min, max));
    }
    return result;
  }
}



@proxy
class $string extends $object<String> {
  $string(String target) : super(target);
  
  
  String repeat(int times) => target * times;
  
  
  String longer(String other) =>
      target.length >= other.length ? target : other;
  
  
  String shorter(String other) =>
      target.length <= other.length ? target : other;
  
  
  bool equalsIgnoreCase(String other) =>
      target.toLowerCase() == other.toLowerCase();
  
  
  String flip() {
    if (target == null || target == "") return target;
    return new String.fromCharCodes(target.runes.toList().reversed);
  }
  
  
  bool get isBlank => target == null || target == "";
}



class $type extends $object<Type> {
  $type(Type target) : super(target);
  
  Symbol get qualifiedName => reflectType(target).qualifiedName;
  Symbol get simpleName => reflectType(target).simpleName;
}



@proxy
class $function extends $object<Function> {
  $function(Function target) : super(target);
  
  noSuchMethod(Invocation invocation) {
    return Function.apply(target, invocation.positionalArguments,
        invocation.namedArguments);
  }
}



@proxy
class $symbol extends $object<Symbol> {
  $symbol(Symbol target) : super(target);
  
  String get name => MirrorSystem.getName(target);
}



@proxy
class $num extends $object {
  $num(num target) : super(target);
  
  void times(f(int index), {int start: 0, bool reverse: false}) {
    if (!reverse) {
      for (int i = start; i < target; i++) {
        f(i);
      }
      return;
    }
    for (int i = target - 1; i >= start; i--) {
      f(i);
    }
  }
  
  List map(f(int index)) {
    var result = [];
    for (int i = 0; i < target; i++) {
      result.add(f(i));
    }
    return result;
  }
}



@proxy
class $iterable<E extends Iterable> extends $object<E> {
  $iterable(Iterable target) : super(target);
  
  
  get randomElement => target.elementAt(new Random().nextInt(target.length));
  
  
  Iterable extract(type) {
    var _type = type is $type ? type.target : type;
    return target.where((elem) =>
        reflect(elem).type.isAssignableTo(reflectType(_type)));
  }
  
  
  Set getDistinctRandomElements(int n) {
    return new Set.from((
        new Set.from(target).toList()..shuffle()).sublist(0, n));
  }
  
  
  bool operator==(other) {
    if (other is! Iterable && other is! $iterable) return false;
    var l = other is Iterable ? other: other.target;
    if (other.length != target.length) return false;
    var thisIterator = target.iterator;
    var otherIterator = other.iterator as Iterator;
    while (thisIterator.moveNext() && otherIterator.moveNext()) {
      if (!($(thisIterator.current) == $(otherIterator.current)))
        return false;
    }
    return true;
  }
  
  
  max() {
    if (target.length == 0)
      throw new Exception("Cannot get maximum element of empty list");
    if (target.length == 1) return target.single;
    var start = target.first;
    for (int i = 1; i < target.length; i++) {
      if (target.elementAt(i) > start) start = target.elementAt(i);
    }
    return start;
  }
  
  
  min() {
    if (target.length == 0)
      throw new Exception("Cannot get maximum element of empty list");
    if (target.length == 1) return target.single;
    var start = target.first;
    for (int i = 1; i < target.length; i++) {
      if (target.elementAt(i) < start) start = target.elementAt(i);
    }
    return start;
  }
}



@proxy
class $list extends $iterable<List> {
  $list(List target) : super(target);
}

@proxy
class $libraryMirror extends $object<LibraryMirror> {
  $libraryMirror(LibraryMirror target) : super(target);
  
  Map<Symbol, ClassMirror> getClasses({bool recursive: true}) =>
      _getClassMirrors(recursive: recursive);
  
  Map<Symbol, ClassMirror> _getClassMirrors(
      {bool recursive: true, Set<LibraryMirror> doneLibraries}) {
    if (doneLibraries == null) doneLibraries = new Set();
    if (doneLibraries.contains(target)) return {};
    var result = new Map<Symbol, ClassMirror>();
    target.declarations.forEach((sym, declaration) {
      if (declaration is ClassMirror) result[sym] = declaration;
    });
    doneLibraries.add(target);
    if (recursive) {
      target.libraryDependencies.forEach((dependency) {
        if (dependency.targetLibrary is LibraryMirror) {
          result.addAll($(dependency.targetLibrary)
              ._getClassMirrors(doneLibraries: doneLibraries));
        }
      });
    }
    return result;
  }
}

@proxy
class $classMirror extends $object<ClassMirror> {
  $classMirror(ClassMirror target) : super(target);
  
  Map<Symbol, VariableMirror> get fields {
    var cm = target;
    if (cm.superclass == null) return {};
    var result = {};
    cm.declarations.forEach((sym, mirr) {
      if (mirr is VariableMirror) result[sym] = mirr;
    });
    result.addAll($(cm.superclass).fields);
    return result;
  }
}

@proxy
class $map extends $object<Map> {
  $map(Map target) : super(target);
  
  Map whereValue(bool test(value)) {
    return where((_, value) => test(value));
  }
  
  Map whereKey(bool test(key)) {
    return where((key, _) => test(key));
  }
  
  Map where(bool test(key, value)) {
    var result = {};
    target.forEach((k, v) {
      if (test(k, v)) result[k] = v;
    });
    return result;
  }
  
  Map mapValue(transform(value)) {
    var result = {};
    target.forEach((k, v) {
      result[k] = transform(v);
    });
    return result;
  }
  
  Map mapKey(transform(key)) {
    var result = {};
    target.forEach((k, v) {
      result[transform(k)] = v;
    });
    return result;
  }
  
  Map map(transformKey(key), transformValue(value)) {
    var result = {};
    target.forEach((k, v) {
      result[transformKey(k)] = transformValue(v);
    });
    return result;
  }
  
  List flatten(flatten(key, value)) {
    var result = [];
    target.forEach((k, v) {
      result.add(flatten(k, v));
    });
    return result;
  }
  
  bool operator==(other) {
    if (other is! Map && other is! $map) return false;
    var m = other is $map ? other.target : other;
    if (this.target.length != m.length) return false;
    for (var key in this.target.keys) {
      if (!($(this.target[key]) == $(m[key]))) return false;
    }
    return true;
  }
}

@proxy
class $object<E> {
  final E target;
  
  $object(this.target);
  
  noSuchMethod(Invocation invocation) {
    return reflect(target).delegate(invocation);
  }
  
  bool equalsOneOrMoreOf(List arg) => arg.any((elem) => target == elem);
  bool identicalToOneOrMoreOf(List arg) =>
      arg.any((elem) => identical(target, elem));
  
  ifNull(then) {
    if(target == null && then is Function) {
      return then();
    }
    return then;
  }
  
  ifNotNull(then) {
    if(target != null && then is Function) {
      return then();
    }
    return then;
  }
  
  bool operator ==(Object other) {
    if (other == null) return this.target == null;
    return other is $object ? target == other.target : target == other;
  }
  
  ClassMirror get classMirror => reflect(this).type;
  bool isNull() => target == null;
  
  Type get runtimeType => target.runtimeType;
  int get hashCode => target.hashCode;
  toString() => target.toString();
  void printSelf() => print(target);
}
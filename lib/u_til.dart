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

@proxy
class _$ {
  const _$();
  
  $object call([arg]) {
    if (arg is $object) return arg;
    if (arg is num || arg is int || arg is double) return new $num(arg);
    if (arg is List) return new $list(arg);
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
}

class $type extends $object {
  $type(Type target) : super(target);
  
  Symbol get qualifiedName => reflectType(target).qualifiedName;
  Symbol get simpleName => reflectType(target).simpleName;
}

@proxy
class $function extends $object {
  $function(Function target) : super(target);
  
  noSuchMethod(Invocation invocation) {
    return Function.apply(target, invocation.positionalArguments,
        invocation.namedArguments);
  }
}

@proxy
class $symbol extends $object {
  $symbol(Symbol target) : super(target);
  
  String get name => MirrorSystem.getName(target);
}

@proxy
class $num extends $object {
  $num(num target) : super(target);
  
  void times(f(int index), {int start: 0, bool reverse: false}) {
    if (!reverse) {
      for (int i = start; i < _target; i++) {
        f(i);
      }
      return;
    }
    for (int i = _target - 1; i >= start; i--) {
      f(i);
    }
  }
}

@proxy
class $list extends $object {
  $list(List target) : super(target);
  
  get randomElement => target[new Random().nextInt(target.length)];
  
  List extract(type) {
    var _type = type is $type ? type._target : type;
    return _target.where((elem) =>
        reflect(elem).type.isAssignableTo(reflectType(_type))).toList();
  }
  
  bool _isList(other) => other is List || other is $list;
  
  bool operator==(other) {
    if (!_isList(other)) return false;
    if (other.length != _target.length) return false;
    for (int i = 0; i < _target.length; i++) {
      if (!($(_target[i]) == other[i])) return false;
    }
    return true;
  }
}

@proxy
class $libraryMirror extends $object {
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
      _target.libraryDependencies.forEach((dependency) {
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
class $classMirror extends $object {
  $classMirror(ClassMirror target) : super(target);
  
  Map<Symbol, VariableMirror> get fields {
    var cm = target as ClassMirror;
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
class $map extends $object {
  $map(Map target) : super(target);
  
  Map retainWhereValue(bool test(value)) {
    var result = {};
    _target.forEach((k, v) {
      if (test(v)) result[k] = v;
    });
    return result;
  }
  
  Map retainWhereKey(bool test(key)) {
    var result = {};
    _target.forEach((k, v) {
      if (test(k)) result[k] = v;
    });
    return result;
  }
  
  Map retainWhere(bool test(key, value)) {
    var result = {};
    _target.forEach((k, v) {
      if (test(k, v)) result[k] = v;
    });
    return result;
  }
  
  Map transformValue(transform(value)) {
    var result = {};
    _target.forEach((k, v) {
      result[k] = transform(v);
    });
    return result;
  }
  
  Map transformKey(transform(key)) {
    var result = {};
    _target.forEach((k, v) {
      result[transform(k)] = v;
    });
    return result;
  }
  
  Map transform(transformKey(key), transformValue(value)) {
    var result = {};
    _target.forEach((k, v) {
      result[transformKey(k)] = transformValue(v);
    });
    return result;
  }
  
  List flatten(flatten(key, value)) {
    var result = [];
    _target.forEach((k, v) {
      result.add(flatten(k, v));
    });
    return result;
  }
}

@proxy
class $object {
  var _target;
  
  $object(this._target);
  
  noSuchMethod(Invocation invocation) {
    return reflect(_target).delegate(invocation);
  }
  
  bool equalsOneOrMoreOf(List arg) => arg.any((elem) => _target == elem);
  bool identicalToOneOrMoreOf(List arg) =>
      arg.any((elem) => identical(_target, elem));
  
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
  
  bool operator ==(Object other) =>
      other is $object ? _target == other.target : _target == other;
  
  ClassMirror get classMirror => reflect(this).type;
  bool isNull() => _target == null;
  
  get target => _target;
  
  Type get runtimeType => _target.runtimeType;
  int get hashCode => _target.hashCode;
  toString() => _target.toString();
  void printSelf() => print(_target);
}
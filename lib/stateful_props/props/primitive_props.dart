import '../stateful_properties.dart';

/// TODO: Add RestorationAPI support. Figure out how to check if a Restorable has been registered, and fallback to regular value if not.
class IntProp extends ValueProp<int> {
  IntProp([int defaultValue = 0]) : super(defaultValue);
}

class BoolProp extends ValueProp<bool> {
  BoolProp([bool defaultValue = false]) : super(defaultValue);

  void toggle() => value = !value;
}

class DoubleProp extends ValueProp<double> {
  DoubleProp([double defaultValue = 0]) : super(defaultValue);
}

class ValueProp<T> extends StatefulProp<ValueProp<T>> {
  ValueProp(this._value);

  T _value;
  T get value => _value;
  set value(T value) {
    if (value == _value) return;
    _value = value;
    setState(() {});
  }
}

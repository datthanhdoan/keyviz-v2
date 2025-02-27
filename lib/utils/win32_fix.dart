// File này được tạo để sửa lỗi UnmodifiableUint8ListView trong thư viện win32
// Nó sẽ được import trước khi sử dụng win32

import 'dart:typed_data';
import 'package:collection/collection.dart';

// Định nghĩa lại UnmodifiableUint8ListView nếu chưa tồn tại
class UnmodifiableUint8ListView extends UnmodifiableListView<int> {
  UnmodifiableUint8ListView(Iterable<int> list) : super(list);
}

// Định nghĩa lại GUID để tránh sử dụng UnmodifiableUint8ListView
class GUID {
  final Uint8List _data;

  GUID(List<int> data) : _data = Uint8List.fromList(data);

  Uint8List get data => _data;

  @override
  String toString() {
    return 'GUID(${_data.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GUID && _data.equals(other._data);
  }

  @override
  int get hashCode => _data.hashCode;
  
  static GUID fromString(String guidString) {
    final List<int> data = guidString.split('-').map((part) => int.parse(part, radix: 16)).expand((i) => [i]).toList();
    return GUID(data);
  }
} 
import 'dart:async';

class StreamManager<T> {
  // 1. Variabel privat untuk menyimpan data saat ini (State)
  T _currentValue;

  // 2. StreamController dengan mode broadcast
  final StreamController<T> _controller = StreamController<T>.broadcast();

  // 3. Constructor dengan Default Data (Initial Data)
  StreamManager(this._currentValue);

  // 4. Getter untuk mengambil current data secara sinkron
  T get value => _currentValue;

  // 5. Getter untuk Stream (untuk widget penerima)
  Stream<T> get stream => _controller.stream;

  // 6. Fungsi untuk memperbarui data dan mengirim event
  void emit(T newData) {
    if (!_controller.isClosed) {
      _currentValue = newData; // Update state internal
      _controller.sink.add(newData); // Kirim ke semua listener
    }
  }

  void dispose() {
    _controller.close();
  }
}

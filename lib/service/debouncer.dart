import 'dart:async';

/// A generic debouncer that delays and deduplicates rapid successive calls.
///
/// [Debouncer] is useful for deferring expensive operations (like API calls, searches,
/// or validations) until the user stops triggering them. For example, in a search field,
/// instead of making an API call on every keystroke, the debouncer waits for the user
/// to stop typing before executing the search.
///
/// How it works:
/// 1. When [run()] is called, any previously scheduled action is cancelled
/// 2. A new timer starts for the specified [delay]
/// 3. If [run()] is called again before the timer completes, the timer is reset
/// 4. When the timer finally completes, the action is executed
/// 5. The returned Future completes with the action's result
///
/// Example - debounced search:
/// ```dart
/// final debouncer = Debouncer<List<String>>(delay: Duration(milliseconds: 500));
///
/// searchField.onChanged = (value) {
///   debouncer.run(() async {
///     final results = await searchApi.search(value);
///     return results;
///   }).then((results) {
///     setState(() => searchResults = results);
///   });
/// };
/// ```
class Debouncer<T> {
  /// The delay duration to wait before executing the action.
  ///
  /// After calling [run()], the action will be executed after this delay
  /// unless [run()] is called again (which resets the timer).
  final Duration delay;

  /// The timer that schedules the delayed action execution.
  ///
  /// Kept as a class field so it can be cancelled when a new call to [run()] arrives.
  Timer? _timer;

  /// The completer that resolves the future returned by [run()].
  ///
  /// Reused across multiple calls to [run()] if the previous call's action
  /// hasn't completed yet. A new completer is created when the previous one completes.
  Completer<T>? _completer;

  /// Creates a new [Debouncer] with the specified delay.
  ///
  /// The [delay] parameter is required and determines how long to wait
  /// after the last [run()] call before executing the action.
  ///
  /// Example: `Debouncer<String>(delay: Duration(milliseconds: 300))`
  Debouncer({required this.delay});

  /// Schedules an action to run after the delay, cancelling any previously scheduled action.
  ///
  /// Each call to [run()] cancels the previous timer, effectively resetting the delay.
  /// This ensures that rapid successive calls will only execute the action once,
  /// after the delay period has passed since the last call.
  ///
  /// The action can be synchronous or asynchronous (returns FutureOr&lt;T&gt;).
  /// The returned Future completes when the action finishes executing.
  ///
  /// Returns a [Future] that completes with the action's result (of type T),
  /// or completes with an error if the action throws or is cancelled.
  ///
  /// Parameters:
  ///   - [action]: A function that performs the debounced work. Can be async or sync.
  ///
  /// Example:
  /// ```dart
  /// final future = debouncer.run(() async {
  ///   return await expensiveOperation();
  /// });
  ///
  /// future.then((result) {
  ///   print('Result: $result');
  /// }).catchError((error) {
  ///   print('Error: $error');
  /// });
  /// ```
  Future<T> run(FutureOr<T> Function() action) {
    _timer?.cancel();

    if (_completer == null || _completer?.isCompleted == true) {
      _completer = Completer<T>();
    }

    _timer = Timer(delay, () async {
      try {
        final result = await action();
        _completer?.complete(result);
      } catch (e) {
        _completer?.completeError(e);
      }
    });

    return _completer!.future;
  }

  /// Cancels the pending debounced action and completes the future with an error.
  ///
  /// If an action is currently scheduled via [run()], this method:
  /// 1. Cancels the pending timer
  /// 2. Completes the returned future with a 'Debounce cancelled' error
  ///
  /// This is useful when cleaning up (e.g., when a widget is disposed) to ensure
  /// pending operations don't complete after the widget is destroyed, which could
  /// cause "mounted check failed" errors.
  ///
  /// Calling [cancel()] when no action is scheduled is safe (no-op).
  ///
  /// Example - cancelling in dispose:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   debouncer.cancel(); // Cancel any pending search
  ///   super.dispose();
  /// }
  /// ```
  void cancel() {
    _timer?.cancel();
    if (!(_completer?.isCompleted == true)) {
      _completer?.completeError('Debounce cancelled');
    }
  }
}

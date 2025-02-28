import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:hid_listener/hid_listener.dart';
import 'package:window_size/window_size.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/domain/services/raw_keyboard_mouse.dart';
import 'package:keyviz/domain/vault/vault.dart';

import 'key_event_data.dart';

export 'key_event_data.dart';

// modifiers in a keyboard
enum ModifierKey {
  control("Control"),
  shift("Shift"),
  alt("Alt"),
  meta("Meta");

  const ModifierKey(this.label);
  final String label;

  String get keyLabel {
    if (this == ModifierKey.alt) {
      if (Platform.isMacOS) {
        return "Option";
      }
    } else if (this == ModifierKey.meta) {
      if (Platform.isWindows) {
        return "Win";
      } else if (Platform.isMacOS) {
        return "Command";
      }
    }

    return label;
  }
}

// key visualization history mode
enum VisualizationHistoryMode {
  none("None"),
  vertical('Vertical'),
  horizontal('Horizontal');

  const VisualizationHistoryMode(this.label);
  final String label;

  @override
  String toString() => label;
}

// keycap animation style
enum KeyCapAnimationType {
  none("None"),
  fade("Fade"),
  wham("Focus"),
  grow("Grow"),
  slide("Slide");

  const KeyCapAnimationType(this.label);
  final String label;

  @override
  String toString() => label;
}

extension on MouseEvent {
  Offset get offset => Offset(x, y);
}

/// keyboard event provider and related configurations
class KeyEventProvider extends ChangeNotifier with TrayListener {
  KeyEventProvider() {
    _init();
  }

  // index of current screen in the screens list
  int _screenIndex = 0;

  // display/screens list
  final List<Screen> _screens = [];

  // an offset to adapt origin from topLeft
  // to bottomRight on macOS for mouse events
  Offset _macOSMouseOriginOffset = Offset.zero;

  // errors
  bool _hasError = false;

  // toggle for styling, if true keeps the events
  // on display unless changed by others
  bool _styling = false;

  // keyboard event listener id
  int? _mouseListenerId;

  // cursor position
  Offset _cursorOffset = Offset.zero;

  // first cursor down offset
  Offset? _firstCursorOffset;

  // cursor button down state
  bool _mouseButtonDown = false;

  // track gap between mouse down and up
  int? _mouseButtonDownTimestamp;

  // mouse left button down and mouse moving
  bool _dragging = false;

  // keyboard event listener id
  int? _keyboardListenerId;

  // list of key id's currently hold down
  final Map<int, RawKeyDownEvent> _keyDown = {};

  // unfiltered keyboard event ids list
  final List<int> _unfilteredEvents = [];

  // tracking variable for every key down
  // follwed by key up  synchronously
  bool _lastKeyDown = false;
  bool _keyUpFollowed = true;

  // id for each key events group
  String? _groupId;

  // main list of key events to be consumed by the visualizer
  // may not include history is historyMode is set to none
  final Map<String, Map<int, KeyEventData>> _keyboardEvents = {};

  // filter letters, numbers, symbols, etc. and
  // show hotkeys/keyboard shortuts
  bool _filterHotkeys = _Defaults.filterHotkeys;

  // modifiers and function keys to ignore
  // when hotkey filter is turned on
  final Map<ModifierKey, bool> _ignoreKeys = {
    ModifierKey.control: false,
    ModifierKey.shift: true,
    ModifierKey.alt: false,
    ModifierKey.meta: false,
  };

  // whether to show history, if yes
  // then vertically or horizontally
  VisualizationHistoryMode _historyMode = _Defaults.historyMode;

  // max history number
  // TODO calculate based on keycap height and screen size
  final int _maxHistory = 6;

  // global keyviz toggle shortcut, list of keyIds
  // default [Shift] + [F10]
  List<int> keyvizToggleShortcut = _Defaults.toggleShortcut;

  // display events in the visualizer
  bool _visualizeEvents = true;

  // amount of time the visualization stays on the screen in seconds
  int _lingerDurationInSeconds = _Defaults.lingerDurationInSeconds;

  // key cap animation speed in milliseconds
  int _animationSpeed = _Defaults.animationSpeed;

  // keycap animation type
  KeyCapAnimationType _keyCapAnimation = _Defaults.keyCapAnimation;

  // mouse visualize clicks
  bool _showMouseClicks = _Defaults.showMouseClicks;

  // mouse visualize clicks
  bool _highlightCursor = _Defaults.highlightCursor;

  // show mouse events with keypress like, [Shift] + [Drag]
  bool _showMouseEvents = _Defaults.showMouseEvents;

  // Thời gian chờ trước khi fade biến mất trong chế độ lịch sử (giây)
  int _historyFadeDelayInSeconds = _Defaults.historyFadeDelayInSeconds;
  
  // Số bước fade khi biến mất
  int _fadeSteps = _Defaults.fadeSteps;
  
  // Hiển thị số lần bấm phím (combo count)
  bool _showComboCount = _Defaults.showComboCount;
  
  // Số lần bấm tối thiểu để hiển thị combo count
  int _minComboCount = _Defaults.minComboCount;

  Screen get _currentScreen => _screens[_screenIndex];

  Map<String, Map<int, KeyEventData>> get keyboardEvents => _keyboardEvents;
  int get screenIndex => _screenIndex;
  List<Screen> get screens => _screens;
  bool get styling => _styling;
  bool get visualizeEvents => _visualizeEvents;
  bool get hasError => _hasError;

  bool get filterHotkeys => _filterHotkeys;
  Map<ModifierKey, bool> get ignoreKeys => _ignoreKeys;
  VisualizationHistoryMode get historyMode => _historyMode;
  Axis? get historyDirection {
    switch (_historyMode) {
      case VisualizationHistoryMode.none:
        return null;

      case VisualizationHistoryMode.horizontal:
        return Axis.horizontal;

      case VisualizationHistoryMode.vertical:
        return Axis.vertical;
    }
  }

  int get lingerDurationInSeconds => _lingerDurationInSeconds;
  Duration get lingerDuration => Duration(seconds: _lingerDurationInSeconds);
  int get animationSpeed => _animationSpeed;
  Duration get animationDuration => Duration(milliseconds: _animationSpeed);
  KeyCapAnimationType get keyCapAnimation => _keyCapAnimation;
  bool get noKeyCapAnimation => _keyCapAnimation == KeyCapAnimationType.none;
  bool get showMouseClicks => _visualizeEvents ? _showMouseClicks : false;
  bool get highlightCursor => _highlightCursor;
  bool get showMouseEvents => _showMouseEvents;
  Offset get cursorOffset => _cursorOffset;
  bool get mouseButtonDown => _mouseButtonDown;

  bool get _ignoreHistory {
    // Luôn trả về true nếu đang trong chế độ styling
    if (_styling) return true;
    // Chỉ trả về true nếu historyMode là none
    return _historyMode == VisualizationHistoryMode.none;
  }

  // Getter và setter cho các biến cài đặt mới
  int get historyFadeDelayInSeconds => _historyFadeDelayInSeconds;
  int get fadeSteps => _fadeSteps;
  bool get showComboCount => _showComboCount;
  int get minComboCount => _minComboCount;

  set screenIndex(int value) {
    _screenIndex = value;
    _changeDisplay();
  }

  set styling(bool value) {
    if (_hasError) return;
    _styling = value;
    windowManager.setIgnoreMouseEvents(!value);
    notifyListeners();
  }

  set filterHotkeys(bool value) {
    _filterHotkeys = value;
    notifyListeners();
    _saveSettings();
  }

  void setModifierKeyIgnoring(ModifierKey key, bool ingnoring) {
    _ignoreKeys[key] = ingnoring;
    notifyListeners();
  }

  set historyMode(VisualizationHistoryMode value) {
    _historyMode = value;
    notifyListeners();
    _saveSettings();
  }

  set lingerDurationInSeconds(int value) {
    _lingerDurationInSeconds = value;
    notifyListeners();
    _saveSettings();
  }

  set animationSpeed(value) {
    _animationSpeed = value;
    notifyListeners();
    _saveSettings();
  }

  set keyCapAnimation(KeyCapAnimationType value) {
    _keyCapAnimation = value;
    notifyListeners();
    _saveSettings();
  }

  set showMouseClicks(bool value) {
    _showMouseClicks = value;
    notifyListeners();
    _saveSettings();
  }

  set highlightCursor(bool value) {
    _highlightCursor = value;
    notifyListeners();
    _saveSettings();
  }

  set showMouseEvents(bool value) {
    _showMouseEvents = value;
    notifyListeners();
    _saveSettings();
  }

  set historyFadeDelayInSeconds(int value) {
    _historyFadeDelayInSeconds = value;
    notifyListeners();
    _saveSettings();
  }

  set fadeSteps(int value) {
    _fadeSteps = value;
    notifyListeners();
    _saveSettings();
  }

  set showComboCount(bool value) {
    _showComboCount = value;
    notifyListeners();
    _saveSettings();
  }

  set minComboCount(int value) {
    _minComboCount = value;
    notifyListeners();
    _saveSettings();
  }

  _toggleVisualizer() {
    _visualizeEvents = !_visualizeEvents;
    _setTrayIcon();
    _setTrayContextMenu();
    notifyListeners();
  }

  _init() async {
    // load data
    await _updateFromJson();
    // register mouse event listener
    _registerMouseListener();
    // register keyboard event listener
    _registerKeyboardListener();
    // setup tray manager
    trayManager.addListener(this);
    await _setTrayIcon();
    await _setTrayContextMenu();
    
    // Đảm bảo historyMode được áp dụng đúng cách
    _applyHistoryMode();
  }

  _registerMouseListener() async {
    _mouseListenerId = getListenerBackend()!.addMouseListener(_onMouseEvent);

    if (_mouseListenerId == null) {
      _hasError = true;
      notifyListeners();
      debugPrint("couldn't register mouse listener");
    } else {
      debugPrint("registered mouse listener");
    }
  }

  _onMouseEvent(MouseEvent event) {
    // visualizer toggle
    if (!_visualizeEvents) return;
    // process mouse event
    event.x -= _currentScreen.frame.left;
    if (!Platform.isMacOS) {
      event.y -= _currentScreen.frame.top;

      event.x /= _currentScreen.scaleFactor;
      event.y /= _currentScreen.scaleFactor;
    } else {
      event.y -= _macOSMouseOriginOffset.dy;
    }
    // mouse moved
    if (event is MouseMoveEvent) {
      _onMouseMove(event);
    }
    // mouse button clicked/released
    else if (event is MouseButtonEvent) {
      _onMouseButton(event);
    }
    // mouse wheel scrolled
    else if (event is MouseWheelEvent) {
      _onMouseWheel(event);
    }
  }

  _onMouseMove(MouseMoveEvent event) {
    bool notify = false;
    _cursorOffset = event.offset;
    // animate cursor position when cursor highlighted
    if (_highlightCursor || _dragging) {
      notify = true;
    }

    // drag threshold
    final dragDistance = _firstCursorOffset == null
        ? 0
        : (_firstCursorOffset! - cursorOffset).distance.abs();

    // drag started
    if (dragDistance >= 64 && !_dragging) {
      _dragging = true;

      // show mouse events in key visualizer
      if (_showMouseEvents) {
        // remove left/right click event
        _keyDown.removeWhere(
          (_, event) =>
              event.logicalKey.keyId == leftClickId ||
              event.logicalKey.keyId == rightClickId,
        );
        _keyboardEvents[_groupId]?.removeWhere(
          (_, value) =>
              value.rawEvent.logicalKey.keyId == leftClickId ||
              value.rawEvent.logicalKey.keyId == rightClickId,
        );

        // drag event pressed down
        _onKeyDown(
          const RawKeyDownEvent(data: RawKeyEventDataMouse.drag()),
        );

        notify = true;
      }
    }

    if (notify) notifyListeners();
  }

  _onMouseButton(MouseButtonEvent event) {
    final wasDragging = _dragging;
    final leftOrRightDown = event.type == MouseButtonEventType.leftButtonDown ||
        event.type == MouseButtonEventType.rightButtonDown;

    if (_dragging && leftOrRightDown) {
      _dragging = false;
    }

    // update offset
    _cursorOffset = event.offset;

    // mouse button down
    if (leftOrRightDown) {
      _mouseButtonDown = true;
      _firstCursorOffset = event.offset;

      if (_showMouseClicks) {
        _mouseButtonDownTimestamp = DateTime.now().millisecondsSinceEpoch;
        notifyListeners();
      }
    }
    // mouse button up
    else {
      _firstCursorOffset = null;

      if (_showMouseClicks) {
        final diff = _mouseButtonDownTimestamp == null
            ? 200
            : DateTime.now().millisecondsSinceEpoch -
                _mouseButtonDownTimestamp!;
        _mouseButtonDownTimestamp = null;

        // enforce minimum transition duration for smooth animation
        if (diff < 200) {
          Future.delayed(Duration(milliseconds: 200 - diff)).then(
            (_) {
              _mouseButtonDown = false;
              notifyListeners();
            },
          );
        } else {
          _mouseButtonDown = false;
          notifyListeners();
        }
      }
      // set it right away
      else {
        _mouseButtonDown = false;
      }
    }

    if (_showMouseEvents) {
      switch (event.type) {
        case MouseButtonEventType.leftButtonDown:
          _onKeyDown(
            const RawKeyDownEvent(data: RawKeyEventDataMouse.leftClick()),
          );
          break;

        case MouseButtonEventType.leftButtonUp:
          _onKeyUp(
            RawKeyUpEvent(
              data: wasDragging
                  ? const RawKeyEventDataMouse.drag()
                  : const RawKeyEventDataMouse.leftClick(),
            ),
          );
          break;

        case MouseButtonEventType.rightButtonDown:
          _onKeyDown(
            const RawKeyDownEvent(data: RawKeyEventDataMouse.rightClick()),
          );
          break;

        case MouseButtonEventType.rightButtonUp:
          _onKeyUp(
            RawKeyUpEvent(
              data: wasDragging
                  ? const RawKeyEventDataMouse.drag()
                  : const RawKeyEventDataMouse.rightClick(),
            ),
          );
          break;
      }
    }
  }

  // mouse wheel delta
  int _wheelDelta = 0;

  _onMouseWheel(MouseWheelEvent event) {
    // scroll started
    if (_wheelDelta == 0) {
      // dispatch scroll event
      _onKeyDown(
        const RawKeyDownEvent(data: RawKeyEventDataMouse.scroll()),
      );
    }
    _wheelDelta += event.wheelDelta;

    _isScrollStopped(_wheelDelta);
  }

  _isScrollStopped(int delta) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // scroll stopped
    if (delta == _wheelDelta) {
      // dispatch key up event
      _onKeyUp(
        const RawKeyUpEvent(data: RawKeyEventDataMouse.scroll()),
      );
      // reset wheel delta
      _wheelDelta = 0;
    }
  }

  _removeMouseListener() {
    if (_mouseListenerId != null) {
      getListenerBackend()!.removeKeyboardListener(_mouseListenerId!);
    }
  }

  _registerKeyboardListener() async {
    _keyboardListenerId =
        getListenerBackend()!.addKeyboardListener(_onRawKeyEvent);

    if (_keyboardListenerId == null) {
      _hasError = true;
      notifyListeners();
      debugPrint("cannot register keyboard listener!");
    } else {
      debugPrint("keyboard listener registered");
    }
  }

  _onRawKeyEvent(RawKeyEvent event) {
    // key pressed
    if (event is RawKeyDownEvent && !_keyDown.containsKey(event.keyId)) {
      // check for shortcut pressed
      _unfilteredEvents.add(event.keyId);
      if (listEquals(_unfilteredEvents, keyvizToggleShortcut)) {
        _toggleVisualizer();
      }

      if (_visualizeEvents) _onKeyDown(event);
    }
    // key released
    else if (event is RawKeyUpEvent) {
      _unfilteredEvents.remove(event.keyId);

      if (_visualizeEvents) _onKeyUp(event);
    }
  }

  _onKeyDown(RawKeyDownEvent event) {
    // filter hotkey
    if (_filterHotkeys && !_eventIsHotkey(event)) {
      debugPrint("⬇️ [${event.data.keyLabel}] not hotkey, returning...");
      return;
    }

    // filter unknown key
    if (event.logicalKey.keyLabel == "") {
      // fake mouse event
      if (event.data is! RawKeyEventDataMouse) {
        debugPrint("⬇️ ignoring [${event.label}]");
        return;
      }
    }

    // init group id
    _groupId ??= _timestamp;
    // create group if not created
    if (!_keyboardEvents.containsKey(_groupId)) {
      _keyboardEvents[_groupId!] = {};
    }

    // Kiểm tra xem phím đã được bấm trước đó chưa và đang trong cùng một group
    if (_keyboardEvents[_groupId]?.containsKey(event.keyId) ?? false) {
      final data = _keyboardEvents[_groupId]![event.keyId]!;
      final newPressedCount = data.pressedCount + 1;
      final shouldShowCombo = _showComboCount && newPressedCount >= _minComboCount;
      
      debugPrint("Key pressed again: ${event.label}");
      debugPrint("Current count: $newPressedCount");
      debugPrint("Show combo enabled: $_showComboCount");
      debugPrint("Min combo count: $_minComboCount");
      debugPrint("Should show combo: $shouldShowCombo");
      
      // Cập nhật KeyEventData với pressedCount mới và hiển thị combo nếu đủ điều kiện
      _keyboardEvents[_groupId]![event.keyId] = KeyEventData(
        event,
        pressed: true,
        show: true,
        pressedCount: newPressedCount,
        showPressCount: shouldShowCombo,
        opacity: 1.0,
      );
      
      // Xóa các phím khác nếu đang trong combo
      if (_keyDown.length == 1) {
        _keyboardEvents[_groupId]!.removeWhere((key, _) => key != event.keyId);
      }
      
      _keyDown[event.keyId] = event;
      notifyListeners();
      return;
    }

    // Tạo KeyEventData mới cho phím chưa được bấm
    final keyEventData = KeyEventData(
      event,
      pressed: true,
      show: !noKeyCapAnimation,
      pressedCount: 1,
      showPressCount: false,
      opacity: 1.0,
    );

    // track key pressed down
    _keyDown[event.keyId] = event;
    _keyboardEvents[_groupId]![event.keyId] = keyEventData;

    // animate with configured key cap animation
    if (!noKeyCapAnimation) {
      _animateIn(_groupId!, event.keyId);
    }

    notifyListeners();
    debugPrint("⬇️ [${event.label}]");
    _lastKeyDown = true;
  }

  _onKeyUp(RawKeyUpEvent event) async {
    // track key pressed up
    final removedEvent = _keyDown.remove(event.keyId);

    // sanity check
    if (removedEvent == null || _groupId == null) return;

    _animateOut(_groupId!, event.keyId);

    debugPrint("⬆️ [${event.label}]");

    // no keys pressed or only left with mouse events
    if (_keyDown.isEmpty) {
      // track all keys removed
      _keyUpFollowed = true;
      // reset _groupId when there are no keys pressed
      if (!_ignoreHistory) _groupId = null;
    } else {
      // track key combinations
      if (_lastKeyDown) {
        _lastKeyDown = false;
        _keyUpFollowed = false;
      }
    }
  }

  _animateIn(String groupId, int keyId) async {
    // wait for background bar to expand
    await Future.delayed(animationDuration);
    // set show to true
    final event = _keyboardEvents[groupId]?[keyId];
    if (event != null) {
      _keyboardEvents[groupId]![keyId] = event.copyWith(show: true);
      notifyListeners();
    }
  }

  _animateOut(String groupId, int keyId) async {
    Future.delayed(Duration(seconds: _historyFadeDelayInSeconds), () {
      if (_keyboardEvents.containsKey(groupId)) {
        final events = _keyboardEvents[groupId]!;
        
        // Sử dụng _fadeSteps để tạo hiệu ứng mờ dần
        for (int i = 1; i <= _fadeSteps; i++) {
          Future.delayed(Duration(milliseconds: i * 100), () {
            for (final event in events.values) {
              _keyboardEvents[groupId]![event.rawEvent.keyId] = event.copyWith(
                opacity: 1.0 - (i / _fadeSteps),
              );
            }
            notifyListeners();
          });
        }
        
        // Xóa sự kiện sau khi hoàn tất hiệu ứng mờ dần
        Future.delayed(Duration(milliseconds: _fadeSteps * 100), () {
          _keyboardEvents.remove(groupId);
          notifyListeners();  
        });
      }
    });
  }

  _removeKeyboardListener() {
    if (_keyboardListenerId != null) {
      getListenerBackend()!.removeKeyboardListener(_keyboardListenerId!);
    }
  }

  bool _eventIsHotkey(RawKeyDownEvent event) {
    if (_keyDown.isEmpty) {
      // event should be a modifier and not ignored
      return !event.isMouse &&
              (!_ignoreKeys[ModifierKey.control]! && event.isControl) ||
          (!_ignoreKeys[ModifierKey.meta]! && event.isMeta) ||
          (!_ignoreKeys[ModifierKey.alt]! && event.isAlt) ||
          (!_ignoreKeys[ModifierKey.shift]! && event.isShift);
    } else {
      // modifier should be pressed down
      return _keyDown.values.first.isModifier;
    }
  }

  String get _timestamp {
    final now = DateTime.now();
    return "${now.minute}${now.second}${now.millisecond}";
  }

  _setTrayIcon() async {
    if (_visualizeEvents) {
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/img/tray-on.ico'
            : 'assets/img/tray-on.png',
      );
    } else {
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/img/tray-off.ico'
            : 'assets/img/tray-off.png',
      );
    }
  }

  _setTrayContextMenu() async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final isVietnamese = locale.languageCode == 'vi';
    
    final closeLabel = isVietnamese ? 'Đóng' : 'Close';
    final openLabel = isVietnamese ? 'Mở' : 'Open';
    final settingsLabel = isVietnamese ? 'Cài đặt' : 'Settings';
    final openSettingsTooltip = isVietnamese ? 'Mở cửa sổ cài đặt' : 'Open settings window';
    final exitLabel = isVietnamese ? 'Thoát' : 'Exit';
    final closeAppTooltip = isVietnamese ? 'Đóng Keyviz' : 'Close Keyviz';
    
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: "toggle",
            label: _visualizeEvents ? "✗ $closeLabel" : "✓ $openLabel",
          ),
          MenuItem(
            key: "settings",
            label: settingsLabel,
            toolTip: openSettingsTooltip,
          ),
          MenuItem.separator(),
          MenuItem(
            key: "quit",
            label: exitLabel,
            toolTip: closeAppTooltip,
          ),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    super.onTrayIconMouseDown();
    _toggleVisualizer();
  }

  @override
  void onTrayIconRightMouseDown() async {
    super.onTrayIconRightMouseDown();
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    super.onTrayMenuItemClick(menuItem);

    switch (menuItem.key) {
      case "toggle":
        _toggleVisualizer();
        break;

      case "settings":
        styling = !_styling;
        break;

      case "quit":
        windowManager.close();
        break;
    }
  }

  Map<String, dynamic> get toJson => {
        _JsonKeys.screenFrame: [
          _screens[_screenIndex].frame.width,
          _screens[_screenIndex].frame.height,
        ],
        _JsonKeys.filterHotkeys: _filterHotkeys,
        _JsonKeys.ignoreKeys: {
          ModifierKey.control.name: _ignoreKeys[ModifierKey.control],
          ModifierKey.shift.name: _ignoreKeys[ModifierKey.shift],
          ModifierKey.alt.name: _ignoreKeys[ModifierKey.alt],
          ModifierKey.meta.name: _ignoreKeys[ModifierKey.meta],
        },
        _JsonKeys.historyMode: _historyMode.name,
        _JsonKeys.toggleShortcut: keyvizToggleShortcut,
        _JsonKeys.lingerDurationInSeconds: _lingerDurationInSeconds,
        _JsonKeys.animationSpeed: _animationSpeed,
        _JsonKeys.keyCapAnimation: _keyCapAnimation.name,
        _JsonKeys.showMouseClicks: _showMouseClicks,
        _JsonKeys.highlightCursor: _highlightCursor,
        _JsonKeys.showMouseEvents: _showMouseEvents,
        _JsonKeys.historyFadeDelayInSeconds: _historyFadeDelayInSeconds,
        _JsonKeys.fadeSteps: _fadeSteps,
        _JsonKeys.showComboCount: _showComboCount,
        _JsonKeys.minComboCount: _minComboCount,
      };

  _updateFromJson() async {
    final data = await Vault.loadConfigData();
    
    // set preferred display
    _setDisplay(data?[_JsonKeys.screenFrame]);

    if (data == null) return;

    _filterHotkeys = data[_JsonKeys.filterHotkeys] ?? _Defaults.filterHotkeys;

    final ignoreKeys = data[_JsonKeys.ignoreKeys];
    if (ignoreKeys != null) {
      for (final key in ignoreKeys.keys) {
        switch (key) {
          case "control":
            _ignoreKeys[ModifierKey.control] = ignoreKeys[key];
            break;

          case "shift":
            _ignoreKeys[ModifierKey.shift] = ignoreKeys[key];
            break;

          case "alt":
            _ignoreKeys[ModifierKey.alt] = ignoreKeys[key];
            break;

          case "meta":
            _ignoreKeys[ModifierKey.meta] = ignoreKeys[key];
            break;
        }
      }
    }

    switch (data[_JsonKeys.historyMode]) {
      case "none":
        _historyMode = VisualizationHistoryMode.none;
        break;

      case "vertical":
        _historyMode = VisualizationHistoryMode.vertical;
        break;

      case "horizontal":
        _historyMode = VisualizationHistoryMode.horizontal;
        break;
        
      default:
        // Đảm bảo historyMode luôn có giá trị hợp lệ
        _historyMode = _Defaults.historyMode;
        break;
    }
    
    // Ghi log để debug
    debugPrint("Loaded historyMode: $_historyMode");

    final toggleShortcut = data[_JsonKeys.toggleShortcut];
    if (toggleShortcut != null) {
      keyvizToggleShortcut = List<int>.from(toggleShortcut);
    }

    _lingerDurationInSeconds =
        data[_JsonKeys.lingerDurationInSeconds] ?? _Defaults.lingerDurationInSeconds;
    _animationSpeed = data[_JsonKeys.animationSpeed] ?? _Defaults.animationSpeed;

    switch (data[_JsonKeys.keyCapAnimation]) {
      case "none":
        _keyCapAnimation = KeyCapAnimationType.none;
        break;

      case "fade":
        _keyCapAnimation = KeyCapAnimationType.fade;
        break;

      case "wham":
        _keyCapAnimation = KeyCapAnimationType.wham;
        break;

      case "grow":
        _keyCapAnimation = KeyCapAnimationType.grow;
        break;

      case "slide":
        _keyCapAnimation = KeyCapAnimationType.slide;
        break;
    }

    _showMouseClicks =
        data[_JsonKeys.showMouseClicks] ?? _Defaults.showMouseClicks;
    _highlightCursor =
        data[_JsonKeys.highlightCursor] ?? _Defaults.highlightCursor;
    _showMouseEvents =
        data[_JsonKeys.showMouseEvents] ?? _Defaults.showMouseEvents;
        
    // Tải các cài đặt mới
    _historyFadeDelayInSeconds = 
        data[_JsonKeys.historyFadeDelayInSeconds] ?? _Defaults.historyFadeDelayInSeconds;
    _fadeSteps = 
        data[_JsonKeys.fadeSteps] ?? _Defaults.fadeSteps;
    _showComboCount = 
        data[_JsonKeys.showComboCount] ?? _Defaults.showComboCount;
    _minComboCount = 
        data[_JsonKeys.minComboCount] ?? _Defaults.minComboCount;
  }

  _setDisplay(List? frame) async {
    _screens.addAll(await getScreenList());

    if (frame != null) {
      final index = _screens.indexWhere(
        (screen) =>
            screen.frame.width == frame[0] && screen.frame.height == frame[1],
      );

      if (index != -1) _screenIndex = index;
    }

    if (Platform.isMacOS) {
      _macOSMouseOriginOffset =
          _screens[0].frame.bottomLeft - _currentScreen.frame.bottomLeft;
    }

    setWindowFrame(_currentScreen.frame);

    windowManager.show();
  }

  _changeDisplay() async {
    if (Platform.isMacOS) {
      _macOSMouseOriginOffset =
          _screens[0].frame.bottomLeft - _currentScreen.frame.bottomLeft;
      setWindowFrame(_currentScreen.frame);
    } else {
      await windowManager.setFullScreen(false);
      await windowManager.hide();

      setWindowFrame(_currentScreen.frame);
      // simulate delay for above
      await Future.delayed(Durations.extralong2);
      await windowManager.setFullScreen(true);
      await windowManager.show();
    }
    notifyListeners();
  }

  revertToDefaults() {
    _filterHotkeys = _Defaults.filterHotkeys;
    for (final modifier in ModifierKey.values) {
      _ignoreKeys[modifier] = _Defaults.ignoreKeys[modifier] ?? false;
    }
    _historyMode = _Defaults.historyMode;
    keyvizToggleShortcut = _Defaults.toggleShortcut;
    _lingerDurationInSeconds = _Defaults.lingerDurationInSeconds;
    _animationSpeed = _Defaults.animationSpeed;
    _keyCapAnimation = _Defaults.keyCapAnimation;
    _showMouseClicks = _Defaults.showMouseClicks;
    _highlightCursor = _Defaults.highlightCursor;
    _showMouseEvents = _Defaults.showMouseEvents;
    
    // Đặt lại các cài đặt mới về giá trị mặc định
    _historyFadeDelayInSeconds = _Defaults.historyFadeDelayInSeconds;
    _fadeSteps = _Defaults.fadeSteps;
    _showComboCount = _Defaults.showComboCount;
    _minComboCount = _Defaults.minComboCount;

    notifyListeners();
    
    // Lưu cài đặt sau khi khôi phục về mặc định
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _getGlobalContext();
      if (context != null) {
        Vault.save(context);
      }
    });
  }

  BuildContext? _getGlobalContext() {
    // Sử dụng cách khác để lấy context
    try {
      // Thử sử dụng rootElement nếu có thể truy cập
      final rootElement = WidgetsBinding.instance.rootElement;
      if (rootElement != null) {
        return rootElement;
      }
      
      return null;
    } catch (e) {
      debugPrint('Không thể lấy context: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _removeMouseListener();
    _removeKeyboardListener();
    trayManager.removeListener(this);
    super.dispose();
  }

  // Phương thức để lưu cài đặt
  _saveSettings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _getGlobalContext();
      if (context != null) {
        Vault.save(context);
      }
    });
  }

  // Phương thức để đảm bảo historyMode được áp dụng đúng cách
  _applyHistoryMode() {
    // Ghi log để debug
    debugPrint("Applying historyMode: $_historyMode");
    
    // Đảm bảo historyMode được áp dụng đúng cách
    if (_historyMode != VisualizationHistoryMode.none) {
      // Đảm bảo _ignoreHistory được tính toán lại
      notifyListeners();
    }
  }
}

class _JsonKeys {
  static const screenFrame = "screen_frame";
  static const filterHotkeys = "filter_hotkeys";
  static const ignoreKeys = "ignore_keys";
  static const historyMode = "history_mode";
  static const toggleShortcut = "toggle_shortcut";
  static const lingerDurationInSeconds = "linger_duration";
  static const animationSpeed = "animation_speed";
  static const keyCapAnimation = "keycap_animation";
  static const showMouseClicks = "show_clicks";
  static const highlightCursor = "highlight_cursor";
  static const showMouseEvents = "show_mouse_events";
  static const historyFadeDelayInSeconds = "history_fade_delay";
  static const fadeSteps = "fade_steps";
  static const showComboCount = "show_combo_count";
  static const minComboCount = "min_combo_count";
}

class _Defaults {
  static const filterHotkeys = true;
  static const ignoreKeys = {
    ModifierKey.control: false,
    ModifierKey.shift: true,
    ModifierKey.alt: false,
    ModifierKey.meta: false,
  };
  static const historyMode = VisualizationHistoryMode.none;
  static const toggleShortcut = [8589934850, 4294969354];
  static const lingerDurationInSeconds = 4;
  static const animationSpeed = 500;
  static const keyCapAnimation = KeyCapAnimationType.none;
  static const showMouseClicks = true;
  static const highlightCursor = false;
  static const showMouseEvents = true;
  static const historyFadeDelayInSeconds = 5;
  static const fadeSteps = 10;
  static const showComboCount = true;
  static const minComboCount = 2;
}

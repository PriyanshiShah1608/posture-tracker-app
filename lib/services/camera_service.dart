import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CameraFacing { front, back }

class CameraState {
  final CameraController? controller;
  final bool isStreaming;
  final CameraFacing facing;

  const CameraState({
    this.controller,
    this.isStreaming = false,
    this.facing = CameraFacing.back,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isStreaming,
    CameraFacing? facing,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isStreaming: isStreaming ?? this.isStreaming,
      facing: facing ?? this.facing,
    );
  }
}

class CameraService extends AutoDisposeAsyncNotifier<CameraState> {
  List<CameraDescription> _cameras = [];
  final StreamController<CameraImage> _frameController =
      StreamController<CameraImage>.broadcast();

  Stream<CameraImage> get frameStream => _frameController.stream;

  @override
  Future<CameraState> build() async {
    ref.onDispose(_dispose);
    _cameras = await availableCameras();
    return const CameraState();
  }

  CameraDescription? _findCamera(CameraFacing facing) {
    final direction = facing == CameraFacing.front
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    for (final camera in _cameras) {
      if (camera.lensDirection == direction) return camera;
    }
    return _cameras.isNotEmpty ? _cameras.first : null;
  }

  Future<void> initialize({CameraFacing facing = CameraFacing.back}) async {
    final currentState = await future;

    // Dispose previous controller if switching cameras.
    await _stopStreamAndDispose(currentState.controller);

    final camera = _findCamera(facing);
    if (camera == null) {
      throw StateError('No camera available');
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();

    state = AsyncData(CameraState(
      controller: controller,
      facing: facing,
    ));
  }

  Future<void> startStream() async {
    final currentState = await future;
    final controller = currentState.controller;
    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera not initialized');
    }
    if (currentState.isStreaming) return;

    await controller.startImageStream(_frameController.add);
    state = AsyncData(currentState.copyWith(isStreaming: true));
  }

  Future<void> stopStream() async {
    final currentState = await future;
    final controller = currentState.controller;
    if (controller == null || !currentState.isStreaming) return;

    await controller.stopImageStream();
    state = AsyncData(currentState.copyWith(isStreaming: false));
  }

  Future<void> switchCamera() async {
    final currentState = await future;
    final newFacing = currentState.facing == CameraFacing.front
        ? CameraFacing.back
        : CameraFacing.front;
    final wasStreaming = currentState.isStreaming;

    await initialize(facing: newFacing);
    if (wasStreaming) {
      await startStream();
    }
  }

  Future<void> _stopStreamAndDispose(CameraController? controller) async {
    if (controller == null) return;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
  }

  void _dispose() {
    final currentController = state.valueOrNull?.controller;
    _stopStreamAndDispose(currentController);
    _frameController.close();
  }
}

final cameraServiceProvider =
    AutoDisposeAsyncNotifierProvider<CameraService, CameraState>(
  CameraService.new,
);

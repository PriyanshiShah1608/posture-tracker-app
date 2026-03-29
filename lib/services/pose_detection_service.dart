import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/landmark.dart';
import 'camera_service.dart';

class PoseDetectionService {
  final PoseDetector _poseDetector;
  final StreamController<List<PoseLandmark>> _landmarkController =
      StreamController<List<PoseLandmark>>.broadcast();

  StreamSubscription<CameraImage>? _frameSub;
  bool _isProcessing = false;
  DateTime _lastProcessedTime = DateTime.fromMillisecondsSinceEpoch(0);

  static const _throttleInterval = Duration(milliseconds: 100);

  PoseDetectionService()
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(
            model: PoseDetectionModel.base,
            mode: PoseDetectionMode.stream,
          ),
        );

  Stream<List<PoseLandmark>> get landmarkStream => _landmarkController.stream;

  void attachToCamera(Stream<CameraImage> frameStream) {
    _frameSub?.cancel();
    _frameSub = frameStream.listen(_onFrame);
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();
    if (_isProcessing || now.difference(_lastProcessedTime) < _throttleInterval) {
      return;
    }
    _isProcessing = true;
    _lastProcessedTime = now;

    _processFrame(image).then((_) {
      _isProcessing = false;
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);

      if (!_landmarkController.isClosed) {
        final landmarks = <PoseLandmark>[];
        for (final pose in poses) {
          landmarks.addAll(pose.landmarks.values);
        }
        _landmarkController.add(landmarks);
      }
    } catch (e) {
      debugPrint('PoseDetectionService: frame processing error: $e');
    }
  }

  static InputImage? _convertCameraImage(CameraImage image) {
    final plane = image.planes.first;

    final InputImageFormat format;
    switch (image.format.group) {
      case ImageFormatGroup.nv21:
        format = InputImageFormat.nv21;
        break;
      case ImageFormatGroup.yuv420:
        format = InputImageFormat.yuv_420_888;
        break;
      case ImageFormatGroup.bgra8888:
        format = InputImageFormat.bgra8888;
        break;
      default:
        debugPrint('PoseDetectionService: unsupported format ${image.format.group}');
        return null;
    }

    final bytes = _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _rotationFromSensorOrientation(image),
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    int totalBytes = 0;
    for (final plane in planes) {
      totalBytes += plane.bytes.length;
    }
    final allBytes = Uint8List(totalBytes);
    int offset = 0;
    for (final plane in planes) {
      allBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }
    return allBytes;
  }

  /// Maps sensor orientation to MLKit InputImageRotation.
  ///
  /// On Android the camera sensor is typically rotated 90° or 270° relative to
  /// the device's natural orientation. The `CameraImage` itself doesn't carry
  /// sensor orientation, but on Android with NV21 the sensor rotation is
  /// baked into the byte buffer layout. For front-facing cameras the image is
  /// additionally mirrored. We default to 0° here; the calling layer can
  /// override if the CameraDescription's sensorOrientation is available.
  static InputImageRotation _rotationFromSensorOrientation(CameraImage image) {
    // CameraImage does not expose sensorOrientation directly.
    // On Android with NV21 format, the rotation is already handled by the
    // camera HAL for display purposes. Default to 0°.
    return InputImageRotation.rotation0deg;
  }

  Future<void> dispose() async {
    await _frameSub?.cancel();
    await _poseDetector.close();
    await _landmarkController.close();
  }
}

final poseDetectionServiceProvider = Provider.autoDispose<PoseDetectionService>(
  (ref) {
    final service = PoseDetectionService();

    // Attach to camera frame stream when camera is available.
    final cameraAsync = ref.watch(cameraServiceProvider);
    cameraAsync.whenData((cameraState) {
      if (cameraState.isStreaming) {
        final cameraNotifier = ref.read(cameraServiceProvider.notifier);
        service.attachToCamera(cameraNotifier.frameStream);
      }
    });

    ref.onDispose(() => service.dispose());
    return service;
  },
);

final landmarkStreamProvider = StreamProvider.autoDispose<List<PoseLandmark>>(
  (ref) {
    final service = ref.watch(poseDetectionServiceProvider);
    return service.landmarkStream;
  },
);

/// Maps MLKit [PoseLandmarkType] index to pure-Dart [LandmarkType].
/// Both enums list the 33 BlazePose points in the same order.
LandmarkType _toLandmarkType(PoseLandmarkType t) =>
    LandmarkType.values[t.index];

/// Bridge provider: converts MLKit landmarks into pure-Dart [Landmark] list
/// so downstream services never import MLKit directly.
final landmarksProvider = StreamProvider.autoDispose<List<Landmark>>(
  (ref) {
    final service = ref.watch(poseDetectionServiceProvider);
    return service.landmarkStream.map((poseLandmarks) {
      return poseLandmarks.map((pl) {
        return Landmark(
          type: _toLandmarkType(pl.type),
          x: pl.x,
          y: pl.y,
          z: pl.z,
          likelihood: pl.likelihood,
        );
      }).toList();
    });
  },
);

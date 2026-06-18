import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceVerificationService {
  final FaceDetector _detector;

  FaceVerificationService()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true,
            enableLandmarks: true,
            enableContours: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  Future<FaceData> extractFaceData(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) {
      throw FaceVerificationException('No face detected in photo');
    }
    if (faces.length > 1) {
      throw FaceVerificationException('Multiple faces detected. Please take solo photo.');
    }

    final face = faces.first;
    final rect = face.boundingBox;

    final landmarks = <String, Point<double>>{};
    for (final landmark in FaceLandmarkType.values) {
      final pos = face.landmarks[landmark];
      if (pos != null) {
        landmarks[landmark.name] = Point<double>(
          (pos.position.x - rect.left) / rect.width,
          (pos.position.y - rect.top) / rect.height,
        );
      }
    }

    return FaceData(
      landmarks: landmarks,
      headEulerAngleY: face.headEulerAngleY ?? 0,
      headEulerAngleZ: face.headEulerAngleZ ?? 0,
      smilingProbability: face.smilingProbability ?? 0,
      leftEyeOpenProbability: face.leftEyeOpenProbability ?? 0,
      rightEyeOpenProbability: face.rightEyeOpenProbability ?? 0,
      boundingWidth: rect.width.toDouble(),
      boundingHeight: rect.height.toDouble(),
    );
  }

  double compareFaces(FaceData reference, FaceData current) {
    final refKeys = reference.landmarks.keys.where((k) => current.landmarks.containsKey(k)).toList();
    if (refKeys.isEmpty) return 0.0;

    double totalDistance = 0;
    for (final key in refKeys) {
      final ref = reference.landmarks[key]!;
      final cur = current.landmarks[key]!;
      totalDistance += sqrt(pow(ref.x - cur.x, 2) + pow(ref.y - cur.y, 2));
    }

    final avgDistance = totalDistance / refKeys.length;
    return max(0.0, min(1.0, 1.0 - (avgDistance * 10.0)));
  }

  bool isVerifiedFace(FaceData reference, FaceData current, {double threshold = 0.65}) {
    return compareFaces(reference, current) >= threshold;
  }

  void dispose() {
    _detector.close();
  }
}

class FaceData {
  final Map<String, Point<double>> landmarks;
  final double headEulerAngleY;
  final double headEulerAngleZ;
  final double smilingProbability;
  final double leftEyeOpenProbability;
  final double rightEyeOpenProbability;
  final double boundingWidth;
  final double boundingHeight;

  const FaceData({
    required this.landmarks,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.smilingProbability,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.boundingWidth,
    required this.boundingHeight,
  });

  Map<String, dynamic> toJson() => {
    'landmarks': landmarks.map((k, v) => MapEntry(k, {'x': v.x, 'y': v.y})),
    'headEulerAngleY': headEulerAngleY,
    'headEulerAngleZ': headEulerAngleZ,
    'smilingProbability': smilingProbability,
    'leftEyeOpenProbability': leftEyeOpenProbability,
    'rightEyeOpenProbability': rightEyeOpenProbability,
    'boundingWidth': boundingWidth,
    'boundingHeight': boundingHeight,
  };

  factory FaceData.fromJson(Map<String, dynamic> json) {
    final lm = (json['landmarks'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Point<double>(
        (v as Map<String, dynamic>)['x'] as double,
        v['y'] as double,
      )),
    );
    return FaceData(
      landmarks: lm,
      headEulerAngleY: (json['headEulerAngleY'] as num).toDouble(),
      headEulerAngleZ: (json['headEulerAngleZ'] as num).toDouble(),
      smilingProbability: (json['smilingProbability'] as num).toDouble(),
      leftEyeOpenProbability: (json['leftEyeOpenProbability'] as num).toDouble(),
      rightEyeOpenProbability: (json['rightEyeOpenProbability'] as num).toDouble(),
      boundingWidth: (json['boundingWidth'] as num).toDouble(),
      boundingHeight: (json['boundingHeight'] as num).toDouble(),
    );
  }
}

class FaceVerificationException implements Exception {
  final String message;
  const FaceVerificationException(this.message);
  @override
  String toString() => message;
}

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:video_thumbnail/src/image_format.dart';
import 'package:video_thumbnail/src/video_thumbnail_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class VideoThumbnailPlatform extends PlatformInterface {
  /// Constructs a VideoThumbnailPlatform.
  VideoThumbnailPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoThumbnailPlatform _instance = MethodChannelVideoThumbnail();

  /// The default instance of [VideoThumbnailPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoThumbnail].
  static VideoThumbnailPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoThumbnailPlatform] when
  /// they register themselves.
  static set instance(VideoThumbnailPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<XFile>> thumbnailFiles({
    required List<String> videos,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required ImageFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFiles() has not been implemented.');
  }

  Future<XFile> thumbnailFile({
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required ImageFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailFile() has not been implemented.');
  }

  Future<Uint8List> thumbnailData({
    required String video,
    required Map<String, String>? headers,
    required ImageFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    int? timeMs,
    required int quality,
  }) {
    throw UnimplementedError('thumbnailData() has not been implemented.');
  }
}

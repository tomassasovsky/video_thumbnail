import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/src/image_format.dart';
import 'package:get_thumbnail_video/src/video_thumbnail_platform.dart';

/// An implementation of [VideoThumbnailPlatform] that uses method channels.
class MethodChannelVideoThumbnail extends VideoThumbnailPlatform {
  /// The method channel used to interact with the native platform.
  static const methodChannel =
      MethodChannel('plugins.justsoft.xyz/video_thumbnail');

  final Map<int, Completer<Object>> _futures = <int, Completer<Object>>{};

  MethodChannelVideoThumbnail() {
    methodChannel.setMethodCallHandler(_resolveCall);
  }

  Future<dynamic> _resolveCall(MethodCall call) async {
    switch (call.method) {
      case 'result#file':
        _resolveFileCall(call);
        return;

      case 'result#data':
        _resolveDataCall(call);
        return;

      case 'result#error':
        _resolveError(call);
        return;

      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Unknown method ${call.method}',
        );
    }
  }

  void _resolveFileCall(MethodCall call) {
    final String result = call.arguments['result'];
    final int callId = call.arguments['callId'];

    _resolveFuture(callId, XFile(result));
  }

  void _resolveDataCall(MethodCall call) {
    final List<int> result = call.arguments['result'];
    final int callId = call.arguments['callId'];

    _resolveFuture(callId, Uint8List.fromList(result));
  }

  void _resolveError(MethodCall call) {
    final Object error = call.arguments['result'];
    final int callId = call.arguments['callId'];

    _resolveFuture(callId, error is Exception ? error : Exception(error));
  }

  void _resolveFuture(int callId, Object value) {
    _futures[callId]?.complete(value);
    _futures.remove(callId);
  }

  (Completer<T>, int) _createCompleterAndCallId<T extends Object>() {
    final Completer<T> completer = Completer<T>();
    final int callId = completer.hashCode;

    _futures[callId] = completer;

    return (completer, callId);
  }

  @override
  Future<XFile> thumbnailFile({
    required String video,
    required Map<String, String>? headers,
    required String? thumbnailPath,
    required ImageFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    required int timeMs,
    required int quality,
  }) async {
    final (completer, callId) = _createCompleterAndCallId<XFile>();

    final reqMap = <String, dynamic>{
      'callId': callId,
      'video': video,
      'headers': headers,
      'path': thumbnailPath,
      'format': imageFormat.index,
      'maxh': maxHeight,
      'maxw': maxWidth,
      'timeMs': timeMs,
      'quality': quality
    };

    await methodChannel.invokeMethod('file', reqMap);

    return completer.future;
  }

  @override
  Future<Uint8List> thumbnailData({
    required String video,
    required Map<String, String>? headers,
    required ImageFormat imageFormat,
    required int maxHeight,
    required int maxWidth,
    required int timeMs,
    required int quality,
  }) async {
    final (completer, callId) = _createCompleterAndCallId<Uint8List>();

    final reqMap = <String, dynamic>{
      'callId': callId,
      'video': video,
      'headers': headers,
      'format': imageFormat.index,
      'maxh': maxHeight,
      'maxw': maxWidth,
      'timeMs': timeMs,
      'quality': quality,
    };

    await methodChannel.invokeMethod('data', reqMap);

    return completer.future;
  }
}

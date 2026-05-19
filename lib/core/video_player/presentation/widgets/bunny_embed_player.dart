import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/models/video_token_response_model.dart';
import '../../../../core/extensions/space_extension.dart';

class BunnyEmbedPlayer extends StatefulWidget {
  final VideoTokenResponseModel videoToken;
  final VoidCallback? onVideoEnded;
  final Function(int progress)? onProgress;

  const BunnyEmbedPlayer({
    super.key,
    required this.videoToken,
    this.onVideoEnded,
    this.onProgress,
  });

  @override
  State<BunnyEmbedPlayer> createState() => _BunnyEmbedPlayerState();
}

class _BunnyEmbedPlayerState extends State<BunnyEmbedPlayer> {
  // ... (keep existing variables)
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 10;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    final embedUrl = widget.videoToken.embedUrl.trim();

    if (embedUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Invalid embed URL';
        _isLoading = false;
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'ProgressChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (widget.onProgress != null) {
            final progress = int.tryParse(message.message) ?? 0;
            if (progress > 0 && progress <= 100) {
              widget.onProgress!(progress);
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = null;
              _retryCount = 0;
              _isRetrying = false;
            });
            // Inject CSS and polling script
            _controller?.runJavaScript('''
              // Custom CSS to make video fill entire screen
              var style = document.createElement('style');
              style.textContent = `
                html, body {
                  margin: 0;
                  padding: 0;
                  width: 100%;
                  height: 100%;
                  overflow: hidden;
                  background-color: black;
                }
                video {
                  width: 100% !important;
                  height: 100% !important;
                  object-fit: cover !important;
                }
                .bunny-player-container,
                .player-container,
                [class*="player"] {
                  width: 100% !important;
                  height: 100% !important;
                }
              `;
              document.head.appendChild(style);
              
              // Polling script
              setInterval(function() {
                var videos = document.getElementsByTagName('video');
                if (videos.length > 0) {
                  var video = videos[0];
                  if (video.duration > 0 && !video.paused) {
                    var pct = Math.floor((video.currentTime / video.duration) * 100);
                    ProgressChannel.postMessage(pct.toString());
                  }
                }
              }, 10000); 
            ''');
          },

          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;

            final desc = (error.description).toLowerCase();
            final code = error.errorCode;

            final isIgnorable =
                desc.contains('favicon') ||
                desc.contains('image') ||
                desc.contains('poster') ||
                desc.contains('media') ||
                desc.contains('unsafe resource') ||
                desc.contains('cors');

            if (isIgnorable) return;

            final isConnectionRefused =
                desc.contains('net::err_connection_refused') ||
                desc.contains('connection_refused') ||
                code == -6;

            if (isConnectionRefused) {
              _silentRetry();
              return;
            }

            final isNetworkError =
                desc.contains('net::err_connection_timed_out') ||
                desc.contains('net::err_name_not_resolved') ||
                desc.contains('internet_disconnected') ||
                desc.contains('name_not_resolved') ||
                desc.contains('timed_out') ||
                code == -2 ||
                code == -105 ||
                code == -106;

            if (isNetworkError) {
              _handleFailure(_friendlyNetworkMessage(error.description));
              return;
            }

            _handleFailure('Failed to load video: ${error.description}');
          },

          onHttpError: (HttpResponseError error) {
            if (!mounted) return;
            final status = error.response?.statusCode;

            if (status == null) return;

            if (status == 403) {
              _handleFailure(
                '403 Forbidden: token expired / domain restriction / hotlink protection.',
              );
              return;
            }

            if (status >= 500) {
              _handleFailure('Server error ($status). Please retry.');
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

    setState(() {
      _controller = controller;
      _isLoading = true;
      _errorMessage = null;
      _retryCount = 0;
      _isRetrying = false;
    });
  }

  String _friendlyNetworkMessage(String raw) {
    final d = raw.toLowerCase();
    if (d.contains('connection_refused') ||
        d.contains('err_connection_refused')) {
      return 'Connection refused. The video host is unreachable (blocked network/DNS/VPN or server down).';
    }
    if (d.contains('timed_out') || d.contains('err_connection_timed_out')) {
      return 'Connection timed out. Check your internet and try again.';
    }
    if (d.contains('name_not_resolved') ||
        d.contains('err_name_not_resolved')) {
      return 'DNS error. Try switching network or disable VPN.';
    }
    if (d.contains('internet_disconnected') ||
        d.contains('err_internet_disconnected')) {
      return 'No internet connection.';
    }
    return 'Network error: $raw';
  }

  void _silentRetry() {
    if (_isRetrying) return;

    if (_retryCount < _maxRetries) {
      _isRetrying = true;
      _retryCount++;

      final delay = Duration(seconds: 2 * _retryCount);
      Future.delayed(delay, () async {
        if (!mounted) return;
        _isRetrying = false;

        if (_controller != null) {
          await _controller!.reload();
        } else {
          _setupWebView();
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleFailure(String message) {
    if (_isRetrying) return;

    if (_retryCount < _maxRetries) {
      _isRetrying = true;
      _retryCount++;

      final delay = Duration(seconds: 2 * _retryCount);
      Future.delayed(delay, () async {
        if (!mounted) return;
        _isRetrying = false;

        if (_controller != null) {
          await _controller!.reload();
        } else {
          _setupWebView();
        }
      });

      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  void _manualRetry() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _retryCount = 0;
      _isRetrying = false;
    });

    if (_controller != null) {
      _controller!.reload();
    } else {
      _setupWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      children: [
        if (controller != null)
          WebViewWidget(controller: controller)
        else
          Container(color: Colors.black),

        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        if (_errorMessage != null && !_isLoading)
          Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48.r),
                    16.height,
                    Text(
                      'Error loading video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    12.height,
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                    20.height,
                    ElevatedButton(
                      onPressed: _manualRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

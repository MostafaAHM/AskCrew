import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    if (_hasPopped) return;

    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      return;
    }

    final isRedirectUrl = url.contains('localhost') || url.contains('hehe');
    final hasTapId = uri.queryParameters.containsKey('tap_id');
    final tapId = uri.queryParameters['tap_id'];
    final statusParam = uri.queryParameters['status'];

    bool isSuccess = false;
    bool isCancel = false;

    // Check for explicit success indicators in URL
    if (url.contains('success') ||
        url.contains('payment_success') ||
        url.contains('status=success') ||
        url.contains('paid') ||
        url.contains('completed')) {
      isSuccess = true;
    } else if (statusParam != null &&
        (statusParam.toLowerCase() == 'success' ||
            statusParam.toLowerCase() == 'paid' ||
            statusParam.toLowerCase() == 'captured')) {
      isSuccess = true;
    } else if (isRedirectUrl && hasTapId && tapId != null && tapId.isNotEmpty) {
      // Tap payment gateway redirects back with tap_id on success
      isSuccess = true;
    }

    // Check for cancellation/failure
    if (isCancel || isSuccess) {
      // don't re-check cancel if already flagged success
    }
    if (url.contains('cancel') ||
        url.contains('payment_cancel') ||
        url.contains('status=cancel') ||
        url.contains('failed') ||
        (url.contains('error') && !url.contains('checkout.tap'))) {
      isCancel = true;
    } else if (statusParam != null &&
        (statusParam.toLowerCase() == 'cancel' ||
            statusParam.toLowerCase() == 'failed')) {
      isCancel = true;
    }

    debugPrint('DEBUG WebView URL: $url | isSuccess: $isSuccess | isCancel: $isCancel');

    if (isCancel && !isSuccess && !_hasPopped) {
      _hasPopped = true;
      widget.onPaymentCancel?.call();
      if (mounted) {
        context.pop(false);
      }
    } else if (isSuccess && !_hasPopped) {
      _hasPopped = true;
      widget.onPaymentSuccess?.call();
      if (mounted) {
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: false,
        onBackPressed: () {
          context.pop();
        },
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: AnimatedLoading(color: Color(0xFFFF6B35)),
              ),
            ),
        ],
      ),
    );
  }
}

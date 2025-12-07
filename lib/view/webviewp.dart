import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaylinkWebView extends StatefulWidget {
  final String url;

  const PaylinkWebView({super.key, required this.url});

  @override
  State<PaylinkWebView> createState() => _PaylinkWebViewState();
}

class _PaylinkWebViewState extends State<PaylinkWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Paymee"),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

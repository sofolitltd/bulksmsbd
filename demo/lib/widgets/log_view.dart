import 'package:flutter/material.dart';

class LogViewController {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void log(String text) {
    final t = DateTime.now();
    final ts = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    _textCtrl.text = '${_textCtrl.text}[$ts] $text\n';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
  }
}

class LogView extends StatelessWidget {
  final LogViewController controller;

  const LogView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller._textCtrl,
        readOnly: true,
        maxLines: null,
        scrollController: controller._scrollCtrl,
        decoration: const InputDecoration(
        fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
        ),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white, height: 1.5),
      ),
    );
  }
}

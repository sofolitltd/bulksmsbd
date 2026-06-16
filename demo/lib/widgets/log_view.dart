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
    return TextField(
      controller: controller._textCtrl,
      readOnly: true,
      maxLines: null,
      scrollController: controller._scrollCtrl,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: 'Responses appear here...',
        contentPadding: const EdgeInsets.all(12),
      ),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    );
  }
}

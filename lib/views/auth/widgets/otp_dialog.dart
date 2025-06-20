import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/modern_loader.dart';

class OtpDialog extends StatefulWidget {
  final bool isLoading;
  final void Function(String otp) onSubmit;
  final VoidCallback? onCancel;
  final String? errorMessage;

  const OtpDialog({
    Key? key,
    required this.isLoading,
    required this.onSubmit,
    this.onCancel,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    // Removed auto-submit here
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'أدخل رمز التحقق',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: Focus(
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (_controllers[index].text.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                          _controllers[index - 1].text = '';
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onChanged(index, value),
                    ),
                  ),
                );
              }),
            ),
            if (widget.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            if (widget.isLoading)
              const ModernLoader()
          ],
        ),
        actions: [
          TextButton(
            onPressed: widget.isLoading ? null : widget.onCancel ?? () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.isLoading ? null : () {
              final otp = _controllers.map((c) => c.text).join();
              if (otp.length == 4) {
                widget.onSubmit(otp);
              }
            },
            child: widget.isLoading
                ? const SizedBox(height: 20, width: 20, child: ModernLoader())
                : const Text(
                    'تحقق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 
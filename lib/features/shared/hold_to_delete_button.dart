import 'package:flutter/material.dart';

import '../../app/app_strings.dart';

/// Botão de exclusão que só dispara depois de um pressionamento contínuo.
///
/// O anel circular funciona como confirmação visual: começa a preencher após o
/// reconhecimento do *long press* e volta ao início se o dedo/botão for solto
/// antes do fim. Assim a exclusão não acontece por toque acidental nem abre um
/// diálogo extra para itens de lista.
class HoldToDeleteButton extends StatefulWidget {
  const HoldToDeleteButton({
    super.key,
    required this.onDelete,
    this.duration = const Duration(milliseconds: 650),
    this.size = 40,
    this.semanticLabel,
  });

  final VoidCallback onDelete;
  final Duration duration;
  final double size;
  final String? semanticLabel;

  @override
  State<HoldToDeleteButton> createState() => _HoldToDeleteButtonState();
}

class _HoldToDeleteButtonState extends State<HoldToDeleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);

  bool _fired = false;
  bool _pressed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _fired) return;
    _fired = true;
    _pressed = false;
    widget.onDelete();
  }

  void _start(LongPressStartDetails _) {
    if (_fired) return;
    setState(() => _pressed = true);
    _controller.forward(from: 0);
  }

  void _reset() {
    if (!mounted) return;
    if (_controller.isAnimating || _controller.value > 0) {
      _controller.stop();
      _controller.value = 0;
    }
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = widget.semanticLabel ?? AppStrings.holdToDelete;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: label,
        hint: AppStrings.holdToDeleteHint,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: _start,
          onLongPressEnd: (_) => _reset(),
          onLongPressCancel: _reset,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.4,
                          color: scheme.error,
                          backgroundColor: scheme.outlineVariant.withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.delete_outline,
                      size: widget.size * 0.45,
                      color: _pressed ? scheme.error : scheme.onSurfaceVariant,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

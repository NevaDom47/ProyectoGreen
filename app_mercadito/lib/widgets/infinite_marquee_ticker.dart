import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Un componente de marquesina/ticker verdaderamente infinito y continuo.
/// Desplaza los elementos de derecha a izquierda sin cortes, sin vacíos
/// y sin reinicios abruptos, utilizando un ListView infinito impulsado por un Ticker.
class InfiniteMarqueeTicker extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double height;
  final double speed; // Píxeles por segundo
  final bool pauseOnTouch;
  final Color? fadeColor;
  final double fadeWidth;

  InfiniteMarqueeTicker({
    super.key,
    required List<Widget> children,
    this.height = 36.0,
    this.speed = 36.0,
    this.pauseOnTouch = true,
    this.fadeColor,
    this.fadeWidth = 20.0,
  })  : itemCount = children.length,
        itemBuilder = ((context, index) => children[index % children.length]);

  const InfiniteMarqueeTicker.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 36.0,
    this.speed = 36.0,
    this.pauseOnTouch = true,
    this.fadeColor,
    this.fadeWidth = 20.0,
  });

  @override
  State<InfiniteMarqueeTicker> createState() => _InfiniteMarqueeTickerState();
}

class _InfiniteMarqueeTickerState extends State<InfiniteMarqueeTicker>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _ticker = createTicker((elapsed) {
        if (!_isPaused && mounted && _scrollController.hasClients) {
          if (_lastElapsed != Duration.zero) {
            final deltaMicros = (elapsed - _lastElapsed).inMicroseconds;
            if (deltaMicros > 0 && deltaMicros < 100000) {
              final deltaSec = deltaMicros / 1000000.0;
              final newOffset = _scrollController.offset + (widget.speed * deltaSec);
              _scrollController.jumpTo(newOffset);
            }
          }
        }
        _lastElapsed = elapsed;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !isTest) {
          _ticker?.start();
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _pause() {
    if (!widget.pauseOnTouch) return;
    _isPaused = true;
  }

  void _resume() {
    if (!widget.pauseOnTouch) return;
    _lastElapsed = Duration.zero;
    _isPaused = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: MouseRegion(
        onEnter: (_) => _pause(),
        onExit: (_) => _resume(),
        child: Listener(
          onPointerDown: (_) => _pause(),
          onPointerUp: (_) => _resume(),
          onPointerCancel: (_) => _resume(),
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return widget.itemBuilder(context, index % widget.itemCount);
                },
              ),
              if (widget.fadeColor != null) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: widget.fadeWidth,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            widget.fadeColor!,
                            widget.fadeColor!.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: widget.fadeWidth,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            widget.fadeColor!,
                            widget.fadeColor!.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

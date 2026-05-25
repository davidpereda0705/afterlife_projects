// Efecto de entrada animada: desliza y desvanece cualquier widget al aparecer en pantalla.
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offset = const Offset(0, 24),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class StaggeredColumn extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration stagger;
  final Duration duration;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const StaggeredColumn({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 100),
    this.stagger = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 550),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children.asMap().entries.map((entry) {
        return AnimatedEntry(
          delay: baseDelay + (stagger * entry.key),
          duration: duration,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }
}

class StaggeredListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Duration baseDelay;
  final Duration stagger;
  final Duration duration;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
    this.padding,
    this.baseDelay = const Duration(milliseconds: 50),
    this.stagger = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return AnimatedEntry(
          delay: baseDelay + (stagger * index),
          duration: duration,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

class PulseScale extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const PulseScale({
    super.key,
    required this.child,
    this.minScale = 0.96,
    this.maxScale = 1.04,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<PulseScale> createState() => _PulseScaleState();
}

class _PulseScaleState extends State<PulseScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.minScale +
            (widget.maxScale - widget.minScale) *
                ((sin(_controller.value * pi * 2) + 1) / 2);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;
  final Duration duration;

  const GlowPulse({
    super.key,
    required this.child,
    required this.glowColor,
    this.maxBlur = 16,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final blur = widget.maxBlur *
            ((sin(_controller.value * pi * 2) + 1) / 2);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.4),
                blurRadius: blur,
                spreadRadius: blur * 0.3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

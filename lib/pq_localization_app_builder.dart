part of pa_localization;

class _InnerAppBuilder extends StatefulWidget {
  final Locale intailLocale;
  final bool fadeAnimation;
  final Duration duration;
  final MaterialApp Function(Locale locale) builder;

  const _InnerAppBuilder({
    @required this.intailLocale,
    @required this.builder,
    @required this.fadeAnimation,
    @required this.duration,
  });
  @override
  __InnerAppBuilderState createState() => __InnerAppBuilderState();
}

class __InnerAppBuilderState extends State<_InnerAppBuilder> {
  ValueNotifier<Locale> locale;
  bool _visible = true;
  Locale _oldLocale;
  @override
  void initState() {
    locale = ValueNotifier(widget.intailLocale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fadeAnimation == true)
      return AnimatedOpacity(
        onEnd: () {
          if (_visible == false) {
            setState(() {
              _visible = true;
              _oldLocale = null;
            });
          }
        },
        duration: widget.duration ?? Duration(milliseconds: 300),
        opacity: _visible ? 1.0 : 0.0,
        child: widget.builder(_oldLocale ?? locale.value),
      );
    else
      return widget.builder(locale.value);
  }

  void setLocale(Locale newLocale) {
    if (widget.fadeAnimation == true) {
      setState(() {
        _visible = false;
        _oldLocale = locale.value;
        locale.value = newLocale;
      });
    } else {
      setState(() {
        locale.value = newLocale;
        _visible = true;
      });
    }
  }
}

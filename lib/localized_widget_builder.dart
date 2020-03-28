part of pa_localization;

class LocalizedWidgetBuilder extends StatefulWidget {
  final Widget Function(PQLocalization localizer) builder;
  final Function(Locale newLOcale) onLocaleChange;
  const LocalizedWidgetBuilder(
      {Key key, @required this.builder, this.onLocaleChange})
      : super(key: key);

  @override
  _LocalizedWidgetBuilderState createState() => _LocalizedWidgetBuilderState();
}

class _LocalizedWidgetBuilderState extends State<LocalizedWidgetBuilder> {
  __InnerAppBuilderState _state;
  @override
  Widget build(BuildContext context) {
    return widget.builder(PQLocalization.of(context));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((d) {
      _state = context.findAncestorStateOfType<__InnerAppBuilderState>();
      if (_state == null) {
        throw Exception(
            "You should wrap  your  material app   with LocalizedMaterialAppBuilder");
      }
      _state.locale.addListener(onChange);
    });
  }

  @override
  void dispose() {
    if (_state != null) _state.locale.removeListener(onChange);
    super.dispose();
  }

  void onChange() {
    if (!mounted) return;
    widget.onLocaleChange(_state?.locale?.value);
  }
}

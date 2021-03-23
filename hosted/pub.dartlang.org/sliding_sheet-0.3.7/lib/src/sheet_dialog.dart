part of 'sheet.dart';

/// Shows a [SlidingSheet] as a material design bottom sheet.
///
/// The `builder` parameter must not be null and is used to construct a [SlidingSheetDialog].
///
/// The `parentBuilder` parameter can be used to wrap the sheet inside a parent, for example a
/// [Theme] or [AnnotatedRegion].
///
/// The `resizeToAvoidBottomInset` parameter can be used to avoid the keyboard from obscuring
/// the content bottom sheet.
Future<T> showSlidingBottomSheet<T>(
  BuildContext context, {
  @required SlidingSheetDialog Function(BuildContext context) builder,
  Widget Function(BuildContext context, SlidingSheet sheet) parentBuilder,
  bool useRootNavigator = false,
  bool resizeToAvoidBottomInset = true,
}) {
  assert(builder != null);
  assert(useRootNavigator != null);
  assert(resizeToAvoidBottomInset != null);

  SlidingSheetDialog dialog = builder(context);
  final SheetController controller = dialog.controller ?? SheetController();

  final theme = Theme.of(context);
  final ValueNotifier<int> rebuilder = ValueNotifier(0);

  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push(
    _SlidingSheetRoute(
      duration: dialog.duration,
      builder: (context, animation, route) {
        return ValueListenableBuilder(
          valueListenable: rebuilder,
          builder: (context, value, _) {
            dialog = builder(context);

            // Assign the rebuild function in order to
            // be able to change the dialogs parameters
            // inside a dialog.
            controller._rebuild = () {
              rebuilder.value++;
            };

            var snapSpec = dialog.snapSpec;
            if (snapSpec.snappings.first != 0.0) {
              snapSpec = snapSpec.copyWith(
                snappings: [0.0] + snapSpec.snappings,
              );
            }

            final sheet = SlidingSheet._(
              route: route,
              controller: controller,
              snapSpec: snapSpec,
              duration: dialog.duration,
              color: dialog.color ??
                  theme.bottomSheetTheme.backgroundColor ??
                  theme.dialogTheme.backgroundColor ??
                  theme.dialogBackgroundColor ??
                  theme.backgroundColor,
              backdropColor: dialog.backdropColor,
              shadowColor: dialog.shadowColor,
              elevation: dialog.elevation,
              padding: dialog.padding,
              addTopViewPaddingOnFullscreen:
                  dialog.addTopViewPaddingOnFullscreen,
              margin: dialog.margin,
              border: dialog.border,
              cornerRadius: dialog.cornerRadius,
              cornerRadiusOnFullscreen: dialog.cornerRadiusOnFullscreen,
              closeOnBackdropTap: dialog.dismissOnBackdropTap,
              builder: dialog.builder,
              headerBuilder: dialog.headerBuilder,
              footerBuilder: dialog.footerBuilder,
              listener: dialog.listener,
              scrollSpec: dialog.scrollSpec,
              maxWidth: dialog.maxWidth,
              closeSheetOnBackButtonPressed: false,
              minHeight: dialog.minHeight,
              isDismissable: dialog.isDismissable,
              onDismissPrevented: dialog.onDismissPrevented,
              isBackdropInteractable: dialog.isBackdropInteractable,
              axisAlignment: dialog.axisAlignment,
              extendBody: dialog.extendBody,
              body: null,
            );

            if (resizeToAvoidBottomInset) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: sheet,
              );
            }

            if (parentBuilder != null) {
              return parentBuilder(context, sheet);
            }

            return sheet;
          },
        );
      },
    ),
  );
}

class SlidingSheetDialog {
  /// {@macro sliding_sheet.builder}
  final SheetBuilder builder;

  /// {@macro sliding_sheet.headerBuilder}
  final SheetBuilder headerBuilder;

  /// {@macro sliding_sheet.footerBuilder}
  final SheetBuilder footerBuilder;

  /// {@macro sliding_sheet.snapSpec}
  final SnapSpec snapSpec;

  /// {@macro sliding_sheet.duration}
  final Duration duration;

  /// {@macro sliding_sheet.color}
  final Color color;

  /// {@macro sliding_sheet.backdropColor}
  final Color backdropColor;

  /// {@macro sliding_sheet.shadowColor}
  final Color shadowColor;

  /// {@macro sliding_sheet.elevation}
  final double elevation;

  /// {@macro sliding_sheet.padding}
  final EdgeInsets padding;

  /// {@macro sliding_sheet.addTopViewPaddingWhenAtFullscreen}
  final bool addTopViewPaddingOnFullscreen;

  /// {@macro sliding_sheet.margin}
  final EdgeInsets margin;

  /// {@macro sliding_sheet.border}
  final Border border;

  /// {@macro sliding_sheet.cornerRadius}
  final double cornerRadius;

  /// {@macro sliding_sheet.cornerRadiusOnFullscreen}
  final double cornerRadiusOnFullscreen;

  /// If true, the sheet will be dismissed the backdrop
  /// was tapped.
  final bool dismissOnBackdropTap;

  /// {@macro sliding_sheet.listener}
  final SheetListener listener;

  /// {@macro sliding_sheet.controller}
  final SheetController controller;

  /// {@macro sliding_sheet.scrollSpec}
  final ScrollSpec scrollSpec;

  /// {@macro sliding_sheet.maxWidth}
  final double maxWidth;

  /// {@macro sliding_sheet.minHeight}
  final double minHeight;

  /// {@macro sliding_sheet.isDismissable}
  final bool isDismissable;

  /// {@macro sliding_sheet.onDismissPrevented}
  final OnDismissPreventedCallback onDismissPrevented;

  /// {@macro sliding_sheet.isBackDropInteractable}
  final bool isBackdropInteractable;

  /// {@macro sliding_sheet.axisAlignment}
  final double axisAlignment;

  /// {@macro sliding_sheet.extendBody}
  final bool extendBody;

  const SlidingSheetDialog({
    @required this.builder,
    this.headerBuilder,
    this.footerBuilder,
    this.snapSpec = const SnapSpec(),
    this.duration = const Duration(milliseconds: 800),
    this.color,
    this.backdropColor = Colors.black54,
    this.shadowColor,
    this.elevation = 0.0,
    this.padding,
    this.addTopViewPaddingOnFullscreen = false,
    this.margin,
    this.border,
    this.cornerRadius = 0.0,
    this.cornerRadiusOnFullscreen,
    this.dismissOnBackdropTap = true,
    this.listener,
    this.controller,
    this.scrollSpec = const ScrollSpec(overscroll: false),
    this.maxWidth = double.infinity,
    this.minHeight,
    this.isDismissable = true,
    this.onDismissPrevented,
    this.isBackdropInteractable = false,
    this.axisAlignment = 0.0,
    this.extendBody = false,
  }) : assert(isDismissable != null);
}

/// A transparent route for a bottom sheet dialog.
class _SlidingSheetRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext, Animation<double>, _SlidingSheetRoute<T>)
      builder;
  final Duration duration;
  _SlidingSheetRoute({
    @required this.builder,
    @required this.duration,
    RouteSettings settings,
  })  : assert(builder != null),
        super(
          settings: settings,
          fullscreenDialog: false,
        );

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context, animation, this);
}

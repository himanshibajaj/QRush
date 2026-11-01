import 'package:flutter/material.dart';

const double kWideBreakpoint = 900;

bool isWide(BuildContext context) =>
    MediaQuery.of(context).size.width >= kWideBreakpoint;

/// Content ko beech mein, max chaudai tak rakhta hai
Widget fitWidth(Widget child, {double max = 1200}) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
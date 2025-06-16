import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:WashAm/configuration/padding_spacing.dart';

class ResponsiveFormBuilder extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool autoValidateMode;
  final VoidCallback? onChanged;
  final bool shrinkWrap;
  final Map<String, dynamic> initialValue;

  const ResponsiveFormBuilder({
    super.key,
    required this.formKey,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.autoValidateMode = false,
    this.onChanged,
    this.shrinkWrap = false,
    this.initialValue = const <String, dynamic>{},
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      initialValue: initialValue,
      autovalidateMode: autoValidateMode
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: onChanged,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: Spacing.formMaxWidthLarge),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.medium),
              child: Column(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
                children: _addSpacingBetweenChildren(children, Spacing.medium),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _addSpacingBetweenChildren(
      List<Widget> children, double spacing) {
    if (children.isEmpty) return [];
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i != children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

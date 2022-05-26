import 'package:flutter/cupertino.dart';
import 'package:kyc2/models/get_flows.dart';
import 'package:kyc2/utils/from_data.dart';
import 'package:kyc2/utils/widget_repo.dart';
import 'package:provider/provider.dart';

class DynamicLayout extends StatelessWidget {
  final String screenId;
  final int screenIndex;
  final List<List<Layout>> layout;
  String? analyticID;
  String? analytic_metaData;

  DynamicLayout({
    required this.screenId,
    required this.layout,
    required this.screenIndex,
    this.analyticID,
    this.analytic_metaData,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetColumns = [];

    //debugPrint('dynamic is $analyticID $screenIndex $screenId');
    //debugPrint('dynamic layout is $layout');

    layout.forEach(
      (row) {
        List<Widget> widgetRows = [];
        row.forEach(
          (widget) {
            widgetRows.add(
              Expanded(
                child: Consumer<FormData>(
                  builder: (context, formData, child) => WidgetRepo.getWidget(
                    context,
                    screenId,
                    screenIndex,
                    analyticID!,
                    analytic_metaData!,
                    widget.id,
                    widget.component,
                    params: widget.params,
                    validation: widget.validation,
                    style: widget.style,
                    action: widget.action,
                    formData: formData,
                    layout: widget,
                  ),
                ),
                flex: widget.width,
              ),
            );
          },
        );

      widgetColumns.add(Row(
        children: widgetRows,
      ));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgetColumns,
    );
  }
}

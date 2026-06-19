import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../theme/design_tokens.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final bool borderless;
  final double iconSize;

  const CustomDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.borderless = false,
    this.iconSize = 14,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  final _flyoutController = FlyoutController();

  @override
  void dispose() {
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlyoutTarget(
          controller: _flyoutController,
          child: Button(
            style: ButtonStyle(
              backgroundColor: widget.borderless 
                  ? WidgetStateProperty.all(Colors.transparent)
                  : WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: widget.borderless 
                      ? BorderSide.none 
                      : BorderSide(
                          color: DesignTokens.brown.withValues(alpha: 0.5),
                        ),
                ),
              ),
            ),
            onPressed: () {
              _flyoutController.showFlyout(
                builder: (context) {
                  return FlyoutContent(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: 320,
                      height: 350,
                      child: SfDateRangePicker(
                        view: DateRangePickerView.month,
                        selectionMode: DateRangePickerSelectionMode.single,
                        initialSelectedDate: widget.selectedDate,
                        todayHighlightColor: DesignTokens.brown,
                        selectionColor: DesignTokens.brown,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          todayTextStyle: const TextStyle(
                            color: DesignTokens.brown,
                            fontWeight: FontWeight.bold,
                          ),
                          textStyle: TextStyle(
                            color: DesignTokens.brown.withValues(alpha: 0.8),
                          ),
                        ),
                        headerStyle: const DateRangePickerHeaderStyle(
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            color: DesignTokens.brown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onSelectionChanged: (args) {
                          if (args.value is DateTime) {
                            widget.onDateChanged(args.value);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: Icon(
              FluentIcons.calendar,
              size: widget.iconSize,
              color: widget.borderless ? DesignTokens.gray : DesignTokens.brown,
            ),
          ),
        ),
        if (widget.selectedDate != null) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(FluentIcons.clear, size: 12),
            onPressed: () => widget.onDateChanged(null),
          ),
        ],
      ],
    );
  }
}

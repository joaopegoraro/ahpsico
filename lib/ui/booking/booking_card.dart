import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef Booking = MapEntry<String, DateTime>;
typedef TimeRanges = Map<int, DateTimeRange>;

@immutable
class BookingCard extends StatefulWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.blockedTimeRanges,
    required this.onTapAvailable,
    required this.onTapBlocked,
  });

  final Booking booking;
  final TimeRanges blockedTimeRanges;
  final void Function(DateTime bookingTime) onTapAvailable;
  final void Function(int blockedScheduleId) onTapBlocked;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  late final int? _blockedScheduleId;

  bool get _isAvailable => _blockedScheduleId == null;

  @override
  void initState() {
    super.initState();
    final bookingTimeStart = widget.booking.value;
    final bookingTimeEnd = widget.booking.value.add(const Duration(hours: 1));
    _blockedScheduleId = widget.blockedTimeRanges.entries.firstWhereOrNull((range) {
      final isStartAfterStart = bookingTimeStart.isAfter(range.value.start);
      final isStartBeforeEnd = bookingTimeStart.isBefore(range.value.end);
      final isEndAfterStart = bookingTimeEnd.isAfter(range.value.start);
      final isEndBeforeEnd = bookingTimeEnd.isBefore(range.value.end);
      return (isStartAfterStart && isStartBeforeEnd) || (isEndAfterStart && isEndBeforeEnd);
    })?.key;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isAvailable ? AhpsicoColors.blue : AhpsicoColors.red,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: () {
          if (_isAvailable) {
            widget.onTapAvailable(widget.booking.value);
          } else if (_blockedScheduleId != null) {
            widget.onTapBlocked(_blockedScheduleId!);
          }
        },
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Center(
              child: Text(
                widget.booking.key,
                style: AhpsicoText.regular1Style.copyWith(
                  color: AhpsicoColors.light80,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

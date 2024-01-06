import 'package:ahpsico/ui/app/theme/colors.dart';
import 'package:ahpsico/ui/app/theme/text.dart';
import 'package:flutter/material.dart';

typedef Booking = MapEntry<String, DateTime>;
typedef TimeRanges = Map<int, DateTimeRange>;

@immutable
class BookingCard extends StatefulWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTapAvailable,
  });

  final Booking booking;
  final void Function(DateTime bookingTime) onTapAvailable;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  late final int? _blockedScheduleId;
  late final bool _isAvailable;

  @override
  void initState() {
    super.initState();

    final bookingLimit = DateTime.now().add(const Duration(hours: 3));
    final isBookingTooSoon = widget.booking.value.isBefore(bookingLimit);
    _isAvailable = !isBookingTooSoon && _blockedScheduleId == null;
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

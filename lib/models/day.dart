class Day {
  final String shortName;
  final int dayNumber;
  final bool isSelected;

  Day({
    required this.shortName,
    required this.dayNumber,
    this.isSelected = false,
  });

  Day copyWith({bool? isSelected}) {
    return Day(
      shortName: shortName,
      dayNumber: dayNumber,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/holiday_repository.dart';
import '../../models/holidays/holiday_model.dart';
import '../../viewmodels/holidays/edit_holiday_viewmodel.dart';
import '../../widgets/top_bar.dart';

class EditHolidayScreen extends StatelessWidget {
  final Holiday? holiday;

  const EditHolidayScreen({
    super.key,
    this.holiday,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditHolidayViewModel(
        repository: context.read<HolidayRepository>(),
        holidayId: holiday?.id,
      ),
      child: const _EditHolidayScreenContent(),
    );
  }
}

class _EditHolidayScreenContent extends StatelessWidget {
  const _EditHolidayScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditHolidayViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: 'Holiday',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
      )
    );
  }
}
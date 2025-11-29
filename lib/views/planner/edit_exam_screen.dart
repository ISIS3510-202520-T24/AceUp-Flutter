import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/planner/exam_model.dart';
import '../../viewmodels/planner/edit_exam_viewmodel.dart';
import '../../widgets/top_bar.dart';

class EditExamScreen extends StatelessWidget {
  final Exam? exam;
  final String? subjectId;
  final String? termId;

  const EditExamScreen({
    super.key,
    this.exam,
    this.subjectId,
    this.termId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditExamViewModel(
        academicRepo: context.read<AcademicRepository>(),
        teacherRepo: context.read<TeacherRepository>(),
        examId: exam?.id,
        subjectId: subjectId,
        termId: termId,
      ),
      child: const _EditExamContent(),
    );
  }
}

class _EditExamContent extends StatelessWidget {
  const _EditExamContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditExamViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TopBar(
        title: viewModel.isEditMode ? 'Edit Exam' : 'New Exam',
        leftControlType: LeftControlType.cancel,
        rightControlType: RightControlType.save,
        onRightPressed: () => _saveExam(context, viewModel),
      ),
      body: Center(
        child: Text('Exam editing form goes here'),
      ),
    );
  }

  Future<void> _saveExam(
      BuildContext context, EditExamViewModel viewModel) async {
    if (!viewModel.canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await viewModel.saveExam();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to save exam'),
        ),
      );
    }
  }
}
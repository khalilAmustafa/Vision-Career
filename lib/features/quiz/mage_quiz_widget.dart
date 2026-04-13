import 'package:flutter/material.dart';

class ImageQuizWidget extends StatelessWidget {
  final String task;
  final bool isMarkedComplete;
  final ValueChanged<bool>? onMarkedCompleteChanged;
  final TextEditingController explanationController;

  const ImageQuizWidget({
    super.key,
    required this.task,
    required this.isMarkedComplete,
    required this.explanationController,
    this.onMarkedCompleteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: isMarkedComplete,
            contentPadding: EdgeInsets.zero,
            title: const Text('I completed the required image task'),
            onChanged: (value) => onMarkedCompleteChanged?.call(value ?? false),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: explanationController,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Explain what your image contains and why it matches the task...',
            ),
          ),
        ],
      ),
    );
  }
}

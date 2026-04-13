import 'package:flutter/material.dart';

class WritingQuizWidget extends StatelessWidget {
  final String prompt;
  final TextEditingController controller;
  final String? hintText;

  const WritingQuizWidget({
    super.key,
    required this.prompt,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText ?? 'Write your answer here...',
            ),
          ),
        ),
      ],
    );
  }
}

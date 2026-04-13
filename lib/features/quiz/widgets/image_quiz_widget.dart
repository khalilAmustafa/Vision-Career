import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageQuizWidget extends StatefulWidget {
  final String task;
  final String instructions;
  final bool isSubmitting;
  final ValueChanged<File> onSubmit;

  const ImageQuizWidget({
    super.key,
    required this.task,
    required this.instructions,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<ImageQuizWidget> createState() => _ImageQuizWidgetState();
}

class _ImageQuizWidgetState extends State<ImageQuizWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2200,
        maxHeight: 2200,
      );

      if (!mounted) return;

      if (picked == null) {
        return;
      }

      setState(() {
        _selectedImage = File(picked.path);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to select image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Quiz',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(widget.instructions),
          const SizedBox(height: 16),
          Text(
            widget.task,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: widget.isSubmitting ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pick from Gallery'),
              ),
              ElevatedButton.icon(
                onPressed: widget.isSubmitting ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Use Camera'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImage!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              alignment: Alignment.center,
              child: const Text('No image selected yet'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isSubmitting
                  ? null
                  : () {
                      if (_selectedImage == null) {
                        setState(() {
                          _error = 'Please select or capture an image before submitting.';
                        });
                        return;
                      }
                      widget.onSubmit(_selectedImage!);
                    },
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Image for Grading'),
            ),
          ),
        ],
      ),
    );
  }
}

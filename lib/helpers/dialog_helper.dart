import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/text_constants.dart';
import '../models/note_model.dart';
import '../widgets/base_widgets/custom_text_field_widget.dart';
import '../widgets/common_widgets/action_button_widget.dart';

class DialogHelper {
  static Future showAddNoteDialog(BuildContext context,
      {bool isEdit = false, Note? note}) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    if (isEdit) {
      titleController.text = note!.title;
      contentController.text = note.content;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title:
              Text(isEdit ? TextConstants.editNote : TextConstants.createNote),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: titleController,
                autoFocus: true,
                labelText: TextConstants.title,
                inputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: contentController,
                labelText: TextConstants.content,
                maxLines: 8,
              ),
            ],
          ),
          actions: [
            ActionButton(
              onPressed: () => Navigator.of(context).pop([false]),
              foregroundColor: ColorConstants.black,
              backgroundColor: ColorConstants.transparent,
              text: TextConstants.cancel,
            ),
            ActionButton(
              onPressed: () {
                String title = titleController.text.trim();
                String content = contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  final note = Note(title: title, content: content);
                  Navigator.of(context).pop([true, note]);
                }
              },
              foregroundColor: ColorConstants.white,
              backgroundColor: ColorConstants.teal,
              text: TextConstants.save,
            ),
          ],
        );
      },
    );
  }

  static Future showConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(TextConstants.deleteNote),
          content: const Text(TextConstants.areYouSureYouWantToDeleteTheNote),
          actions: [
            ActionButton(
              onPressed: () => Navigator.of(context).pop(false),
              foregroundColor: ColorConstants.black,
              backgroundColor: ColorConstants.transparent,
              text: TextConstants.cancel,
            ),
            ActionButton(
              onPressed: () => Navigator.of(context).pop(true),
              foregroundColor: ColorConstants.white,
              backgroundColor: ColorConstants.red,
              text: TextConstants.delete,
            ),
          ],
        );
      },
    );
  }
}

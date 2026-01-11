import 'package:flutter/material.dart';
import 'package:free_dz/models/jobs.dart';
import 'package:free_dz/services/api_helper.dart';

class EditJobPage extends StatefulWidget {
  final ClientJob job;

  const EditJobPage({super.key, required this.job});

  @override
  State<EditJobPage> createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _budget;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.job.title);
    _description = TextEditingController(text: widget.job.description);
    _budget = TextEditingController(text: widget.job.budget.toString());
  }

  Future<void> _updateJob() async {
    setState(() => _saving = true);

    try {
      await ApiHelper.put(
        '/projects/${widget.job.id}',
        {
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'budget': int.parse(_budget.text.trim()),
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Update job error: $e');
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
            TextField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _updateJob,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_dz/services/api_helper.dart';

// ==========================================
// CREATE JOB PAGE
// ==========================================

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedCategory = 'Mobile';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Mobile',
    'Web Development',
    'Design',
    'Writing',
    'Marketing',
    'Video Editing',
    'Data Entry',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiHelper.post('/projects', {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'budget': double.parse(_budgetController.text.trim()),
        'category_badge': _selectedCategory,
        'location': _locationController.text.trim(),
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job posted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error creating job: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create job: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Create Job',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              isDark: isDark,
              title: 'Job Details',
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Job Title',
                  hint: 'e.g., Build Flutter App',
                  icon: Icons.work_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a job title';
                    }
                    if (value.trim().length < 10) {
                      return 'Title must be at least 10 characters';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe the job requirements and expectations',
                  icon: Icons.description_outlined,
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.trim().length < 50) {
                      return 'Description must be at least 50 characters';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              isDark: isDark,
              title: 'Job Information',
              children: [
                _buildCategoryDropdown(isDark),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'e.g., Remote, Algiers, or On-site',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _budgetController,
                  label: 'Budget (DA)',
                  hint: 'e.g., 5000',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a budget';
                    }
                    final budget = double.tryParse(value);
                    if (budget == null || budget <= 0) {
                      return 'Please enter a valid budget';
                    }
                    if (budget < 500) {
                      return 'Minimum budget is 500 DA';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.publish, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Publish Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
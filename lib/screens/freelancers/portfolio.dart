// pages/freelancer_profile_edit_page.dart - CORRECTED VERSION
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/models/profile.dart';

class FreelancerProfileEditPage extends StatefulWidget {
  final FreelancerPortfolio portfolio;

  const FreelancerProfileEditPage({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  @override
  State<FreelancerProfileEditPage> createState() =>
      _FreelancerProfileEditPageState();
}

class _FreelancerProfileEditPageState extends State<FreelancerProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  File? _avatarFile;
  final _imagePicker = ImagePicker();

  late TextEditingController _fullNameController;
  late TextEditingController _professionalTitleController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _yearsOfExperienceController;
  late TextEditingController _responseTimeController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _skillsController;
  late TextEditingController _languagesController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.portfolio.fullName);
    _professionalTitleController =
        TextEditingController(text: widget.portfolio.bio);
    _locationController = TextEditingController(text: widget.portfolio.location);
    _bioController = TextEditingController(text: widget.portfolio.bio);
    _yearsOfExperienceController = TextEditingController(
        text: widget.portfolio.yearsOfExperience.toString());
    _responseTimeController =
        TextEditingController(text: widget.portfolio.responseTime);
    _hourlyRateController =
        TextEditingController(text: widget.portfolio.hourlyRate.toString());
    _skillsController =
        TextEditingController(text: widget.portfolio.skills.join(', '));
    _languagesController =
        TextEditingController(text: widget.portfolio.languages.join(', '));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _professionalTitleController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _yearsOfExperienceController.dispose();
    _responseTimeController.dispose();
    _hourlyRateController.dispose();
    _skillsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final languages = _languagesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (_avatarFile != null) {
        // Use multipart upload when avatar is included
        final fields = {
          'full_name': _fullNameController.text.trim(),
          'professional_title': _professionalTitleController.text.trim(),
          'location': _locationController.text.trim(),
          'bio': _bioController.text.trim(),
          'years_of_experience': _yearsOfExperienceController.text.trim(),
          'response_time': _responseTimeController.text.trim(),
          'hourlyRate': _hourlyRateController.text.trim(), // Match backend field name
        };

        // Convert arrays to JSON strings for multipart
        fields['skills'] = json.encode(skills);
        fields['languages'] = json.encode(languages);

        await ApiHelper.putMultipart(
          '/freelancer/profile',
          fields,
          filePath: _avatarFile!.path,
          fileFieldName: 'avatar',
        );
      } else {
        // Use regular JSON update when no avatar
        final data = {
          'full_name': _fullNameController.text.trim(),
          'professional_title': _professionalTitleController.text.trim(),
          'location': _locationController.text.trim(),
          'bio': _bioController.text.trim(),
          'years_of_experience': int.parse(_yearsOfExperienceController.text.trim()),
          'response_time': _responseTimeController.text.trim(),
          'hourlyRate': double.parse(_hourlyRateController.text.trim()), // Match backend
          'skills': skills,
          'languages': languages,
        };

        await ApiHelper.put('/freelancer/profile', data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : (widget.portfolio.avatarUrl != null
                            ? NetworkImage(widget.portfolio.avatarUrl!)
                            : null) as ImageProvider?,
                    child: _avatarFile == null && widget.portfolio.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue.shade700,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _professionalTitleController,
              decoration: InputDecoration(
                labelText: 'Professional Title',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.work),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your professional title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your bio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _yearsOfExperienceController,
              decoration: InputDecoration(
                labelText: 'Years of Experience',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.work_history),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter years of experience';
                }
                final years = int.tryParse(value.trim());
                if (years == null || years < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _responseTimeController,
              decoration: InputDecoration(
                labelText: 'Response Time',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.access_time),
                helperText: 'e.g., "Within 1 hour" or "24 hours"',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your response time';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _hourlyRateController,
              decoration: InputDecoration(
                labelText: 'Hourly Rate (USD)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                prefix: const Text('\$ '),
                suffix: const Text('/hr'),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your hourly rate';
                }
                final rate = double.tryParse(value.trim());
                if (rate == null || rate < 0) {
                  return 'Please enter a valid rate';
                }
                if (rate > 50000) {
                  return 'Rate cannot exceed 50,000';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _skillsController,
              decoration: InputDecoration(
                labelText: 'Skills',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.star),
                helperText: 'Separate skills with commas',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter at least one skill';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _languagesController,
              decoration: InputDecoration(
                labelText: 'Languages',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.language),
                helperText: 'Separate languages with commas',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter at least one language';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
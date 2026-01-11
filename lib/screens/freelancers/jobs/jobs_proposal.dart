// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/models/jobs.dart';
import 'package:free_dz/models/proposals.dart';

// ==========================================
// SUBMIT PROPOSAL PAGE (FREELANCER)
// ==========================================

class SubmitProposalPage extends StatefulWidget {
  final Job job;

  const SubmitProposalPage({
    super.key,
    required this.job,
  });

  @override
  State<SubmitProposalPage> createState() => _SubmitProposalPageState();
}

class _SubmitProposalPageState extends State<SubmitProposalPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _bidAmountController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _coverLetterController = TextEditingController();
  
  // Focus nodes
  final _bidAmountFocus = FocusNode();
  final _deliveryTimeFocus = FocusNode();
  final _coverLetterFocus = FocusNode();
  
  // State
  bool _isSubmitting = false;
  String? _errorMessage;
  
  // Character count for cover letter
  int _coverLetterLength = 0;
  static const int _minCoverLetterLength = 20;
  static const int _maxCoverLetterLength = 1000;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    
    // Pre-fill with job budget if available
    if (widget.job.budget != null) {
      _bidAmountController.text = widget.job.budget.toString();
    }
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    _deliveryTimeController.dispose();
    _coverLetterController.dispose();
    _bidAmountFocus.dispose();
    _deliveryTimeFocus.dispose();
    _coverLetterFocus.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _coverLetterController.addListener(() {
      setState(() {
        _coverLetterLength = _coverLetterController.text.length;
      });
    });
  }

  Future<void> _submitProposal() async {
    // Clear any previous errors
    setState(() => _errorMessage = null);
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus all fields
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final submission = ProposalSubmission(
        bidAmount: int.parse(_bidAmountController.text.trim()),
        deliveryTime: int.parse(_deliveryTimeController.text.trim()),
        coverLetter: _coverLetterController.text.trim(),
      );

      await ApiHelper.post(
  '/projects/${widget.job.id}/proposals',
  submission.toJson(),
);


      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Proposal submitted successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Navigate back
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error submitting proposal: $e');
      
      if (!mounted) return;

      setState(() {
        _errorMessage = _parseErrorMessage(e.toString());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Failed to submit proposal'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('already submitted')) {
      return 'You have already submitted a proposal for this job';
    } else if (error.contains('unauthorized')) {
      return 'You must be logged in as a freelancer';
    } else if (error.contains('validation')) {
      return 'Please check your input and try again';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'Failed to submit proposal. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark),
      body: _buildBody(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'Submit Proposal',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJobInfo(isDark),
                    const SizedBox(height: 32),
                    _buildBidAmountField(isDark),
                    const SizedBox(height: 20),
                    _buildDeliveryTimeField(isDark),
                    const SizedBox(height: 20),
                    _buildCoverLetterField(isDark),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _buildErrorMessage(isDark),
                    ],
                    const SizedBox(height: 32),
                    _buildGuidelines(isDark),
                  ],
                ),
              ),
            ),
          ),
          _buildSubmitButton(isDark),
        ],
      ),
    );
  }

  Widget _buildJobInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.job.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.job.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.job.budget != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Budget: ${widget.job.budget} DA',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBidAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bid Amount (DA)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bidAmountController,
          focusNode: _bidAmountFocus,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter your bid amount',
            prefixIcon: Icon(
              Icons.attach_money,
              color: Colors.grey.shade600,
            ),
            suffixText: 'DA',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue.shade600,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a bid amount';
            }
            final amount = int.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 1000) {
              return 'Minimum bid amount is 1,000 DA';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            _deliveryTimeFocus.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Time (days)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _deliveryTimeController,
          focusNode: _deliveryTimeFocus,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter delivery time in days',
            prefixIcon: Icon(
              Icons.schedule,
              color: Colors.grey.shade600,
            ),
            suffixText: 'days',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue.shade600,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter delivery time';
            }
            final days = int.tryParse(value);
            if (days == null || days <= 0) {
              return 'Please enter a valid number of days';
            }
            if (days > 365) {
              return 'Maximum delivery time is 365 days';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            _coverLetterFocus.requestFocus();
          },
        ),
      ],
    );
  }

  Widget _buildCoverLetterField(bool isDark) {
    final isValid = _coverLetterLength >= _minCoverLetterLength;
    final isTooLong = _coverLetterLength > _maxCoverLetterLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cover Letter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '$_coverLetterLength / $_maxCoverLetterLength',
              style: TextStyle(
                fontSize: 12,
                color: isTooLong
                    ? Colors.red.shade600
                    : isValid
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _coverLetterController,
          focusNode: _coverLetterFocus,
          enabled: !_isSubmitting,
          maxLines: 8,
          maxLength: _maxCoverLetterLength,
          decoration: InputDecoration(
            hintText: 'Explain why you\'re the best fit for this job...\n\n'
                'Include:\n'
                '• Your relevant experience\n'
                '• How you\'ll approach the project\n'
                '• Any questions or clarifications',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue.shade600,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
            counterText: '',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write a cover letter';
            }
            if (value.trim().length < _minCoverLetterLength) {
              return 'Cover letter must be at least $_minCoverLetterLength characters';
            }
            if (value.length > _maxCoverLetterLength) {
              return 'Cover letter is too long';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelines(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips for a Great Proposal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideline('Be realistic with your bid and timeline'),
          _buildGuideline('Highlight your relevant skills and experience'),
          _buildGuideline('Ask clarifying questions if needed'),
          _buildGuideline('Proofread your cover letter before submitting'),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitProposal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Proposal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
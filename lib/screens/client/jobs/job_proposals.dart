import 'package:flutter/material.dart';
import 'package:free_dz/screens/client/freelancer_profile.dart';
import '../../../models/proposals.dart';
import '../../../services/api_helper.dart';

class JobProposalsPage extends StatefulWidget {
  final String projectId;

  const JobProposalsPage({super.key, required this.projectId});

  @override
  State<JobProposalsPage> createState() => _JobProposalsPageState();
}

class _JobProposalsPageState extends State<JobProposalsPage> {
  bool _loading = true;
  List<Proposal> _proposals = [];

  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }

  Future<void> _fetchProposals() async {
    setState(() => _loading = true);
    try {
      final res = await ApiHelper.get('/projects/${widget.projectId}/proposals');
      final List data = res['data'] ?? [];
      _proposals = data.map((e) => Proposal.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Fetch proposals error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching proposals')),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _acceptProposal(Proposal proposal) async {
    try {
      await ApiHelper.post('/proposals/${proposal.id}/accept', {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proposal accepted')),
      );
      _fetchProposals();
    } catch (e) {
      debugPrint('Accept proposal error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting proposal')),
      );
    }
  }

  Future<void> _rejectProposal(Proposal proposal) async {
    try {
      await ApiHelper.post('/proposals/${proposal.id}/reject', {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proposal rejected')),
      );
      _fetchProposals();
    } catch (e) {
      debugPrint('Reject proposal error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting proposal')),
      );
    }
  }

  void _viewFreelancerProfile(Proposal proposal) {
    
     Navigator.push(context, MaterialPageRoute(
       builder: (_) => FreelancerProfileScreen(freelancerId: proposal.freelancerId)
     ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open profile: ${proposal.freelancerName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proposals')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _proposals.isEmpty
              ? const Center(child: Text('No proposals yet'))
              : ListView.builder(
  itemCount: _proposals.length,
  itemBuilder: (_, i) {
    final p = _proposals[i];
    return InkWell(
      onTap: () => _viewFreelancerProfile(p), // tap anywhere to open profile
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.freelancerName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text('Bid: ${p.bidAmount} DA • Delivery: ${p.deliveryTime} days'),
              const SizedBox(height: 8),
              Text('Cover Letter: ${p.coverLetter}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: p.status.isPending
                        ? () => _acceptProposal(p)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: p.status.isPending
                        ? () => _rejectProposal(p)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const Spacer(),
                  Text(
                    p.status.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: p.status.isAccepted
                          ? Colors.green
                          : p.status.isRejected
                              ? Colors.red
                              : Colors.orange,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
)

    );
  }
}

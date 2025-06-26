import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  Widget _buildSection(String title, List<String> paragraphs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...paragraphs.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(p, style: const TextStyle(fontSize: 15, height: 1.5)),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: ${'2024-07-27'}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              [
                'Welcome to Kosan App ("we," "our," "us"). These Terms of Service ("Terms") govern your use of our mobile application (the "Service"). By accessing or using our Service, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.',
              ],
            ),
            _buildSection(
              '2. User Accounts',
              [
                'When you create an account with us, you must provide us with information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.',
                'You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password. You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.',
              ],
            ),
            _buildSection(
              '3. User Responsibilities',
              [
                'You agree not to use the Service for any unlawful purpose or in any way that interrupts, damages, or impairs the service. You are responsible for all data and information you input into the Service.',
                'You agree not to misuse the service by knowingly introducing viruses, trojans, or other material that is malicious or technologically harmful.',
              ],
            ),
            _buildSection(
              '4. Intellectual Property',
              [
                'The Service and its original content, features, and functionality are and will remain the exclusive property of Kosan App and its licensors. The Service is protected by copyright, trademark, and other laws of both the local and foreign countries.',
              ],
            ),
            _buildSection(
              '5. Termination',
              [
                'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
                'Upon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may do so through the account deletion feature within the application.',
              ],
            ),
            _buildSection(
              '6. Limitation of Liability',
              [
                'In no event shall Kosan App, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.',
              ],
            ),
            _buildSection(
              '7. Governing Law',
              [
                'These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which our company is established, without regard to its conflict of law provisions.',
              ],
            ),
            _buildSection(
              '8. Changes to These Terms',
              [
                'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms of Service on this page. Your continued use of the Service after any such changes constitutes your acceptance of the new Terms.',
              ],
            ),
            _buildSection(
              '9. Contact Us',
              [
                'If you have any questions about these Terms, please contact us through the "Contact Us" feature in the app or by emailing support@example.com.',
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
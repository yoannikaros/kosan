import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Privacy Policy',
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
                'Kosan App ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application (the "Service"). Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
              ],
            ),
            _buildSection(
              '2. Information We Collect',
              [
                'We may collect information about you in a variety of ways. The information we may collect via the Application includes:',
                'Personal Data: Personally identifiable information, such as your username, email address, and password, that you voluntarily give to us when you register with the Application.',
                'Usage Data: Information our servers automatically collect when you access the Application, such as your IP address, browser type, operating system, access times, and the pages you have viewed directly before and after accessing the Application.',
              ],
            ),
            _buildSection(
              '3. How We Use Your Information',
              [
                'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:',
                '• Create and manage your account.',
                '• Process your transactions and send you related information.',
                '• Improve the application and user experience.',
                '• Respond to your comments and questions and provide customer service.',
                '• Send you technical notices, updates, security alerts, and support messages.',
              ],
            ),
             _buildSection(
              '4. Data Sharing and Disclosure',
              [
                'We do not share your personal information with third parties except in the following circumstances:',
                '• With your consent.',
                '• To comply with laws or to respond to lawful requests and legal processes.',
                '• To protect the rights and property of Kosan App, our agents, customers, and others.',
              ],
            ),
            _buildSection(
              '5. Data Security',
              [
                'We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.',
              ],
            ),
            _buildSection(
              '6. Your Data Protection Rights',
              [
                'Depending on your location, you may have the following rights regarding your personal information:',
                '• The right to access – You have the right to request copies of your personal data.',
                '• The right to rectification – You have the right to request that we correct any information you believe is inaccurate.',
                '• The right to erasure – You have the right to request that we erase your personal data, under certain conditions.',
              ],
            ),
            _buildSection(
              '7. Children\'s Privacy',
              [
                'Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us.',
              ],
            ),
            _buildSection(
              '8. Changes to This Privacy Policy',
              [
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes.',
              ],
            ),
            _buildSection(
              '9. Contact Us',
              [
                'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@example.com.',
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
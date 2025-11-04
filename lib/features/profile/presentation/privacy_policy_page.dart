import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppTheme.offWhite,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: November 4, 2025',
              style: TextStyle(
                color: AppTheme.darkTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Introduction
            _buildSection(
              title: 'Introduction',
              content:
                  'Welcome to Sentimo. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our AI-powered sentiment journal application.',
            ),

            // Information We Collect
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect information that you provide directly to us when using Sentimo:',
            ),
            _buildBulletPoint(
              'Account Information: Email address, name, and password',
            ),
            _buildBulletPoint(
              'Journal Entries: Your written journal entries and the content you create',
            ),
            _buildBulletPoint(
              'Sentiment Analysis Data: AI-generated sentiment analysis results from your entries',
            ),
            _buildBulletPoint(
              'Usage Data: Information about how you interact with the app',
            ),
            const SizedBox(height: 24),

            // How We Use Your Information
            _buildSection(
              title: '2. How We Use Your Information',
              content: 'We use the information we collect to:',
            ),
            _buildBulletPoint(
              'Provide and maintain the Sentimo service',
            ),
            _buildBulletPoint(
              'Perform sentiment analysis on your journal entries using Google Gemini AI',
            ),
            _buildBulletPoint(
              'Improve and personalize your experience',
            ),
            _buildBulletPoint(
              'Send you important notifications about your account',
            ),
            _buildBulletPoint(
              'Ensure the security and integrity of our services',
            ),
            const SizedBox(height: 24),

            // Data Storage and Security
            _buildSection(
              title: '3. Data Storage and Security',
              content:
                  'Your data is stored securely using Supabase, a secure cloud database platform. We implement industry-standard security measures including:',
            ),
            _buildBulletPoint(
              'Encryption in transit and at rest',
            ),
            _buildBulletPoint(
              'Secure authentication protocols',
            ),
            _buildBulletPoint(
              'Regular security audits and updates',
            ),
            _buildBulletPoint(
              'Row Level Security (RLS) policies to protect your data',
            ),
            const SizedBox(height: 24),

            // Third-Party Services
            _buildSection(
              title: '4. Third-Party Services',
              content:
                  'Sentimo uses the following third-party services to provide functionality:',
            ),
            _buildServiceCard(
              service: 'Supabase',
              purpose: 'Database hosting and authentication',
              url: 'supabase.com',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              service: 'Google Gemini AI',
              purpose: 'AI-powered sentiment analysis of journal entries',
              url: 'ai.google.dev',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              service: 'Google Sign-In',
              purpose: 'Optional authentication method',
              url: 'developers.google.com',
            ),
            const SizedBox(height: 24),

            // Your Privacy Rights
            _buildSection(
              title: '5. Your Privacy Rights',
              content: 'You have the right to:',
            ),
            _buildBulletPoint(
              'Access your personal information',
            ),
            _buildBulletPoint(
              'Update or correct your information',
            ),
            _buildBulletPoint(
              'Delete your account and all associated data',
            ),
            _buildBulletPoint(
              'Export your journal entries',
            ),
            _buildBulletPoint(
              'Opt-out of non-essential data collection',
            ),
            const SizedBox(height: 24),

            // Data Retention
            _buildSection(
              title: '6. Data Retention',
              content:
                  'We retain your personal information only for as long as necessary to provide you with the Sentimo service. When you delete your account, we will permanently delete all your data within 30 days.',
            ),

            // Children\'s Privacy
            _buildSection(
              title: '7. Children\'s Privacy',
              content:
                  'Sentimo is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
            ),

            // Changes to This Policy
            _buildSection(
              title: '8. Changes to This Privacy Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),

            // Contact Us
            _buildSection(
              title: '9. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy or our data practices, please contact us at:',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.brightBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppTheme.brightBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Email',
                        style: TextStyle(
                          color: AppTheme.darkTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'privacy@sentimo.app',
                    style: TextStyle(
                      color: AppTheme.offWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2025 Sentimo. All rights reserved.',
                    style: TextStyle(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy matters to us.',
                    style: TextStyle(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.offWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            color: AppTheme.darkTextSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.brightBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.darkTextSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String service,
    required String purpose,
    required String url,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.brightBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service,
                  style: TextStyle(
                    color: AppTheme.brightBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            purpose,
            style: TextStyle(
              color: AppTheme.offWhite,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            url,
            style: TextStyle(
              color: AppTheme.darkTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

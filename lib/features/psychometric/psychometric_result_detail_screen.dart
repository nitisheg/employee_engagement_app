import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/psychometric_model.dart';
import '../../models/psychometric_model/psychometric_result.dart';

class PsychometricResultDetailScreen extends StatelessWidget {
  final PsychometricResult result;

  const PsychometricResultDetailScreen({super.key, required this.result});

  String _getDimensionLabel(String dimension) {
    const labels = {
      'EI': 'Extroversion vs Introversion',
      'SN': 'Sensing vs iNtuition',
      'TF': 'Thinking vs Feeling',
      'JP': 'Judging vs Perceiving',
    };
    return labels[dimension] ?? dimension;
  }

  String _getTypeDescription(String type) {
    const descriptions = {
      'ISTJ': 'The Logistician - Practical, fact-oriented, responsible',
      'ISFJ': 'The Defender - Protective, caring, dutiful',
      'INFJ': 'The Advocate - Insightful, principled, goal-oriented',
      'INTJ': 'The Architect - Strategic, logical, independent',
      'ISTP': 'The Virtuoso - Practical, spontaneous, analytical',
      'ISFP': 'The Adventurer - Flexible, charming, sensitive',
      'INFP': 'The Mediator - Idealistic, loyal, creative',
      'INTP': 'The Logician - Innovative, objective, curious',
      'ESTP': 'The Entrepreneur - Energetic, practical, perceptive',
      'ESFP': 'The Entertainer - Outgoing, spontaneous, enjoyable',
      'ENFP': 'The Campaigner - Enthusiastic, creative, sociable',
      'ENTP': 'The Debater - Smart, curious, argumentative',
      'ESTJ': 'The Executive - Efficient, responsible, realistic',
      'ESFJ': 'The Consul - Caring, supportive, cooperative',
      'ENFJ': 'The Commander - Inspiring, responsible, natural leader',
      'ENTJ': 'The Commander - Strategic, analytical, determined',
    };
    return descriptions[type] ?? 'Personality Type';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Results'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test title
              Text(
                result.test.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submitted on ${DateFormat('MMM dd, yyyy').format(result.submittedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Personality type card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Personality Type',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.personalityType,
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getTypeDescription(result.personalityType),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Dimensions breakdown
              Text(
                'Dimension Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildDimensionCard('EI', result.profile.ei),
              const SizedBox(height: 12),
              _buildDimensionCard('SN', result.profile.sn),
              const SizedBox(height: 12),
              _buildDimensionCard('TF', result.profile.tf),
              const SizedBox(height: 12),
              _buildDimensionCard('JP', result.profile.jp),
              const SizedBox(height: 32),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'About Your Type',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTypeDescription(result.personalityType),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Return button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Tests'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionCard(String label, PersonalityDimension dimension) {
    final labels = {
      'EI': ['Extroverted', 'Introverted'],
      'SN': ['Sensing', 'iNtuitive'],
      'TF': ['Thinking', 'Feeling'],
      'JP': ['Judging', 'Perceiving'],
    };

    final labelPair = labels[label] ?? ['First', 'Second'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getDimensionLabel(label),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelPair[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: dimension.firstPercentage / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dimension.firstPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelPair[1],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: dimension.secondPercentage / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dimension.secondPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

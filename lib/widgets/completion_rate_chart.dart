import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/design_system.dart';

class CompletionRateChart extends StatelessWidget {
  final List<double> weeklyData; // List of 7 percentages (0.0 to 1.0)

  const CompletionRateChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final isLargeDataset = weeklyData.length > 7;
    final barWidth = isLargeDataset ? 6.0 : 18.0;

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}%',
                  AppTypography.labelMedium.copyWith(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyData.length) return const SizedBox.shrink();

                  if (isLargeDataset) {
                    // For 30 days, only show labels for every week or start/end
                    if (index % 7 == 0 || index == weeklyData.length - 1) {
                      final date = DateTime.now().subtract(Duration(days: (weeklyData.length - 1) - index));
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(
                          DateFormat('M/d').format(date),
                          style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textTertiary),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  // We need to match the days to the actual dates
                  final date = DateTime.now().subtract(Duration(days: (weeklyData.length - 1) - index));
                  final dayLabel = DateFormat('E').format(date);

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      dayLabel,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      '${value.toInt()}',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeklyData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[index] * 100,
                  color: AppColors.primary,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.primarySurface,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

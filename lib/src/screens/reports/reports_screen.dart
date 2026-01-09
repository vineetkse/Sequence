import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/session_repository.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(l10n.reportsTitle),
            bottom: TabBar(
              tabs: [
                Tab(text: l10n.daily),
                Tab(text: l10n.weekly),
                Tab(text: l10n.monthly),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              children: const [
                _ReportTab(mode: _ReportMode.daily),
                _ReportTab(mode: _ReportMode.weekly),
                _ReportTab(mode: _ReportMode.monthly),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ReportMode { daily, weekly, monthly }

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.mode});

  final _ReportMode mode;

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionRepository>().sessions;
    final now = DateTime.now();

    final buckets = switch (mode) {
      _ReportMode.daily => _bucketByDay(sessions, now, days: 14),
      _ReportMode.weekly => _bucketByWeek(sessions, now, weeks: 12),
      _ReportMode.monthly => _bucketByMonth(sessions, now, months: 12),
    };

    final totalSeconds = buckets.fold<int>(0, (acc, b) => acc + b.seconds);
    final title = switch (mode) {
      _ReportMode.daily => AppLocalizations.of(context)!.daily,
      _ReportMode.weekly => AppLocalizations.of(context)!.weekly,
      _ReportMode.monthly => AppLocalizations.of(context)!.monthly,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          '${AppLocalizations.of(context)!.totalTime}: ${_formatMinutesSeconds(totalSeconds)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.auto_graph_rounded, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _BarReportChart(mode: mode, buckets: buckets),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBucket {
  const _ReportBucket({required this.start, required this.seconds});

  final DateTime start;
  final int seconds;
}

class _BarReportChart extends StatelessWidget {
  const _BarReportChart({required this.mode, required this.buckets});

  final _ReportMode mode;
  final List<_ReportBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxSeconds = buckets.fold<int>(0, (acc, b) => b.seconds > acc ? b.seconds : acc);
    final top = (maxSeconds <= 0) ? 1.0 : (maxSeconds.toDouble() * 1.2);

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceBetween,
        maxY: top,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.surfaceContainerHighest,
            getTooltipItem: (group, _, rod, __) {
              final b = buckets[group.x.toInt()];
              return BarTooltipItem(
                '${_labelForBucket(context, mode, b.start)}\n${_formatMinutesSeconds(rod.toY.toInt())}',
                TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _bottomInterval(mode),
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _shortLabelForBucket(context, mode, buckets[i].start),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].seconds.toDouble(),
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary,
                      scheme.tertiary,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }
}

double _bottomInterval(_ReportMode mode) => switch (mode) {
      _ReportMode.daily => 2,
      _ReportMode.weekly => 2,
      _ReportMode.monthly => 1,
    };

String _labelForBucket(BuildContext context, _ReportMode mode, DateTime start) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return switch (mode) {
    _ReportMode.daily => DateFormat.yMMMd(locale).format(start),
    _ReportMode.weekly => '${DateFormat.yMMMd(locale).format(start)}',
    _ReportMode.monthly => DateFormat.yMMM(locale).format(start),
  };
}

String _shortLabelForBucket(BuildContext context, _ReportMode mode, DateTime start) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return switch (mode) {
    _ReportMode.daily => DateFormat.E(locale).format(start),
    _ReportMode.weekly => DateFormat.Md(locale).format(start),
    _ReportMode.monthly => DateFormat.MMM(locale).format(start),
  };
}

List<_ReportBucket> _bucketByDay(List<SessionLog> sessions, DateTime now, {required int days}) {
  final end = _startOfDay(now);
  final starts = List<DateTime>.generate(days, (i) => end.subtract(Duration(days: days - 1 - i)));
  final map = <DateTime, int>{for (final d in starts) d: 0};

  for (final s in sessions) {
    final day = _startOfDay(s.startedAt);
    if (map.containsKey(day)) {
      map[day] = (map[day] ?? 0) + s.totalSeconds;
    }
  }

  return starts.map((d) => _ReportBucket(start: d, seconds: map[d] ?? 0)).toList(growable: false);
}

List<_ReportBucket> _bucketByWeek(List<SessionLog> sessions, DateTime now, {required int weeks}) {
  final end = _startOfWeek(now);
  final starts = List<DateTime>.generate(weeks, (i) => end.subtract(Duration(days: 7 * (weeks - 1 - i))));
  final map = <DateTime, int>{for (final d in starts) d: 0};

  for (final s in sessions) {
    final wk = _startOfWeek(s.startedAt);
    if (map.containsKey(wk)) {
      map[wk] = (map[wk] ?? 0) + s.totalSeconds;
    }
  }

  return starts.map((d) => _ReportBucket(start: d, seconds: map[d] ?? 0)).toList(growable: false);
}

List<_ReportBucket> _bucketByMonth(List<SessionLog> sessions, DateTime now, {required int months}) {
  final end = DateTime(now.year, now.month, 1);
  final starts = List<DateTime>.generate(months, (i) {
    final offset = months - 1 - i;
    final dt = DateTime(end.year, end.month - offset, 1);
    return DateTime(dt.year, dt.month, 1);
  });
  final map = <DateTime, int>{for (final d in starts) d: 0};

  for (final s in sessions) {
    final st = s.startedAt;
    final m = DateTime(st.year, st.month, 1);
    if (map.containsKey(m)) {
      map[m] = (map[m] ?? 0) + s.totalSeconds;
    }
  }

  return starts.map((d) => _ReportBucket(start: d, seconds: map[d] ?? 0)).toList(growable: false);
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _startOfWeek(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  final delta = (day.weekday - DateTime.monday) % 7;
  return day.subtract(Duration(days: delta));
}

String _formatMinutesSeconds(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}


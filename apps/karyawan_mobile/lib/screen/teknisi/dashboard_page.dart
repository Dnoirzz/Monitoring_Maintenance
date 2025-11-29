import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/providers/auth_provider.dart';
import 'package:shared/utils/name_helper.dart';

class TeknisiDashboardPage extends ConsumerStatefulWidget {
  const TeknisiDashboardPage({super.key});

  @override
  ConsumerState<TeknisiDashboardPage> createState() => _TeknisiDashboardPageState();
}

class _TeknisiDashboardPageState extends ConsumerState<TeknisiDashboardPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userFullName = authState.userFullName;
    final Color primary = const Color(0xFF0A9C5D);
    final Color textLight = const Color(0xFF0D1C15);
    final Color textSubtle = const Color(0xFF4B9B78);
    final Color cardLight = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primary,
                              child: Text(
                                NameHelper.getInitials(userFullName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          color: textLight,
                          onPressed: () {},
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NameHelper.getGreetingWithName(userFullName),
                      style: TextStyle(
                        color: textLight,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anda memiliki 2 tugas hari ini.',
                      style: TextStyle(color: textSubtle, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFCFE8DD)),
                  ),
                ),
                child: TabBar(
                  labelColor: textLight,
                  unselectedLabelColor: textSubtle,
                  indicatorColor: primary,
                  tabs: const [
                    Tab(text: 'Tugas Hari Ini'),
                    Tab(text: 'Jadwal Mendatang'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TasksList(primary: primary, textLight: textLight, cardLight: cardLight, textSubtle: textSubtle),
                    _UpcomingList(primary: primary, textLight: textLight, cardLight: cardLight, textSubtle: textSubtle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Lapor Kerusakan'),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _TasksList({
    super.key,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDhMFpfJO_AVtyTuN8mnexoF-kWv_iLjDusKM69ZVFAenCopg7tQBpEy-izxBj20UJdKmQ_Ot0jI6dNoQiXXWS5rg7ZXM2AkepIXe1LDOXtLAAAFBfKTYHhf_nO7NZrQJvqrR4JMkJDH8iKMRjY_ZdRnWDe5eCEXp153x4tSM5MkbKDIVWqpAmAFhjqWtmqKUnLktw8bFE9mRhGYxCVyZguOEsXZwm0B6U3dy23Fn8foaya2eCrV4qGUWPM1gpJKQGKJoCh52ar3yHd',
        'lokasi': 'Area Press A',
        'judul': 'Mesin Press Hidrolik #MP-001',
        'jenis': 'Perawatan Terjadwal',
        'statusColor': Colors.yellow,
        'statusText': 'Menunggu Dikerjakan',
      },
      {
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD9eGJi8SQI9zyW5ZZnuo0oOmUV4mwlgaX86jXQiieO3U7DazFWQeuOnvGQysVYM9BMNWeMcxCdRiZeK14teUpvws7HnYkIjHUTD3EOy8saaUq7Id2yBV0H9n6TICcOblCkzo2JbEX7llhzxgUCMxoghV5TcWPnoWKoW5oj9CcQbHePHc_lK_7gouhFAj-_k4yO-M_9FioUBVB-IRvE_UjQLiiceCgL-QI30ZpuUL9Tw---soSIGLpEWvRJgWv8okoraB2ZH8aq3-0g',
        'lokasi': 'Area Mixing B',
        'judul': 'Mesin Banbury #MB-003',
        'jenis': 'Perbaikan Mendesak',
        'statusColor': Colors.red,
        'statusText': 'Menunggu Dikerjakan',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: tasks
            .map((t) => _TaskCard(
                  imageUrl: t['image'] as String,
                  lokasi: t['lokasi'] as String,
                  judul: t['judul'] as String,
                  jenis: t['jenis'] as String,
                  statusColor: t['statusColor'] as Color,
                  statusText: t['statusText'] as String,
                  primary: primary,
                  textLight: textLight,
                  cardLight: cardLight,
                  textSubtle: textSubtle,
                ))
            .toList(),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _UpcomingList({
    super.key,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = [
      {
        'image':
            'https://images.unsplash.com/photo-1581094794329-c67549b38d6e?q=80&w=1935&auto=format&fit=crop',
        'lokasi': 'Area Extruder C',
        'judul': 'Extruder #EX-020',
        'jenis': 'Perawatan Terjadwal',
        'statusColor': Colors.blue,
        'statusText': 'Dijadwalkan',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: upcoming
            .map((t) => _TaskCard(
                  imageUrl: t['image'] as String,
                  lokasi: t['lokasi'] as String,
                  judul: t['judul'] as String,
                  jenis: t['jenis'] as String,
                  statusColor: t['statusColor'] as Color,
                  statusText: t['statusText'] as String,
                  primary: primary,
                  textLight: textLight,
                  cardLight: cardLight,
                  textSubtle: textSubtle,
                ))
            .toList(),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String imageUrl;
  final String lokasi;
  final String judul;
  final String jenis;
  final Color statusColor;
  final String statusText;
  final Color primary;
  final Color textLight;
  final Color cardLight;
  final Color textSubtle;

  const _TaskCard({
    super.key,
    required this.imageUrl,
    required this.lokasi,
    required this.judul,
    required this.jenis,
    required this.statusColor,
    required this.statusText,
    required this.primary,
    required this.textLight,
    required this.cardLight,
    required this.textSubtle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi: $lokasi',
                  style: TextStyle(color: textSubtle, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  judul,
                  style: TextStyle(
                    color: textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jenis: $jenis',
                          style: TextStyle(color: textSubtle, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {},
                      child: const Text('Mulai Kerjakan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/pengaduan_provider.dart';
import '../providers/statistics_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PengaduanProvider>(context, listen: false).loadStatistics();
      Provider.of<StatisticsProvider>(context, listen: false).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Pengaduan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildPengaduanList(),
          _buildRiwayat(),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Pengaduan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang,',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Statistik Pengaduan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<StatisticsProvider>(
            builder: (context, statisticsProvider, child) {
              if (statisticsProvider.isLoading) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              
              if (statisticsProvider.error != null) {
                return Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red[700], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat statistik',
                          style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statisticsProvider.error!,
                          style: TextStyle(color: Colors.red[600], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => statisticsProvider.refresh(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (statisticsProvider.statistics != null) {
                return _buildStatisticsCards(statisticsProvider.statistics!);
              }
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Tidak ada data statistik'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => statisticsProvider.loadStatistics(),
                        child: const Text('Muat Data'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Menu Utama',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuGrid(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(statistics) {
    return Column(
      children: [
        // First row with Total and Pending
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.report, color: Colors.blue, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        '${statistics.total}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text('Total Pengaduan'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.pending, color: Colors.orange, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        '${statistics.pending}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const Text('Pending'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row with Proses and Selesai
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.yellow[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.refresh, color: Colors.amber, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        '${statistics.proses}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const Text('Proses'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        '${statistics.selesai}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Selesai'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final menus = [
      {
        'title': 'Buat Pengaduan',
        'icon': Icons.add_box,
        'color': Colors.blue,
        'route': '/pengaduan/create',
      },
      {
        'title': 'Daftar Pengaduan',
        'icon': Icons.list,
        'color': Colors.green,
        'route': '/pengaduan',
      },
      {
        'title': 'Profil Saya',
        'icon': Icons.person,
        'color': Colors.orange,
        'route': '/profile',
      },
      {
        'title': 'Ubah Password',
        'icon': Icons.lock,
        'color': Colors.purple,
        'route': '/profile/change-password',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return Card(
          child: InkWell(
            onTap: () {
              context.push(menu['route'] as String);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    menu['icon'] as IconData,
                    color: menu['color'] as Color,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menu['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPengaduanList() {
    return Consumer<PengaduanProvider>(
      builder: (context, pengaduanProvider, child) {
        if (pengaduanProvider.pengaduans.isEmpty) {
          pengaduanProvider.loadPengaduans();
        }

        if (pengaduanProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pengaduanProvider.pengaduans.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.report_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada pengaduan'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pengaduanProvider.pengaduans.length,
          itemBuilder: (context, index) {
            final pengaduan = pengaduanProvider.pengaduans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(pengaduan.judul),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pengaduan.deskripsi.length > 100
                        ? '${pengaduan.deskripsi.substring(0, 100)}...'
                        : pengaduan.deskripsi),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(pengaduan.status),
                          size: 16,
                          color: _getStatusColor(pengaduan.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pengaduan.status,
                          style: TextStyle(
                            color: _getStatusColor(pengaduan.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push('/pengaduan/${pengaduan.id}');
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRiwayat() {
    return _buildPengaduanList(); // Same as pengaduan list for now
  }

  Widget _buildProfile() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) return const Center(child: Text('User not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profil'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.push('/profile/edit');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Ubah Password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.push('/profile/change-password');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'proses':
        return Icons.refresh;
      case 'selesai':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'proses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
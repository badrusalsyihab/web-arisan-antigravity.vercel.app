import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/models/group_model.dart';
import 'core/models/user_model.dart';
import 'core/services/firebase_service.dart';
import 'core/services/user_session.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/widgets/dashboard_skeleton.dart';
import 'features/roulette/screens/roulette_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/group/screens/no_group_screen.dart';
import 'features/group/screens/join_group_screen.dart';
import 'core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
  DeepLinkService.initialize();
  runApp(const DigitalArisanApp());
}

class DigitalArisanApp extends StatefulWidget {
  const DigitalArisanApp({super.key});

  @override
  State<DigitalArisanApp> createState() => _DigitalArisanAppState();
}

class _DigitalArisanAppState extends State<DigitalArisanApp> {
  UserModel? _currentUser;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final savedUser = await UserSession.getUser();
      if (savedUser != null) {
        setState(() {
          _currentUser = savedUser;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Digital Arisan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _currentUser != null
          ? MainNavigationScreen(
              currentUser: _currentUser!,
              onLogout: () async {
                await UserSession.clear();
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (_) {}
                setState(() {
                  _currentUser = null;
                });
              },
            )
          : AuthScreen(
              onAuthSuccess: (user) {
                setState(() {
                  _currentUser = user;
                });
              },
            ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isScrolled = false;
  bool _isLoadingGroup = true;
  final FirebaseService _firebaseService = FirebaseService();

  // Active Group Model State (null if user has not created/joined a group yet)
  GroupModel? activeGroup;

  @override
  void initState() {
    super.initState();
    _restoreActiveGroup();
  }

  Future<void> _restoreActiveGroup() async {
    try {
      final savedGroupId = await UserSession.getActiveGroupId();
      if (savedGroupId != null) {
        final group = await _firebaseService.getGroup(savedGroupId);
        if (group != null && mounted) {
          setState(() {
            activeGroup = group;
            _isLoadingGroup = false;
          });
          return;
        }
      }
      final latestGroup = await _firebaseService.fetchLatestGroup();
      if (latestGroup != null && mounted) {
        setState(() {
          activeGroup = latestGroup;
          _isLoadingGroup = false;
        });
        await UserSession.saveActiveGroupId(latestGroup.id);
        return;
      }
    } catch (e) {
      debugPrint("Restore group error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGroup = false;
        });
        
        // Handle auto-join via deep link after group is resolved
        final pendingCode = DeepLinkService.consumePendingJoinCode();
        if (pendingCode != null && pendingCode.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JoinGroupScreen(
                  currentUser: widget.currentUser,
                  initialJoinCode: pendingCode,
                  onGroupJoined: (group) {
                    _onGroupStateUpdated(group);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
              ),
            );
          });
        }
      }
    }
  }

  void _onGroupStateUpdated(GroupModel updatedGroup) {
    setState(() {
      activeGroup = updatedGroup;
      _isLoadingGroup = false;
    });
    UserSession.saveActiveGroupId(updatedGroup.id);
    // Realtime sync to Cloud Firestore
    _firebaseService.syncGroup(updatedGroup);
  }

  void _onWinnerSelected(String winnerName) {
    if (activeGroup == null) return;
    final group = activeGroup!;

    final updatedMembers = group.members.map((m) {
      if (m.name == winnerName) {
        return m.copyWith(isWinner: true, winPeriodLabel: 'Pemenang Periode ${group.activePeriodIndex}');
      }
      return m;
    }).toList();

    final updatedSchedule = Map<int, String>.from(group.winnerSchedule);
    updatedSchedule[group.activePeriodIndex] = winnerName;

    final nextPeriod = group.activePeriodIndex < group.members.length 
        ? group.activePeriodIndex + 1 
        : group.activePeriodIndex;

    final updatedGroup = GroupModel(
      id: group.id,
      name: group.name,
      potAmount: group.potAmount,
      hasKas: group.hasKas,
      kasAmount: group.kasAmount,
      periodType: group.periodType,
      activePeriodIndex: nextPeriod,
      members: updatedMembers,
      winnerSchedule: updatedSchedule,
    );

    _onGroupStateUpdated(updatedGroup);
    setState(() {
      _currentIndex = 0; // Return to Dashboard
    });
  }

  void _deleteGroup() {
    if (activeGroup == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kelompok', style: TextStyle(color: AppTheme.warning)),
        content: Text('Apakah Anda yakin ingin menghapus kelompok "${activeGroup!.name}" secara permanen? Semua data (kas, anggota, riwayat) akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await _firebaseService.deleteGroup(activeGroup!.id);
              if (success) {
                await UserSession.clearActiveGroupId();
                if (mounted) {
                  setState(() {
                    activeGroup = null;
                    _currentIndex = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelompok berhasil dihapus.'), backgroundColor: AppTheme.primary),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus kelompok.'), backgroundColor: AppTheme.warning),
                  );
                }
              }
            },
            child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGroup) {
      return const DashboardSkeletonScreen();
    }

    final currentGroup = activeGroup;

    final Widget dashboardWidget = currentGroup != null
        ? DashboardScreen(
            group: currentGroup,
            currentUser: widget.currentUser,
            onGroupUpdated: _onGroupStateUpdated,
            onNavigateToTab: (index) => setState(() => _currentIndex = index),
          )
        : NoGroupScreen(
            currentUser: widget.currentUser,
            onGroupCreated: _onGroupStateUpdated,
          );

    final Widget rouletteWidget = currentGroup != null
        ? RouletteScreen(
            group: currentGroup,
            onWinnerSelected: _onWinnerSelected,
          )
        : NoGroupScreen(
            currentUser: widget.currentUser,
            onGroupCreated: _onGroupStateUpdated,
          );

    final Widget historyWidget = currentGroup != null
        ? HistoryScreen(group: currentGroup)
        : NoGroupScreen(
            currentUser: widget.currentUser,
            onGroupCreated: _onGroupStateUpdated,
          );

    final List<Widget> screens = [
      dashboardWidget,
      rouletteWidget,
      if (currentGroup?.hasKas ?? true) historyWidget,
      ProfileScreen(
        currentUser: widget.currentUser,
        onGroupSelected: _onGroupStateUpdated,
        onLogout: widget.onLogout,
        onUserUpdated: (updatedUser) {},
        onGroupCreated: (g) {
          _onGroupStateUpdated(g);
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.casino_outlined), activeIcon: Icon(Icons.casino), label: 'Kocokan'),
      if (currentGroup?.hasKas ?? true)
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Kas'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
    ];

    // Ensure _currentIndex is within bounds if the group changed and removed the Kas tab
    if (_currentIndex >= screens.length) {
      _currentIndex = screens.length - 1;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          final isScrolledNow = scrollNotification.metrics.pixels > 15;
          if (isScrolledNow != _isScrolled) {
            setState(() {
              _isScrolled = isScrolledNow;
            });
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _isScrolled ? AppTheme.primary : AppTheme.bgLight,
          surfaceTintColor: Colors.transparent,
          elevation: _isScrolled ? 4.0 : 0.0,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          title: currentGroup != null
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isScrolled ? AppTheme.limeAccent : AppTheme.cardBorder,
                      width: _isScrolled ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isScrolled ? 0.15 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => _showGroupSwitcher(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👥 ', style: TextStyle(fontSize: 14)),
                        Text(
                          currentGroup.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 18),
                      ],
                    ),
                  ),
                )
              : const Text(
                  'Digital Arisan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
          actions: [
            if (currentGroup != null) ...[
              Builder(
                builder: (context) {
                  final isAdmin = currentGroup.members.firstWhere(
                    (m) => m.userId == widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_'),
                    orElse: () => currentGroup.members.first,
                  ).role == 'Admin';
                  
                  if (isAdmin) {
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppTheme.textMain),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteGroup();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: AppTheme.warning, size: 20),
                              SizedBox(width: 8),
                              Text('Hapus Kelompok', style: TextStyle(color: AppTheme.warning)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),

        // Clean Professional Light Bottom Nav Bar
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.cardBorder)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _isScrolled = false;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: navItems,
          ),
        ),
      ),
    );
  }

  void _showGroupSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Kelompok Arisan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 14),
              StreamBuilder<List<GroupModel>>(
                stream: _firebaseService.streamAllGroups(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Belum ada kelompok lain.', style: TextStyle(color: AppTheme.textMuted));
                  }
                  
                  final groups = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: groups.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isActive = activeGroup?.id == group.id;

                      return ListTile(
                        tileColor: isActive ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        title: Text('👑 ${group.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isActive ? AppTheme.textMain : AppTheme.textMuted)),
                        subtitle: Text('Jenis: Periode ${group.periodType}', style: const TextStyle(fontSize: 11, color: AppTheme.accent)),
                        trailing: isActive 
                            ? const Icon(Icons.check_circle, color: AppTheme.primary, size: 20) 
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (!isActive) {
                            _onGroupStateUpdated(group);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Berhasil beralih ke kelompok ${group.name}')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.group_add, color: Colors.white, size: 20),
                label: const Text('Gabung Kelompok via Kode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinGroupScreen(
                        currentUser: widget.currentUser,
                        onGroupJoined: (group) {
                          _onGroupStateUpdated(group);
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

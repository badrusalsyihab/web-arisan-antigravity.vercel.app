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

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_arisan_antigravity/l10n/app_localizations.dart';

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('id'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        if (_isCheckingSession) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            builder: (context, child) {
              return Container(
                color: const Color(0xFFF0F2F5), // Light background for desktop
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: child!,
                  ),
                ),
              );
            },
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
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return Container(
              color: const Color(0xFFF0F2F5), // Light background for desktop
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: child!,
                ),
              ),
            );
          },
          home: _currentUser != null
              ? MainNavigationScreen(
                  key: ValueKey(_currentUser!.email),
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
                  onAuthSuccess: (user) async {
                    // Force clearing active group on explicit login so it fetches the newest batch
                    await UserSession.clearActiveGroupId();
                    setState(() {
                      _currentUser = user;
                    });
                  },
                ),
        );
      },
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
      final latestGroup = await _firebaseService.fetchLatestGroup(widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_'));
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
        
        final pendingCode = DeepLinkService.consumePendingJoinCode();
        if (pendingCode != null && pendingCode.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
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
            }
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

    final updatedGroup = group.copyWith(
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
                final nextGroup = await _firebaseService.fetchLatestGroup(widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_'));
                if (mounted) {
                  setState(() {
                    activeGroup = nextGroup;
                    _currentIndex = 0;
                  });
                  if (nextGroup != null) {
                    await UserSession.saveActiveGroupId(nextGroup.id);
                  }
                  /* ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kelompok berhasil dihapus.'), backgroundColor: AppTheme.primary),
                  ); */
                }
              } else {
                if (mounted) {
                  /* ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus kelompok.'), backgroundColor: AppTheme.warning),
                  ); */
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
            currentUser: widget.currentUser,
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
      BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: AppLocalizations.of(context)!.navDashboard),
      BottomNavigationBarItem(icon: const Icon(Icons.casino_outlined), activeIcon: const Icon(Icons.casino), label: AppLocalizations.of(context)!.navRoulette),
      if (currentGroup?.hasKas ?? true)
        BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)!.navKas),
      BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: AppLocalizations.of(context)!.navProfile),
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
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 10.0),
            child: InkWell(
              onTap: () {
                appLocale.value = appLocale.value.languageCode == 'id' 
                  ? const Locale('en') 
                  : const Locale('id');
              },
              borderRadius: BorderRadius.circular(24),
              child: ValueListenableBuilder<Locale>(
                valueListenable: appLocale,
                builder: (context, locale, child) {
                  final isId = locale.languageCode == 'id';
                  return Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? Colors.white.withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _isScrolled ? Colors.white54 : AppTheme.primary.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isId ? '🇮🇩' : '🇬🇧',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locale.languageCode.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isScrolled ? Colors.white : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
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
              : const SizedBox.shrink(),
          actions: [
            if (currentGroup != null) ...[
              Builder(
                builder: (context) {
                  final isAdmin = currentGroup.isAdmin(widget.currentUser.email);
                  
                  if (isAdmin) {
                    return Row(
                      children: [
                        if (currentGroup.pendingMembers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.notifications_outlined, color: _isScrolled ? Colors.white : AppTheme.textMain),
                                  onPressed: () {
                                    _showPendingMembersModal(context, currentGroup);
                                  },
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${currentGroup.pendingMembers.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: _isScrolled ? Colors.white : AppTheme.textMain),
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
                                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Hapus Kelompok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
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
              Text(AppLocalizations.of(context)!.groupSwitcherTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              const SizedBox(height: 14),
              StreamBuilder<List<GroupModel>>(
                stream: _firebaseService.streamUserGroups(widget.currentUser.email.replaceAll('.', '_').replaceAll('@', '_at_')),
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
                label: Text(AppLocalizations.of(context)!.joinGroupViaCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showPendingMembersModal(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pendingMembers = group.pendingMembers;
            
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Daftar Calon Anggota', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 16),
                  if (pendingMembers.isEmpty)
                    const Text('Tidak ada anggota yang menunggu persetujuan.', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: pendingMembers.length,
                      itemBuilder: (context, index) {
                        final pending = pendingMembers[index];
                        return ListTile(
                          title: Text(pending.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Menunggu persetujuan'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  final success = await _firebaseService.rejectMember(group, pending);
                                  if (success) {
                                    final updatedGroup = await _firebaseService.getGroup(group.id);
                                    if (updatedGroup != null) {
                                      _onGroupStateUpdated(updatedGroup);
                                      group = updatedGroup;
                                      setModalState(() {});
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: AppTheme.primary),
                                onPressed: () async {
                                  final success = await _firebaseService.approveMember(group, pending);
                                  if (success) {
                                    final updatedGroup = await _firebaseService.getGroup(group.id);
                                    if (updatedGroup != null) {
                                      _onGroupStateUpdated(updatedGroup);
                                      group = updatedGroup;
                                      setModalState(() {});
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(color: AppTheme.accent)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

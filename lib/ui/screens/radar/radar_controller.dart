import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/user_profile.dart';
import '../../providers/app_providers.dart';

class RadarState {
  const RadarState({
    this.allUsers = const [],
    this.filterMode,
    this.isScanning = false,
  });

  final List<UserProfile> allUsers;
  final ConnectionMode? filterMode;
  final bool isScanning;

  List<UserProfile> get filtered => filterMode == null
      ? allUsers
      : allUsers.where((u) => u.seenVia.contains(filterMode)).toList();

  RadarState copyWith({
    List<UserProfile>? allUsers,
    ConnectionMode? filterMode,
    bool clearFilter = false,
    bool? isScanning,
  }) =>
      RadarState(
        allUsers: allUsers ?? this.allUsers,
        filterMode: clearFilter ? null : filterMode ?? this.filterMode,
        isScanning: isScanning ?? this.isScanning,
      );
}

class RadarNotifier extends StateNotifier<RadarState> {
  RadarNotifier(this._ref) : super(const RadarState());
  final Ref _ref;

  void setFilter(ConnectionMode? mode) => state =
      mode == null ? state.copyWith(clearFilter: true) : state.copyWith(filterMode: mode);

  void updateUsers(List<UserProfile> users) {
    final sorted = [...users]
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    state = state.copyWith(allUsers: sorted);
  }

  Future<void> startScan() async {
    state = state.copyWith(isScanning: true);
    await _ref.read(meshServiceProvider).start();
    await _ref.read(discoveryServiceProvider).start();
  }
}

final radarNotifierProvider =
    StateNotifierProvider<RadarNotifier, RadarState>((ref) {
  final notifier = RadarNotifier(ref);
  ref.listen(nearbyUsersProvider, (_, next) {
    next.whenData(notifier.updateUsers);
  });
  return notifier;
});

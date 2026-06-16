// TODO: wire up go_router when added to pubspec.yaml
//
// Suggested routes:
//   /               → ChatsScreen
//   /chat/:chatId   → ChatScreen
//   /radar          → RadarScreen
//   /files          → FilesScreen
//   /profile        → ProfileScreen
//   /call/:peerId   → VoiceCallScreen
//
// Example:
// final router = GoRouter(routes: [
//   ShellRoute(builder: (_, __, child) => AppShell(child: child), routes: [
//     GoRoute(path: '/',          builder: (_, __) => const ChatsScreen()),
//     GoRoute(path: '/radar',     builder: (_, __) => const RadarScreen()),
//     GoRoute(path: '/files',     builder: (_, __) => const FilesScreen()),
//     GoRoute(path: '/profile',   builder: (_, __) => const ProfileScreen()),
//     GoRoute(path: '/chat/:id',  builder: (_, s) => ChatScreen(chatId: s.pathParameters['id']!)),
//     GoRoute(path: '/call/:id',  builder: (_, s) => VoiceCallScreen(peerId: s.pathParameters['id']!)),
//   ]),
// ]);

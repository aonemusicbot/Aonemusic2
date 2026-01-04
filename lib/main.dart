import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ഫയർബേസ് തുടങ്ങുന്നു
  runApp(const AOneMusic());
}

class AOneMusic extends StatelessWidget {
  const AOneMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A One Music',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const MusicListScreen(),
    );
  }
}

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseReference _musicRef = FirebaseDatabase.instance.ref().child('songs');

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSong(String url) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Music Library')),
      body: StreamBuilder(
        stream: _musicRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> songs = snapshot.data!.snapshot.value as Map;
            List songList = songs.values.toList();

            return ListView.builder(
              itemCount: songList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(songList[index]['title'] ?? 'Unknown Title'),
                  subtitle: Text(songList[index]['artist'] ?? 'Unknown Artist'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _playSong(songList[index]['url']),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

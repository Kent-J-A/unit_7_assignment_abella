import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

void main() => runApp(const NarutoApp());

class NarutoApp extends StatelessWidget {
  const NarutoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naruto Characters',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchCharacters() async {
    final url = Uri.parse('https://narutodb.xyz/api/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['characters'];
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Naruto Characters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No characters found.'));
          } else {
            final characters = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                final controller = ExpandedTileController();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpandedTile(
                    controller: controller,
                    theme: ExpandedTileThemeData(
                      headerColor: Colors.white,
                      contentBackgroundColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.all(10.0),
                      headerPadding: const EdgeInsets.all(8.0),
                    ),
                    title: Row(
                      children: [
                        character['images'] != null &&
                                character['images'].isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  character['images'][0],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            character['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildCharacterDetails(character),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildCharacterDetails(Map<String, dynamic> character) {
    List<Widget> details = [];

    character.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        if (value is List) {
          details.add(
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${_formatKey(key)}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          );
          details.addAll(
            value.map<Widget>((item) => Text('- $item')).toList(),
          );
        } else if (value is Map) {
          details.add(
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${_formatKey(key)}:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          );
          value.forEach((subKey, subValue) {
            details.add(Text('$subKey: $subValue'));
          });
        } else {
          details.add(
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${_formatKey(key)}: $value',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          );
        }
      }
    });

    if (details.isEmpty) {
      details.add(const Text('No details available.'));
    }

    return details;
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
          return '${match.group(1)} ${match.group(2)}';
        })
        .replaceAll('_', ' ')
        .toUpperCase();
  }
}

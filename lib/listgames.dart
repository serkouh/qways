import 'package:flutter/material.dart';
import 'package:qways/theme/theme.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  final List<Map<String, String>> _games = [
    {
      'title': 'World Explorer',
      'description': 'Discover new locations around the globe!',
      'date': 'Oct 15, 2025',
    },
    {
      'title': 'City Challenge',
      'description': 'Answer questions about famous cities!',
      'date': 'Oct 13, 2025',
    },
    {
      'title': 'Geo Quiz Journey',
      'description': 'Travel and test your geography skills!',
      'date': 'Oct 10, 2025',
    },
  ];

  void _showGameOptions(Map<String, String> game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(fixPadding * 2),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: fixPadding),
                decoration: BoxDecoration(
                  color: greyColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.play_arrow_rounded, color: Colors.green),
              title: Text('Play Game', style: bold16BlackText),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: primaryColor),
              title: Text('Edit Game', style: bold16BlackText),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: Text('Delete Game', style: bold16BlackText),
              onTap: () {
                setState(() => _games.remove(game));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(Map<String, String> game) {
    return InkWell(
      onTap: () => _showGameOptions(game),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: fixPadding * 2),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(fixPadding * 1.5),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.public_rounded,
                    color: primaryColor, size: 28),
              ),
              widthSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['title']!,
                      style: bold16BlackText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    height5Space,
                    Text(
                      game['description']!,
                      style: semibold14Grey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              widthSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    game['date']!,
                    style: semibold14Grey,
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: greyColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(fixPadding * 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videogame_asset_rounded,
                color: primaryColor.withOpacity(0.6), size: 90),
            heightSpace,
            Text(
              "No games created yet",
              style: bold18BlackText,
              textAlign: TextAlign.center,
            ),
            height5Space,
            Text(
              "Tap the + button to create your first game!",
              style: semibold14Grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text("My Created Games", style: bold18White),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: _games.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(fixPadding * 2),
              itemCount: _games.length,
              itemBuilder: (context, index) => _buildGameCard(_games[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create screen
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: whiteColor),
        label: Text("New Game", style: bold16White),
      ),
    );
  }
}

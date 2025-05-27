import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sql_flutter_project/pages/user/profileView.dart';

class HomePage extends StatefulWidget {
  final bool darkMode;
  final String username;

  const HomePage({super.key, this.darkMode = true, this.username = "Guest"});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late bool _darkMode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _featuredMovies = [
    {
      'title': 'The Adventure Begins',
      'image': 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=2070',
      'rating': 4.8,
      'genre': 'Adventure'
    },
    {
      'title': 'Lost in Space',
      'image': 'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?q=80&w=2071',
      'rating': 4.5,
      'genre': 'Sci-Fi'
    },
    {
      'title': 'City Lights',
      'image': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?q=80&w=2064',
      'rating': 4.7,
      'genre': 'Drama'
    },
    {
      'title': 'Mysterious Island',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073',
      'rating': 4.2,
      'genre': 'Mystery'
    },
  ];

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> testProtectedEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/user/hello'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      _showSnackBar("Backend says: ${response.body}");
    } else {
      _showSnackBar("Failed: ${response.statusCode}");
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _darkMode
                    ? [Colors.black, Colors.grey[900]!]
                    : [Color(0xFFFD0CA9), Color(0xFFF7F6FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Movie Rentals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFEC0DC6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                    Text(
                      widget.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: testProtectedEndpoint,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      child: const Text("Test Protected Backend", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 30),

                    // Feature buttons
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFeatureCard(Icons.star, 'Top Rated', Colors.amber),
                          _buildFeatureCard(Icons.new_releases, 'New Releases', Colors.redAccent),
                          _buildFeatureCard(Icons.local_movies, 'Genres', Colors.teal),
                          _buildFeatureCard(Icons.favorite, 'Favorites', Colors.pink),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Movie section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Movies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('See All', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _featuredMovies.length,
                      itemBuilder: (context, index) {
                        return _buildMovieCard(_featuredMovies[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top-right buttons (dark mode + profile + logout)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _darkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _darkMode = !_darkMode),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileView()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie['image'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${movie['rating']}', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie['genre'],
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'compareScreen.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pokémon App',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          bottom: TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Compare'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              // HomeScreen wrapped with Container
              color: Colors.black87, 
              child: HomeScreen(),
            ),
            Container(
              child: CompareScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> pokemonList;

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=0&limit=151'));
    final data = json.decode(response.body);
    setState(() {
      pokemonList = data['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return pokemonList == null
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              //crossAxisSpacing: 8.0,
              //mainAxisSpacing: 8.0,
            ),
            itemCount: pokemonList.length,
            itemBuilder: (context, index) {
              final pokemon = pokemonList[index];
              final pokemonId = index + 1;
              final cardColor = Color.fromARGB(255, 248, 248, 246);
              final imageUrl =
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PokemonDetailsScreen(pokemonName: pokemon['name']),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(3.0), 
                  child: Card(
                    color: cardColor,
                    child: Column(
                      children: <Widget>[
                        Image.network(
                          imageUrl,
                          width: 200, 
                          height: 165,
                        ),
                        SizedBox(height: 10),
                        Text(
                          pokemon['name'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class PokemonDetailsScreen extends StatelessWidget {
  final String pokemonName;

  PokemonDetailsScreen({required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Pokémon Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.black87, 
      body: Center(
        child: FutureBuilder(
          future: fetchPokemonDetails(pokemonName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final data = snapshot.data as Map<String, dynamic>;
              final stats = data['stats'] as List<dynamic>;
              final types = data['types'] as List<dynamic>;
              final backImageUrl = data['sprites']['back_default'];
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height *
                        0.35, 
                    padding: EdgeInsets.symmetric(
                        horizontal: 20), 

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft:
                            Radius.circular(70), 
                        bottomRight:
                            Radius.circular(70), 
                      ),
                      border: Border.all(
                          color: Colors.black, width: 2),
                      color: Colors.white,
                      image: DecorationImage(
                        opacity: 0.8,
                        image: AssetImage(
                            'assets/background_pokemon.jpg'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(data['sprites']['front_default']),
                        if (backImageUrl != null)
                          SizedBox(width:20), 
                        if (backImageUrl != null)
                          Image.network(
                            backImageUrl,
                            width: 200, 
                            height: 200,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity, 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$pokemonName',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Type 1: ${types[0]['type']['name']}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold), 
                            ),
                            SizedBox(height: 20),
                            if (types.length > 1)
                              Text(
                                'Type 2: ${types[1]['type']['name']}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold), 
                              ),
                            SizedBox(height: 20),
                            Text(
                              'Base stats:',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold), 
                            ),
                            SizedBox(height: 20),
                            ...stats.map((stat) {
                              return Text(
                                '${stat['stat']['name']}: ${stat['base_stat']}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String pokemonName) async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
    final data = json.decode(response.body);
    return data;
  }
}

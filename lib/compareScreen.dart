import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String selectedPokemonName = '';
  String selectedPokemonImageUrl = '';
  String selectedPokemonName2 = '';
  String selectedPokemonImageUrl2 = '';
  String selectedPokemonType1 = '';
  String selectedPokemonType2 = '';
  List<int> selectedPokemonBaseStats1List = [];
  List<int> selectedPokemonBaseStats2List = [];

  Future<Map<String, dynamic>> fetchPokemonData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> fetchPokemonNames() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=150'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> pokemonList = data['results'];
      return pokemonList.map<String>((pokemon) => pokemon['name']).toList();
    } else {
      throw Exception('Failed to load Pokemon names');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPokemonData('https://pokeapi.co/api/v2/pokemon/1/')
        .then((pokemonData) {
      setState(() {
        selectedPokemonName = pokemonData['name'];
        selectedPokemonName2 = pokemonData['name'];
        selectedPokemonImageUrl = pokemonData['sprites']['front_default'];
        selectedPokemonImageUrl2 = pokemonData['sprites']['front_default'];
        selectedPokemonType1 = pokemonData['types'][0]['type']['name'];
        if (pokemonData['types'].length > 1) {
          selectedPokemonType2 = pokemonData['types'][1]['type']['name'];
        }
        selectedPokemonBaseStats1List = List.generate(
            pokemonData['stats'].length,
            (index) => pokemonData['stats'][index]['base_stat']);
        selectedPokemonBaseStats2List = List.generate(
            pokemonData['stats'].length,
            (index) => pokemonData['stats'][index]['base_stat']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Choose the Pokemon you want to compare.',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 220,
                        height: 480,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            FutureBuilder<List<String>>(
                              future: fetchPokemonNames(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold));
                                } else {
                                  List<String> pokemonNames = snapshot.data!;
                                  return DropdownButton<String>(
                                    value: selectedPokemonName,
                                    dropdownColor: Colors.black87, 
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedPokemonName = newValue!;
                                        fetchPokemonData(
                                                'https://pokeapi.co/api/v2/pokemon/$newValue/')
                                            .then((pokemonData) {
                                          setState(() {
                                            selectedPokemonImageUrl =
                                                pokemonData['sprites']
                                                    ['front_default'];
                                            selectedPokemonType1 =
                                                pokemonData['types'][0]['type']
                                                    ['name'];
                                            if (pokemonData['types'].length >
                                                1) {
                                              selectedPokemonType2 =
                                                  pokemonData['types'][1]
                                                      ['type']['name'];
                                            } else {
                                              selectedPokemonType2 = '';
                                            }
                                            selectedPokemonBaseStats1List =
                                              List.generate(
                                                pokemonData['stats'].length,(index) =>
                                                pokemonData['stats'][index]['base_stat']);
                                          });
                                        });
                                      });
                                    },
                                    items: pokemonNames
                                        .map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                        );
                                      },
                                    ).toList(),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 20),
                            selectedPokemonImageUrl.isNotEmpty
                                ? Image.network(selectedPokemonImageUrl)
                                : SizedBox.shrink(),
                            SizedBox(height: 20),
                            Text('Type 1: $selectedPokemonType1',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text('Type 2: $selectedPokemonType2',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            Text(
                              'Base stats:',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            ),
                            for (int i = 0;
                                i < selectedPokemonBaseStats1List.length;
                                i++)
                              Text(
                                  '${[
                                    'hp',
                                    'attack',
                                    'defense',
                                    'special-attack',
                                    'special-defense',
                                    'speed',
                                  ][i]}: ${selectedPokemonBaseStats1List[i]}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 220,
                        height: 480,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: <Widget>[
                            FutureBuilder<List<String>>(
                              future: fetchPokemonNames(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold));
                                } else {
                                  List<String> pokemonNames = snapshot.data!;
                                  return DropdownButton<String>(
                                    value: selectedPokemonName2,
                                    dropdownColor: Colors.black87, 
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        if (newValue != null &&
                                            newValue != selectedPokemonName) {
                                          selectedPokemonName2 = newValue!;
                                          fetchPokemonData(
                                                  'https://pokeapi.co/api/v2/pokemon/$newValue/')
                                              .then((pokemonData) {
                                            setState(() {
                                              selectedPokemonImageUrl2 =
                                                  pokemonData['sprites']
                                                      ['front_default'];
                                              selectedPokemonType1 =
                                                  pokemonData['types'][0]
                                                      ['type']['name'];
                                              if (pokemonData['types'].length >
                                                  1) {
                                                selectedPokemonType2 =
                                                    pokemonData['types'][1]
                                                        ['type']['name'];
                                              } else {
                                                selectedPokemonType2 = '';
                                              }
                                              selectedPokemonBaseStats2List =
                                                List.generate(
                                                  pokemonData['stats'].length,(index) =>
                                                  pokemonData['stats'][index]['base_stat']);
                                            });
                                          });
                                        }
                                      });
                                    },
                                    items: pokemonNames
                                        .map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        );
                                      },
                                    ).toList(),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 20),
                            selectedPokemonImageUrl2.isNotEmpty
                                ? Image.network(selectedPokemonImageUrl2)
                                : SizedBox.shrink(),
                            SizedBox(height: 20),
                            Text('Type 1: $selectedPokemonType1',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text('Type 2: $selectedPokemonType2',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            Text(
                              'Base stats:',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            for (int i = 0;
                                i < selectedPokemonBaseStats1List.length;
                                i++)
                              Text(
                                  '${[
                                    'hp',
                                    'attack',
                                    'defense',
                                    'special-attack',
                                    'special-defense',
                                    'speed'
                                  ][i]}: ${selectedPokemonBaseStats1List[i]}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

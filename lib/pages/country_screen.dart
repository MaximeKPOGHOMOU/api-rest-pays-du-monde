import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_api/services/api_service.dart';
import '../models/country.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  late Future<List<Country>> futureCountries;
  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>>
      connectivitySubscription; // Change type to List<ConnectivityResult>

  @override
  void initState() {
    super.initState();
    futureCountries = CountryService().getCountries();

    // Abonnement aux changements de connectivité
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        // Mettre à jour l'état de la connexion en fonction de la liste de résultats
        isConnected =
            results.isNotEmpty && results.contains(ConnectivityResult.wifi) ||
                results.contains(ConnectivityResult.mobile);
      });
    });
  }

  @override
  void dispose() {
    // Annuler l'écoute du flux de connectivité lorsque le widget est détruit
    connectivitySubscription.cancel();
    super.dispose();
  }

  // Fonction pour recharger les données
  void _reloadCountries() {
    if (isConnected) {
      setState(() {
        futureCountries =
            CountryService().getCountries(); // Recharger les données
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Aucune connexion Internet",
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pays - capital',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Country>>(
        future: futureCountries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error
                            .toString()
                            .contains('Aucune connexion internet')
                        ? 'Aucune connexion internet.'
                        : 'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _reloadCountries,
                    child: const Text('Reessayer'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun pays trouvé"));
          } else {
            List<Country> countryList = snapshot.data!;
            return ListView.builder(
              itemCount: countryList.length,
              itemBuilder: (context, index) {
                Country country = countryList[index];
                return Card(
                  elevation: 4,
                  color: Colors.white,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        country.flagUrl,
                        fit: BoxFit.fitWidth,
                        height: 50,
                        width: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag,
                                size: 50, color: Colors.grey),
                      ),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.capital),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

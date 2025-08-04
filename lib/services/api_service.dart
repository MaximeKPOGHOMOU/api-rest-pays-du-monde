import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/country.dart';
import 'package:http/http.dart' as http;

class CountryService {
  // Vérifier la connexion Internet
  Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResults =
        await Connectivity().checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  Future<List<Country>> getCountries() async {
    if (!await hasInternetConnection()) {
      throw Exception('Aucune connexion internet');
    }

    // ✅ On ajoute capital et flags dans les champs demandés
    const String url =
        "https://restcountries.com/v3.1/all?fields=name,capital,flags,translations";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
      },
    );

    print("CODE: ${response.statusCode}");
    if (response.statusCode == 200) {
      String decodedResponse = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(decodedResponse);
      return data.map((countryData) {
        var country = Country.fromJson(countryData);

        // ✅ Nom en français si disponible
        country.name =
            countryData['translations']['fra']['common'] ?? country.name;

        return country;
      }).toList();
    } else {
      print("BODY: ${response.body}");
      throw Exception(
          'Erreur lors du chargement des pays (code ${response.statusCode})');
    }
  }
}

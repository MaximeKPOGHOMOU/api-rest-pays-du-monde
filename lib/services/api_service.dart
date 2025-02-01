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
    } else {
      const String url = "https://restcountries.com/v3.1/all";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Décoder explicitement en UTF-8
        String decodedResponse = utf8.decode(response.bodyBytes);

        // Convertir le JSON décodé en objet Dart
        List<dynamic> data = jsonDecode(decodedResponse);
        return data.map((countryData) {
          var country = Country.fromJson(countryData);
          // Récupérer le nom du pays en français
          country.name =
              countryData['translations']['fra']['common'] ?? country.name;
          return country;
        }).toList();
      } else {
        throw Exception('Erreur lors du chargement des pays');
      }
    }
  }
}

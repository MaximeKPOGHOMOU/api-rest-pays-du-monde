class Country {
  String name;
  String capital;
  String flagUrl;

  Country({required this.name, required this.capital, required this.flagUrl});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'], // Accéder au nom courant
      capital: json['capital'] != null && json['capital'].isNotEmpty
          ? json['capital'][0] // Prendre la première capitale dans la liste
          : 'Non disponible',
      flagUrl: json['flags'] != null ? json['flags']['png'] ?? '' : '',
    );
  }
}

class Consumidores {
  int? idlugar;
  String? consumidor;

  Consumidores({this.idlugar, this.consumidor});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() =>
      {"idlugar": idlugar, "consumidor": consumidor};

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Consumidores.fromMap(Map<String, dynamic> json) =>
      Consumidores(idlugar: json["idlugar"], consumidor: json["consumidor"]);
}

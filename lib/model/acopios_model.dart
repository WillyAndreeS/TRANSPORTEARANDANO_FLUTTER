class Acopios {
  int? idviaje;
  String? alias;
  String? latitud;
  String? longitud;
  int? cantidadjabas;
  String? descripcion;
  int? idlugar;

  Acopios({ this.idviaje,this.alias, this.latitud, this.longitud, this.cantidadjabas, this.descripcion, this.idlugar});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() =>
      {"idviaje": idviaje,"alias": alias, "latitud": latitud, "longitud": longitud, "cantidadjabas": cantidadjabas, "descripcion" : descripcion, "idlugar": idlugar};

  //to receive the data we need to pas<ss it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Acopios.fromMap(Map<String, dynamic> json) => Acopios(
      idviaje: json["idviaje"] ,alias: json["alias"], latitud: json["latitud"], longitud: json["longitud"], cantidadjabas: json["cantidadjabas"], descripcion: json["descripcion"], idlugar: json["idlugar"]);
}

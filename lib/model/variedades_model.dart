class Variedades {
  String? idconsumidor;
  String? descripcion;

  Variedades({this.idconsumidor, this.descripcion});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() =>
      {"idconsumidor": idconsumidor, "descripcion": descripcion};

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Variedades.fromMap(Map<String, dynamic> json) => Variedades(
      idconsumidor: json["idconsumidor"], descripcion: json["descripcion"]);
}

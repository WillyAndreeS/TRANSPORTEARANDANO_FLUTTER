class Jabas {
  int? idviaje;
  String? lat;
  String? long;
  String? alias;
  int? nacional;
  int? exportable;
  int? desmedro;
  String? variedad;
  String? condicion;
  String? consumidor;
  String? valvula;
  String? observaciones;
  int? estado;
  int? jabascargadas;
  String? descripcion;
  int? frutac;
  String? fllegada;

  Jabas(
      {this.idviaje,
      this.lat,
      this.long,
      this.alias,
      this.nacional,
      this.exportable,
      this.desmedro,
      this.variedad,
      this.condicion,
      this.consumidor,
      this.valvula,
      this.observaciones,
      this.estado,
      this.jabascargadas,
      this.descripcion,
        this.frutac,
      this.fllegada});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
        "idviaje": idviaje,
        "lat": lat,
        "long": long,
        "alias": alias,
        "nacional": nacional,
        "exportable": exportable,
        "desmedro": desmedro,
        "variedad": variedad,
        "condicion": condicion,
        "consumidor": consumidor,
        "valvula": valvula,
        "observaciones": observaciones,
        "estado": estado,
        "jabascargadas": jabascargadas,
        "descripcion": descripcion,
        "frutac": frutac,
        "fllegada": fllegada
      };

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Jabas.fromMap(Map<String, dynamic> json) => Jabas(
      idviaje: json["idviaje"],
      lat: json["lat"],
      long: json["long"],
      alias: json["alias"],
      nacional: json["nacional"],
      exportable: json["exportable"],
      desmedro: json["desmedro"],
      variedad: json["variedad"],
      condicion: json["condicion"],
      consumidor: json["consumidor"],
      valvula: json["valvula"],
      observaciones: json["observaciones"],
      estado: json["estado"],
      jabascargadas: json["jabascargadas"],
      descripcion: json["descripcion"],
      frutac: json["frutac"],
      fllegada: json["fllegada"]);
}

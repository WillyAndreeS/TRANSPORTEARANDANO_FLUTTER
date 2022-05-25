class Intro {
  int? id;
  int? estado;

  Intro({this.id, this.estado});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {"id": id, "estado": estado};
  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory Intro.fromMap(Map<String, dynamic> json) =>
      Intro(id: json["id"], estado: json["estado"]);
}

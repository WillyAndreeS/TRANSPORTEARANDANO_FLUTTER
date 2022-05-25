class User {
  int? id;
  String? name;
  int? capacidad;
  String? dni;
  String? placa;

  User({this.id, this.name, this.capacidad, this.dni, this.placa});

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "capacidad": capacidad,
        "dni": dni,
        "placa": placa
      };

  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory User.fromMap(Map<String, dynamic> json) => User(
      id: json["id"],
      name: json["name"],
      capacidad: json["capacidad"],
      dni: json["dni"],
      placa: json["placa"]);
}

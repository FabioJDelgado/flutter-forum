class Publicacao{

  String texto;
  String uidUsuario;
  DateTime data;

  Publicacao({
    required this.texto,
    required this.uidUsuario,
    required this.data,
  });

  factory Publicacao.fromJson(Map<String, dynamic> json) {
    return Publicacao(
      texto: json['texto'],
      uidUsuario: json['uidUsuario'],
      data: json['data'].toDate(),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'texto': texto,
      'uidUsuario': uidUsuario,
      'data': data,
    };
  }

}
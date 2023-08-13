class Usuario {
  
  String uid;
  String nome;
  String email;
  String imagem;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.imagem,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'],
      nome: json['nome'],
      email: json['email'],
      imagem: json['imagem'],
    );
  } 

  Map<String, dynamic> toJson(){
    return {
      'nome': nome,
      'email': email,
      'imagem': imagem,
    };
  }
}
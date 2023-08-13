import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/services/usuario_service.dart';

class ComentarioException implements Exception {
  String message;
  ComentarioException(this.message);
}

class ComentarioService extends ChangeNotifier {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UsuarioService usuarioService = UsuarioService();

  Future<List> buscarTodosPublicacao(String uidPublicacao) async{
    QuerySnapshot querySnapshot;
    List docs = [];
    try {
      querySnapshot =
          await _db.collection('comentarios').where("uidPublicacao", isEqualTo: uidPublicacao).orderBy("data", descending: true).get();
      if(querySnapshot.docs.isNotEmpty) {
        for(var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "texto": doc['texto'],
            "data": doc["data"].toDate(),
            "uidPublicacao": doc["uidPublicacao"],
            "uidUsuario": doc["uidUsuario"],
            "usuarioComentario": await usuarioService.buscarUsuario(doc["uidUsuario"]),
          };
          docs.add(a);
        }
      }
    } on FirebaseException {
      throw ComentarioException('Erro ao listar as comentários');
    }
    return docs;
  }

  Future<Map> salvar(String uidUsuario, String uidPublicacao, String texto) async{
    try{
      Map<String, Object> comentario = {
        "texto": texto,
        "data": DateTime.now(),
        "uidPublicacao": uidPublicacao,
        "uidUsuario": uidUsuario
      };

      DocumentReference<Map<String, dynamic>> docRef = await _db.collection('comentarios').add(comentario);
      comentario["id"] = docRef.id;

      comentario["usuarioComentario"] = (await usuarioService.buscarUsuario(uidUsuario)) as Object;

      return comentario;
    } on FirebaseException {
      throw ComentarioException('Erro ao salvar comentário');
    }
  }

  remover(String idComentario) async{
    try{
      await _db.collection('comentarios').doc(idComentario).delete();
    } on FirebaseException {
      throw ComentarioException('Erro ao remover comentário');
    }
  }

  removerTodosPublicacao(String idPublicacao) async{
    try{
      QuerySnapshot querySnapshot = await _db.collection('comentarios').where('uidPublicacao', isEqualTo: idPublicacao).get();
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }
    } on FirebaseException {
      throw ComentarioException('Erro ao remover comentários da publicação $idPublicacao');
    }
  }

  Future<String> atualizar(String idComentario, String texto) async{
    try{
      await _db.collection('comentarios').doc(idComentario).update({"texto": texto, "data": DateTime.now()});
      return texto;
    } on FirebaseException {
      throw ComentarioException('Erro ao atualizar comentário');
    }
  }
}
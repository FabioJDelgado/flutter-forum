import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/models/publicacao.dart';
import 'package:flutter_atividade_a2/services/comentario_service.dart';
import 'package:flutter_atividade_a2/services/usuario_service.dart';

class PublicaoException implements Exception {
  String message;
  PublicaoException(this.message);
}

class PublicacaoService extends ChangeNotifier {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UsuarioService usuarioService = UsuarioService();
  final ComentarioService comentarioService = ComentarioService();

  salvar(Publicacao publicacao) async{
    try{
      final pub = publicacao.toJson();
      await _db.collection('publicacoes').add(pub);
      
    } on FirebaseException {
      throw PublicaoException('Erro ao salvar publicação');
    }
  }

  Future<List> buscarTodos() async{
    QuerySnapshot querySnapshot;
    List docs = [];
    try {
      querySnapshot =
          await _db.collection('publicacoes').orderBy("data", descending: true).get();
      if(querySnapshot.docs.isNotEmpty) {
        for(var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            "texto": doc['texto'],
            "data": doc["data"].toDate(),
            "uidUsuario": doc["uidUsuario"],
            "usuario": await usuarioService.buscarUsuario(doc["uidUsuario"]),
            "comentarios": await comentarioService.buscarTodosPublicacao(doc.id)
          };
          docs.add(a);
        }
      }
    } on FirebaseException {
      throw PublicaoException('Erro ao listar as publicações');
    }
    return docs;
  }

  Future<String> editarPublicacao(String idPublicacao, String texto) async{
    try{
      await _db.collection('publicacoes').doc(idPublicacao).update({'texto': texto, "data": DateTime.now()});
      return texto;
    } on FirebaseException {
      throw PublicaoException('Erro ao editar publicação');
    }
  }

  excluirPublicacao(String idPublicacao) async{
    try{
      await _db.collection('publicacoes').doc(idPublicacao).delete();
      await comentarioService.removerTodosPublicacao(idPublicacao);
    } on FirebaseException {
      throw PublicaoException('Erro ao excluir publicação');
    }
  }
}
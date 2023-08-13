import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/models/usuario.dart';

class UsuarioException implements Exception {
  String message;
  UsuarioException(this.message);
}

class UsuarioService extends ChangeNotifier{
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> atualizarUsuario(Usuario usuario, String senha) async{
    try {
      
      User? user = _auth.currentUser;
      if(senha.isNotEmpty && senha.length > 5){
        await user?.updatePassword(senha);
      }

      String uid = user!.uid;
      String urlImagem = '';
      if(usuario.imagem.isNotEmpty){
        File file = File(usuario.imagem);
        Reference ref = _storage.ref().child('imagens').child('usuarios').child('$uid-perfil.jpg');
        await ref.putFile(file);
        urlImagem = await ref.getDownloadURL();
      } else{
        bool existeImagem = await verificarExistenciaImagem('/imagens/usuarios/$uid-perfil.jpg');
        if(existeImagem){
          Reference storageReference = _storage.ref().child('/imagens/usuarios/$uid-perfil.jpg');
          await storageReference.delete();
        }
      }

      Map<String, dynamic> data = usuario.toJson();
      data['imagem'] = urlImagem;
      await _db.collection('usuarios').doc(usuario.uid).update(data);

    } on FirebaseException {
      throw UsuarioException('Erro ao atualizar usuário');
    }
  }

  Future<Usuario?> buscarUsuario(String uid) async{
    DocumentSnapshot documentSnapshot;
    Usuario? usuario;
    try {
      documentSnapshot = await _db.collection('usuarios').doc(uid).get();
      if(documentSnapshot.exists){
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        usuario = Usuario(uid: documentSnapshot.id, nome: data['nome'], email: data['email'], imagem: data['imagem']);
      }
    } on FirebaseException {
      throw UsuarioException('Erro ao buscar usuário');
    }
    return usuario;
  }

  
  Future<bool> verificarExistenciaImagem(String caminhoImagem) async {
    try {
      Reference storageReference = _storage.ref().child(caminhoImagem);
      await storageReference.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }
}
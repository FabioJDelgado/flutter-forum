import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }
  
  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  registrar(String email, String senha, String nome, String path) async{
    try{
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      String uid = _auth.currentUser!.uid;

      String urlImagem = '';
      if(path != ''){
        File file = File(path);
        Reference ref = _storage.ref().child('imagens').child('usuarios').child('$uid-perfil.jpg');
        await ref.putFile(file);
        urlImagem = await ref.getDownloadURL();
      }
      
      await _db.collection('usuarios').doc(_auth.currentUser!.uid).set({
        'nome': nome,
        'email': email,
        'imagem': urlImagem,
      });

      _getUser();
    } on FirebaseAuthException catch(e) {
      if(e.code == 'weak-password'){
        throw AuthException('Senha muito fraca!');
      } else if(e.code == 'email-already-in-use'){
        throw AuthException('Email já cadastrado');
      }
    }
  }

  login(String email, String senha) async{
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found'){
        throw AuthException('Seu login ou senha estão incorretos!');
      } else if(e.code == 'wrong-password'){
        throw AuthException('Seu login ou senha estão incorretos!');
      }
    }
  }

  logout() async{
    await _auth.signOut();
    _getUser();
  }
}
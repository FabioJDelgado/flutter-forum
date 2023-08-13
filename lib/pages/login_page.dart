import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseStorage storage = FirebaseStorage.instance;

  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  XFile? imagemArq;
  File? imagemExibir;

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool acao){
    setState(() {
      isLogin = acao;
      if (isLogin) {
        titulo = 'Bem vindo';
        actionButton = 'Login';
        toggleButton = 'Ainda não tem conta? Cadastre-se agora.';
        imagemArq = null;
        imagemExibir = null;
      } else {
        titulo = 'Crie sua conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Voltar ao Login.';
      }
    });
  }

  login() async{
    try{
      await context.read<AuthService>().login(email.text, senha.text);
    } on AuthException catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  registrar() async{
    try{
      await context.read<AuthService>().registrar(email.text, senha.text, nome.text, (imagemArq != null ? imagemArq!.path : ''));
    } on AuthException catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<XFile?> getImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    return imagem;
  }

  selecionarImagem() async {
    imagemArq = await getImage();
    if(imagemArq != null){
      setState(() {
        imagemExibir = File(imagemArq!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5,
                  ),
                ),
                if(!isLogin)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24.0),
                    child: TextFormField(
                      controller: nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome e Sobrenome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Informe seu nome e sobrenome';
                        }
                        return null;
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  child: TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe o email corretamente';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  child: TextFormField(
                    controller: senha,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe sua senha';
                      } else if(value.length < 6){
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                if(!isLogin)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            selecionarImagem();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.upload_file), 
                              SizedBox(width: 10), 
                              Text('Fazer Upload da Foto de Perfil'), 
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (imagemExibir != null) 
                          Image.file(
                          imagemExibir!, 
                          width: 100,   
                          height: 100,   
                          fit: BoxFit.cover, 
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if(isLogin){
                          login();
                        } else{
                          registrar();
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            actionButton,
                            style: const TextStyle(fontSize: 20)
                          ),
                        ),
                      ],
                    ),                    
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setFormAction(!isLogin);
                  },
                  child: Text(
                    toggleButton,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
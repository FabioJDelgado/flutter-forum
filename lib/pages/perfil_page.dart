import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/models/usuario.dart';
import 'package:flutter_atividade_a2/services/usuario_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

bool semImagem = false;

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  late FirebaseAuth auth;
  Usuario? usuario;

  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  late String imagemPerfil = "";
  XFile? imagemArq;
  File? imagemExibir;

  carregarDados() async {
    auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    Usuario? fetchedUsuario = await context.read<UsuarioService>().buscarUsuario(uid);
    setState(() {
      usuario = fetchedUsuario;
    });
    associar();
  }

  associar(){
    nome.text = usuario!.nome;
    email.text = usuario!.email;
    senha.text = '';
    if(usuario!.imagem != ''){
      imagemPerfil = usuario!.imagem;
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
        imagemPerfil = '';
        imagemExibir = File(imagemArq!.path);
      });
    }
  }

  atualizarUsuario() async {
    try{
      String imagemSalvar = "";
      if(semImagem){
        imagemSalvar = "";
      } else if(imagemPerfil == "" && imagemExibir == null){
        imagemSalvar = "";
      } else if(imagemPerfil != "" && imagemExibir == null){
        imagemSalvar = imagemPerfil;
      } else if(imagemPerfil == "" && imagemExibir != null){
        imagemSalvar = imagemExibir!.path;
      }
      Usuario usu = Usuario(uid: usuario!.uid, nome: nome.text, email: usuario!.email, imagem: imagemSalvar);
      await context.read<UsuarioService>().atualizarUsuario(usu, senha.text);

      sucessoEdicao();

      carregarDados();

    } on UsuarioException catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  sucessoEdicao(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição realizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, right: 24.0, left: 24.0, bottom: 24.0),
                  child: Column(
                    children: [
                      if (imagemPerfil != '') 
                        Image.network(
                          imagemPerfil, 
                          width: 150,    
                          height: 150,   
                          fit: BoxFit.cover,
                        )
                      else if (imagemExibir != null)
                        Image.file(
                          imagemExibir!, 
                          width: 150,    
                          height: 150,   
                          fit: BoxFit.cover,
                        )
                      else 
                        Image.asset(
                          'assets/imagens/sem-perfil.jpg',
                          width: 150,
                          height: 150,
                        ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              selecionarImagem();
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.upload_file), 
                                SizedBox(width: 10),
                                Text('Trocar Foto de Perfil'),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: semImagem,
                            onChanged: (bool? value) {
                              setState(() {
                                semImagem = value!;
                              });
                            },
                          ),
                          const Text('Sem Foto de Perfil'),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24.0),
                  child: TextFormField(
                    controller: nome,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe seu nome';
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
                    enabled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  child: TextFormField(
                    controller: senha,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Digite uma nova senha caso queira trocar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        atualizarUsuario();
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Atualizar",
                            style: TextStyle(fontSize: 20)
                          ),
                        ),
                      ],
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
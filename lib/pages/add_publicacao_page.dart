import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/models/publicacao.dart';
import 'package:flutter_atividade_a2/services/publicacao_service.dart';
import 'package:provider/provider.dart';

class AddPublicacaoPage extends StatefulWidget {
  const AddPublicacaoPage({super.key});

  @override
  State<AddPublicacaoPage> createState() => _AddPublicacaoPageState();
}

class _AddPublicacaoPageState extends State<AddPublicacaoPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController pub;

  @override
  void initState() {
    super.initState();
    pub = TextEditingController();
  }

  publicar() async {
    if(pub.text.isNotEmpty){
      Publicacao publicacao = Publicacao(texto: pub.text, uidUsuario: _auth.currentUser!.uid, data: DateTime.now());
      await context.read<PublicacaoService>().salvar(publicacao);

      sucessoPublicacao();

      pub.clear();
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  sucessoPublicacao(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Publicação realizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: pub,
                maxLines: null, // Permite múltiplas linhas de texto
                keyboardType: TextInputType.multiline, // Define o teclado como multiline
                maxLength: 700, // Limite de caracteres
                decoration: const InputDecoration(
                  hintText: 'Digite aqui sua publicação...',
                ),
              ),
              const SizedBox(height: 16), // Espaçamento entre o TextField e o botão
              ElevatedButton(
                onPressed: () {
                  publicar();
                },
                child: const Text(
                  "Publicar",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/db/firebase_options.dart';
import 'package:flutter_atividade_a2/services/auth_service.dart';
import 'package:flutter_atividade_a2/services/comentario_service.dart';
import 'package:flutter_atividade_a2/services/publicacao_service.dart';
import 'package:flutter_atividade_a2/services/usuario_service.dart';
import 'package:provider/provider.dart';
import 'meu_aplicativo.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => PublicacaoService()),
        ChangeNotifierProvider(create: (context) => UsuarioService()),
        ChangeNotifierProvider(create: (context) => ComentarioService())
      ],
      child: const MeuAplicativo(),
    ),
  );
}
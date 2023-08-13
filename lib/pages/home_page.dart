import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/pages/add_publicacao_page.dart';
import 'package:flutter_atividade_a2/pages/perfil_page.dart';
import 'package:flutter_atividade_a2/pages/publicacoes_page.dart';
import 'package:flutter_atividade_a2/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PublicacoesPage(),
    const AddPublicacaoPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Matemática Esperta'),
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center, // Alinhe verticalmente ao centro
              children: [
                TextButton(
                  onPressed: () {
                    context.read<AuthService>().logout();
                  },
                  child: const Text("Sair", style: TextStyle(color: Colors.white)), // Estilize como um link
                ),
              ],
            ),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.blue,
          fixedColor: Colors.white,
          unselectedItemColor: Colors.black,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Publicações'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: 'Adicionar Publicação'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil'
            ),
          ],
        ),
      ),
    );
  }
}
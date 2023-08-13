import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atividade_a2/services/comentario_service.dart';
import 'package:flutter_atividade_a2/services/publicacao_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PublicacoesPage extends StatefulWidget {
  const PublicacoesPage({super.key});

  @override
  State<PublicacoesPage> createState() => _PublicacoesPageState();
}

class _PublicacoesPageState extends State<PublicacoesPage> {

  late FirebaseAuth auth;
  String? uidUsuarioAtual;
  List publicacoes = [];

  final textoPubli = TextEditingController();
  String textoPubliNovo = "";
  bool editando = false;
  int indexEditando = 0;

  List<TextEditingController> comentarioControllers = [];
  String uidPublicacaoComentario = "";
  int indexEditandoComentario = -1;
  String acaoComentario = "novo";
  String acaoCancelamentoEdicaoCriacao = "cancelarNovo";

  initialise(){
    auth = FirebaseAuth.instance;
    uidUsuarioAtual = auth.currentUser!.uid;
    context.read<PublicacaoService>().buscarTodos().then((value) => 
      setState(() {
        publicacoes = value;
      })
    );
  }

  String formataData(DateTime data){
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
  }

  editarPublicacao(String textoPublicacao, int index){
    setState(() {
      editando = true;
    });
    textoPubli.text = textoPublicacao;
    textoPubliNovo = textoPublicacao;
    indexEditando = index;
  }

  confirmaEdicao(String idPublicacao, int index, BuildContext context){
    context.read<PublicacaoService>().editarPublicacao(idPublicacao, textoPubliNovo).then((value) => 
      setState(() {
        publicacoes[index]['texto'] = value;
      })
    );
    fimEdicao(context);
    sucessoEdicao();
    tirarFocus(context);
  }

  fimEdicao(BuildContext context){
    setState(() {
      editando = false;
    });
    textoPubli.text = "";
    textoPubliNovo = "";
    indexEditando = 0;
    tirarFocus(context);
  }

  sucessoEdicao(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição realizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  excluirPublicacao(String idPublicacao, int index, BuildContext context){
    context.read<PublicacaoService>().excluirPublicacao(idPublicacao).then((value) => 
      setState(() {
        publicacoes.removeAt(index);
      })
    );

    sucessoExclusao();
    tirarFocus(context);
  }

  sucessoExclusao(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exclusão realizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  gerirComentarios(String idPublicacao, int indexPublicacao, String acao, BuildContext context){
    if(acao == "novo"){
      confirmarCriarNovoComentario(idPublicacao, indexPublicacao, context);
    } else{
      confirmarEditarComentario(idPublicacao, indexPublicacao, context);
    }
  }

  confirmarCriarNovoComentario(String idPublicacao, int indexPublicacao, BuildContext context){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Adicionar Comentário"),
          content: const Text("Tem certeza que deseja adicionar este comentário?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                limparEdicaoComentario(indexPublicacao, context);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Adicionar"),
              onPressed: () {
                criarNovoComentario(idPublicacao, indexPublicacao, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  confirmarEditarComentario(String idPublicacao, int indexPublicacao, BuildContext context){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Comentário"),
          content: const Text("Tem certeza que deseja editar este comentário?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                limparEdicaoComentario(indexPublicacao, context);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Editar"),
              onPressed: () {
                salvarEditarComentario(indexPublicacao, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  criarNovoComentario(String idPublicacao, int indexPublicacao, BuildContext context){
    context.read<ComentarioService>().salvar(uidUsuarioAtual!, idPublicacao, comentarioControllers[indexPublicacao].text).then((value) => 
      setState(() {       
        publicacoes[indexPublicacao]['comentarios'].insert(0, value);
      })
    );
    limparEdicaoComentario(indexPublicacao, context);
    sucessoComentario();
    tirarFocus(context);
  }

  salvarEditarComentario(int indexPublicacao, BuildContext context){
    int indexComentarioEditado = indexEditandoComentario;
    context.read<ComentarioService>().atualizar(uidPublicacaoComentario, comentarioControllers[indexPublicacao].text).then((value) => 
      setState(() {       
        publicacoes[indexPublicacao]['comentarios'][indexComentarioEditado]['texto'] = value;
      })
    );
    limparEdicaoComentario(indexPublicacao, context);
    sucessoComentario();
    tirarFocus(context);
  }

  editarComentario(uidComentario, textoEditar, int index, int index2) {
    comentarioControllers[index].text = textoEditar;
    uidPublicacaoComentario = uidComentario;
    indexEditandoComentario = index2;
    acaoComentario = "editar";
  }

  limparEdicaoComentario(int indexPublicacao, BuildContext context){
    comentarioControllers[indexPublicacao].text = "";
    uidPublicacaoComentario = "";
    indexEditandoComentario = -1;
    acaoComentario = "novo";
    tirarFocus(context);
  }

  sucessoComentario(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comentário realizado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  excluirComentario(String idComentario, int indexPublicacao, int indexComentario, BuildContext context){
    context.read<ComentarioService>().remover(idComentario).then((value) => 
      setState(() {
        publicacoes[indexPublicacao]['comentarios'].removeAt(indexComentario);
      })
    );
    sucessoExclusaoComentario();
    tirarFocus(context);
  }

  sucessoExclusaoComentario(){
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comentário excluido com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  tirarFocus(BuildContext context){
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  @override
  Widget build(BuildContext context) {

    comentarioControllers = List.generate(publicacoes.length,(_) => TextEditingController());

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: publicacoes.length,
        itemBuilder: (BuildContext context, int index){
          return Card(
            margin: const EdgeInsets.only(bottom: 10, left: 10,right: 10, top: 20),
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: publicacoes[index]['usuario'].imagem != ''
                            ? Image.network(
                                publicacoes[index]['usuario'].imagem,
                                width: 60,
                                height: 60,
                              )
                            : Image.asset(
                                'assets/imagens/sem-perfil.jpg',
                                width: 60,
                                height: 60,
                              ),
                        ),
                        Text(
                          publicacoes[index]['usuario'].nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 31, 30, 30)
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          formataData(publicacoes[index]['data']),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if(publicacoes[index]['usuario'].uid == uidUsuarioAtual)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: editando && indexEditando == index ? const Icon(Icons.check) : const Icon(Icons.edit),
                              onPressed: () {
                                if(editando && indexEditando == index){
                                  if(textoPubliNovo.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Informe o texto da publicação!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Editar Publicação"),
                                          content: const Text("Tem certeza que deseja editar esta publicação?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancelar"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Editar"),
                                              onPressed: () {
                                                confirmaEdicao(publicacoes[index]['id'], index, context);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else{
                                  editarPublicacao(publicacoes[index]['texto'], index);
                                }
                              },
                            ),
                            if(editando && indexEditando == index)
                              IconButton(
                                icon:const Icon(Icons.cancel),
                                onPressed: () {
                                  fimEdicao(context);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Excluir Publicação"),
                                      content: const Text("Tem certeza que deseja excluir esta publicação?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancelar"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Excluir"),
                                          onPressed: () {
                                            excluirPublicacao(publicacoes[index]['id'], index, context);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              subtitle: Column( 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                    child: (editando && indexEditando == index) 
                    ?
                      TextField(
                        controller: textoPubli,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: AutofillHints.countryName,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                        onChanged: (newValue) {
                          textoPubliNovo = newValue;
                        },
                      )
                    : 
                      Text(
                        publicacoes[index]['texto'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: AutofillHints.countryName,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: comentarioControllers[index],
                            decoration: const InputDecoration(
                              hintText: 'Digite seu comentário...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              limparEdicaoComentario(index, context);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            gerirComentarios(publicacoes[index]['id'], index, acaoComentario, context);
                          },
                        ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Exibir Comentários',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 31, 30, 30)
                      ),
                    ),
                    children: [
                      if(publicacoes[index]["comentarios"].length == 0)
                        const Column(
                          children:[
                            Text("Essa publicação não possui comentários"),
                            SizedBox(height: 10)
                          ]
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: publicacoes[index]["comentarios"].length,
                          itemBuilder: (BuildContext context, int index2){
                            return ListTile(
                              contentPadding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30.0),
                                        child: publicacoes[index]['comentarios'][index2]["usuarioComentario"].imagem != ''
                                          ? Image.network(
                                              publicacoes[index]['comentarios'][index2]["usuarioComentario"].imagem,
                                              width: 40,
                                              height: 40,
                                            )
                                          : Image.asset(
                                              'assets/imagens/sem-perfil.jpg',
                                              width: 40,
                                              height: 40,
                                            ),
                                      ),
                                      Text(
                                        publicacoes[index]["comentarios"][index2]["usuarioComentario"].nome,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 31, 30, 30)
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formataData(publicacoes[index]["comentarios"][index2]['data']),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ]
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    publicacoes[index]["comentarios"][index2]["texto"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: AutofillHints.countryName,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  if(publicacoes[index]["comentarios"][index2]["usuarioComentario"].uid == uidUsuarioAtual)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: (){
                                            editarComentario(publicacoes[index]["comentarios"][index2]["id"], publicacoes[index]["comentarios"][index2]["texto"], index, index2);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Excluir Comentário"),
                                                  content: const Text("Tem certeza que deseja excluir este comentário?"),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text("Cancelar"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text("Excluir"),
                                                      onPressed: () {
                                                        excluirComentario(publicacoes[index]["comentarios"][index2]["id"], index, index2, context);
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                ]
                              )
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )
    );
  }  
}
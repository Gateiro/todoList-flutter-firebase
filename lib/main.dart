import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

//1. Ponto de entrada dos aplicativos flutter
Future<void> main() async {
  //Garante que o flutter esteja inicializado antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();
  //Inicializa o Firebase com as configs da plataforma (firebase_options.dart)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //Inicializa no widget principal.
  runApp(const MyApp());
}

//1. Raiz da Aplicação.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Desativa o banner de 'Debug'
      title: 'Sanrio ToDo List',
      theme: ThemeData(
        //DEFINIR TEMA PADRÃO DO APP.
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // ------------------------ Tela principal ----------------------------------------
      home: const TodoListScreen(),
    );
  }
}

//---------------- TodoListScreen - Tela Principal, exibirá a lista de tarefas. ------------------------------
//---------------- StatefulWidget - Lista de tarefas com estados variáveis. ----------------------------------
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // ------ Seção Coleção de Tarefas no Firestore ----------------
  final CollectionReference _taskCollection = FirebaseFirestore.instance
      .collection('tarefas');

  @override
  Widget build(BuildContext context) {
    //Scaffold nos dá a estrutura visual básica da página (app bar, body, etc)
    return Scaffold(
      appBar: AppBar(
        //O título que aparecerá na barra superior.
        title: const Text('Sanrio - Minhas Tarefas'),
        centerTitle: true,
      ),
      //--------------- Corpo do aplicativo -------------------------------------
      body: StreamBuilder(
        stream: _taskCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //Loading de carregamento de dados.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mensagem de erro para algum erro de conexão --
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro!'));
          }

          // Se os dados chegarem mas a lista estiver vazia
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma tarefa ainda! Adicione uma no botão +',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          //Construir a lista com os dados encontrados
          return ListView.builder(
            // A quantidade de itens na lista será o número de documentos que recebemos.
            itemCount: snapshot.data!.docs.length,
            // Como construir cada item da lsita.
            itemBuilder: (context, index) {
              // Pegar o doc (tarefa atual).
              final DocumentSnapshot documentSnapshot =
                  snapshot.data!.docs[index];

              // ListTile é um widget pronto, ótimo para exibir uma  linha em uma lista.
              return ListTile(
                // O título do ListTile será o valor do campo 'titulo' do nosso doc
                title: Text(documentSnapshot['titulo']),
              );
            },
          );
        },
      ),

      // -------- Botão flutuante - Adicionar tarefas -------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ----- Ação - Adicionar nova tarefa ------------------------------------
        },
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}

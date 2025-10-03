import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      body: const Center(
        child: Text('Nenhuma tarefa ainda rs', style: TextStyle(fontSize: 18)),
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

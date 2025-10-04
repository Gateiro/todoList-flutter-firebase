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
      debugShowCheckedModeBanner: false,
      //Desativa o banner de 'Debug'
      title: 'Sanrio ToDo List',
      theme: ThemeData(
        // ---- Cor principal -----
        primaryColor: const Color(0xFFF9A8D4),
        // ---  Cor de fundo --------
        scaffoldBackgroundColor: const Color(0xFFFDF2F8),
        // --- Config para o AppBar ------
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9A8D4),
          foregroundColor: Color(0xFF831843),
          elevation: 0,
        ),
        // --- Config para o floating action button ---
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFEC4899),
          foregroundColor: Colors.white,
        ),
        // --- Estilo dos botões elevados ----
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEC4899),
            foregroundColor: Colors.white,
          ),
        ),
        // --- Tema dos checkboxes ---------
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFEC4899);
            }
            return null;
          }),
        ),

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

  // --- Controlador para o campo onde o usuário digita a tarefa ----
  final TextEditingController _taskTitleController = TextEditingController();

  // -- Método Async para ADICIONAR Tarefa -----
  Future<void> _addTask() async {
    final String title = _taskTitleController.text;
    //Verificação de campo vazio.
    if (title.isNotEmpty) {
      // Adiciona um novo documento à coleção 'tarefas'.
      // O FB cria um ID automático para o doc.
      await _taskCollection.add({'titulo': title, 'concluida': false});

      //Limpar o campo de texto após add tarefa ----------------
      _taskTitleController.clear();

      if (!mounted) return;
      //Fecha o painel inferior
      Navigator.of(context).pop();
    }
  }

  // -- Método para ATUALIZAR tarefa ---
  Future<void> _updateTask(String taskId, bool isCompleted) async {
    await _taskCollection.doc(taskId).update({'concluida': isCompleted});
  }

  // -- Método para DELETAR tarefa ---
  Future<void> _deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }

  // ---- Método: Construir e exibir painel de add tarefas
  void _showAddTaskPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar Nova Tarefa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Campo de texto para o titulo da tarefa.
              TextField(
                controller: _taskTitleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título da Tarefa',
                ),
              ),
              const SizedBox(height: 20),
              // BOtão para salvar tarefa
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                'Nenhuma tarefa ainda!\nAdicione uma no botão +',
                textAlign: TextAlign.center,
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
              final bool isCompleted = documentSnapshot['concluida'];

              // ListTile é um widget pronto exibir uma  linha em uma lista.
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: CheckboxListTile(
                  title: Text(
                    documentSnapshot['titulo'],
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  //O valor do checkbox é o do campo concluído!!!
                  value: isCompleted,
                  // Ao tocar o checkbox chamamos o método de atualização ------------
                  onChanged: (bool? value) {
                    if (value != null) {
                      _updateTask(documentSnapshot.id, value);
                    }
                  },
                  // Icone de lixeira
                  secondary: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteTask(documentSnapshot.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // -------- Botão flutuante - Adicionar tarefas -------------------------------
      floatingActionButton: FloatingActionButton(
        // ----- Ação - Chama o método do painel ------------------------------------
        onPressed: _showAddTaskPanel,
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}

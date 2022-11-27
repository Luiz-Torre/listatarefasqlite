import 'package:flutter/material.dart';
import 'package:listatarefasqlite/helper/AnnotationHelper.dart';
import 'package:listatarefasqlite/model/Annotation.dart';
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var _db = AnnotationHelper();
  List<Annotation> annotations = [];

  void _insertAnnotation() async {
    String title = titleController.text;
    String description = descriptionController.text;

    Annotation annotation =
        Annotation(title, description, DateTime.now().toString());

    int result = await _db.insertAnnotation(annotation);

    titleController.clear();
    descriptionController.clear();

    _getAnnotations();
  }

  void _insertUpdateAnnotation({Annotation? selectedAnnotation}) async {
    String title = titleController.text;
    String description = descriptionController.text;

    if (selectedAnnotation == null) {
      Annotation annotation =
          Annotation(title, description, DateTime.now().toString());

      int result = await _db.insertAnnotation(annotation);
    } else {
      selectedAnnotation.title = title;
      selectedAnnotation.description = description;
      selectedAnnotation.data = DateTime.now().toString();

      int result = await _db.updateAnnotation(selectedAnnotation);
    }

    titleController.clear();
    descriptionController.clear();

    _getAnnotations();
  }

  void _getAnnotations() async {
    List results = await _db.getAnnotations();
    annotations.clear();

    for (var item in results) {
      Annotation annotation = Annotation.fromMap(item);
      annotations.add(annotation);
    }

    setState(() {});
  }

  _removeAnnotation(int? id) async {
    await _db.deleteAnnotation(id!);

    _getAnnotations();
  }

  _formatData(String data) {
    initializeDateFormatting("pt_BR", "");

    var formatter = DateFormat.yMMMMd("pt_BR");

    DateTime newDate = DateTime.parse(data);
    return formatter.format(newDate);
  }

  void _showRegisterScreen({Annotation? annotation}) {
    String saveUpdateText = "";

    if (annotation == null) {
      titleController.text = "";
      descriptionController.text = "";
      saveUpdateText = "Salvar";
    } else {
      titleController.text = annotation.title!;
      descriptionController.text = annotation.description!;
      saveUpdateText = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(saveUpdateText),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "Título", hintText: "Digite o título"),
              ),
              TextField(
                controller: descriptionController,
                autofocus: true,
                decoration: InputDecoration(
                    labelText: "Descrição", hintText: "Digite a descrição"),
              )
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              TextButton(
                  onPressed: () {
                    //Salvar no Database
                    //_insertAnnotation();
                    _insertUpdateAnnotation(selectedAnnotation: annotation);
                    Navigator.pop(context);
                  },
                  child: Text(saveUpdateText))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getAnnotations();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controllerEditarTitulo = TextEditingController();
    TextEditingController _controllerEditarDescricao = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefa Notas SQLITE"),
        backgroundColor: Color.fromARGB(255, 36, 36, 42),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: annotations.length,
                  itemBuilder: (context, index) {
                    final item = annotations[index];

                    return Dismissible(
                      key: ValueKey(item),
                      child: ListTile(
                        title: Text(item.title!),
                        subtitle: Text("${item.description}"),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Tela de confirmação"),
                                content: const Text(
                                    "Tem certeza que deseja excluir?"),
                                actions: <Widget>[
                                  ElevatedButton(
                                      onPressed: () {
                                        _removeAnnotation(item.id);
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("Aceito Deletar")),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                            
                          _showRegisterScreen(annotation: item);
                          
                        }
                      },
                      secondaryBackground: Container(
                        color: Colors.red,
                        padding: EdgeInsets.all(16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                              )
                            ]),
                      ),
                      background: Container(
                        color: Colors.green,
                        padding: EdgeInsets.all(16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                              )
                            ]),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 36, 36, 42),
        foregroundColor: Color.fromARGB(255, 75, 74, 79),
        child: Icon(Icons.add),
        onPressed: () => _showRegisterScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notas_app/helper/AnnotationHelper.dart';
import 'package:notas_app/model/Annotation.dart';
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

  void _insertAnnotation() async{

    String title = titleController.text;
    String description = descriptionController.text;

    print("Data: ${DateTime.now().toString()}");

    Annotation annotation = Annotation(
      title, description, 
      DateTime.now().toString()
    );

    int result = await _db.insertAnnotation(annotation);
    print("Id: $result");

    titleController.clear();
    descriptionController.clear();

    _getAnnotations();
  }

  void _insertUpdateAnnotation({Annotation? selectedAnnotation}) async{

    String title = titleController.text;
    String description = descriptionController.text;

    print("Data: ${DateTime.now().toString()}");

    if (selectedAnnotation == null) {
      Annotation annotation = Annotation(
        title, description, 
        DateTime.now().toString()
      );

      int result = await _db.insertAnnotation(annotation);
      print("Id: $result");
    } else {
      selectedAnnotation.title = title;
      selectedAnnotation.description = description;
      selectedAnnotation.data = DateTime.now().toString();

      int result = await _db.updateAnnotation(selectedAnnotation);
      print("Id: $result");
    }

    titleController.clear();
    descriptionController.clear();

    _getAnnotations();
  }

  void _getAnnotations() async {
    List results = await _db.getAnnotations();
    //print("Lista: ${results.toString()}");
    annotations.clear();

    for (var item in results) {
      //print("${item.toString()}");
      Annotation annotation = Annotation.fromMap(item);
      annotations.add(annotation);
    }

    setState(() {
      
    });
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
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título"
                ),
              ),

              TextField(
                controller: descriptionController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição"
                ),
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Cancelar")
            ),
            TextButton(
              onPressed: () {

                //Salvar no Database
                //_insertAnnotation();
                _insertUpdateAnnotation(selectedAnnotation: annotation);
                Navigator.pop(context);
              }, 
              child: Text(saveUpdateText)
            )

          ],
        );
      }
    );

  }

  @override
  void initState() {
    super.initState();
    _getAnnotations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notas"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
           Expanded (
            child: ListView.builder(
                itemCount: annotations.length,
                itemBuilder: (context, index) {
                  final item = annotations[index];

                  return Card(
                    child: ListTile(
                      title: Text(item.title!),
                      subtitle: Text("${_formatData(item.data!)} - ${item.description}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showRegisterScreen(annotation: item);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _removeAnnotation(item.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              )
           )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),  
        onPressed: () => _showRegisterScreen(),
      ),
    );
  }
}
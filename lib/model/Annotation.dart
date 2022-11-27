class Annotation {
  int? id;
  String? title;
  String? description;
  String? data;

  Annotation(this.title, this.description, this.data);


  Annotation.fromMap(Map map) {
    this.id = map["id"];
    this.title = map["title"];
    this.description = map["description"];
    this.data = map["data"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "title": this.title,
      "description": this.description,
      "data": this.data
    };

    /*if (map["id"] != null) {
      map["id"] = this.id;
    }*/
    map["id"] ??= this.id;

    return map;
  }  
}
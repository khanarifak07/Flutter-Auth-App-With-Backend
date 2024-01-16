import 'dart:convert';

class TodoModel {
  String title;
  String? description;
  bool? complete;
  String? createdBy;
  String id;
  TodoModel({
    required this.title,
    this.id = '',
    this.description,
    this.complete,
    this.createdBy,
  });

  TodoModel copyWith(
      {String? title,
      String? description,
      bool? complete,
      String? createdBy,
      String? id}) {
    return TodoModel(
        title: title ?? this.title,
        description: description ?? this.description,
        complete: complete ?? this.complete,
        createdBy: createdBy ?? this.createdBy,
        id: id ?? this.id);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'complete': complete,
      'createdBy': createdBy,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      complete: map['complete'] as bool?,
      createdBy: map['createdBy'] as String?,
    );
  }


  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TodoModel(title: $title, description: $description, complete: $complete, createdBy: $createdBy)';
  }

  @override
  bool operator ==(covariant TodoModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.complete == complete &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        complete.hashCode ^
        createdBy.hashCode;
  }
}

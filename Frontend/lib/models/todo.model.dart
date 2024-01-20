// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TodoModel {
  String title;
  String? description;
  bool? complete;
  String? createdBy;
  String id;
  String? priority;
  TodoModel({
    required this.title,
    this.description,
    this.complete,
    this.createdBy,
    this.id = '',
    this.priority,
  });

  TodoModel copyWith({
    String? title,
    String? description,
    bool? complete,
    String? createdBy,
    String? id,
    String? priority,
  }) {
    return TodoModel(
      title: title ?? this.title,
      description: description ?? this.description,
      complete: complete ?? this.complete,
      createdBy: createdBy ?? this.createdBy,
      id: id ?? this.id,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'complete': complete,
      'createdBy': createdBy,
      'priority': priority,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      title: map['title'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      complete: map['complete'] != null ? map['complete'] as bool : null,
      createdBy: map['createdBy'] != null ? map['createdBy'] as String : null,
      id: map['_id'] as String,
      priority: map['priority'] != null ? map['priority'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TodoModel(title: $title, description: $description, complete: $complete, createdBy: $createdBy, priority: $priority)';
  }

  @override
  bool operator ==(covariant TodoModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.complete == complete &&
        other.createdBy == createdBy &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        complete.hashCode ^
        createdBy.hashCode ^
        priority.hashCode;
  }
}

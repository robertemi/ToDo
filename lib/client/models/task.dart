class Task {
  final int? id;
  String name;
  bool status;

  Task({this.id, required this.name, this.status = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      name: json['name'] as String,
      status: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name, 'is_done': status};
  }
}

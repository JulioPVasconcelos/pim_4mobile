class User {
  final String id;
  final String nome;
  final String email;
  final int nivel;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.nivel,
  });

  // Converter JSON da API para objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      nivel: json['nivel'] ?? json['nivel_usuario'] ?? 1,
    );
  }

  // Converter objeto User para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'nivel': nivel,
    };
  }

  // Verificar se é técnico
  bool get isTecnico => nivel >= 2;

  // Verificar se é admin
  bool get isAdmin => nivel >= 5;
}

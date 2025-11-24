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

  // AJUSTADO PARA A API SISTEC
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'].toString(),
      nome: json['nome_usuario'] ?? '',
      email: json['email'] ?? '',
      nivel: json['nivel_acesso'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': int.parse(id),
      'nome_usuario': nome,
      'email': email,
      'nivel_acesso': nivel,
    };
  }

  bool get isTecnico => nivel >= 2;
  bool get isAdmin => nivel >= 5;
}

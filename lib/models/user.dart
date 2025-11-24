class User {
  final int id;
  final String nome;
  final String email;
  final String? setor;
  final String? cargo;
  final int nivelAcesso;

  User({
    required this.id,
    required this.nome,
    required this.email,
    this.setor,
    this.cargo,
    required this.nivelAcesso,
  });

  // Getter para verificar se é técnico (Nível 2 ou superior)
  bool get isTecnico => nivelAcesso >= 2;

  factory User.fromJson(Map<String, dynamic> json) {
    int nivel = 1;
    
    if (json['perfil'] != null && json['perfil'] is Map) {
      nivel = json['perfil']['nivel_acesso'] ?? json['perfil']['id'] ?? 1;
    } else if (json['id_perfil_usuario'] != null) {
      nivel = json['id_perfil_usuario'];
    }

    return User(
      id: json['id'] ?? json['id_usuario'] ?? 0,
      nome: json['name'] ?? json['nome_usuario'] ?? 'Usuário',
      email: json['email'] ?? '',
      setor: json['setor'] ?? json['setor_usuario'],
      cargo: json['cargo'] ?? json['cargo_usuario'],
      nivelAcesso: nivel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'setor': setor,
      'cargo': cargo,
      'nivel_acesso': nivelAcesso,
    };
  }
}
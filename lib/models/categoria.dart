class Categoria {
  final String id;
  final String nome;

  Categoria({
    required this.id,
    required this.nome,
  });

  // Converter JSON da API para objeto Categoria
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'].toString(),
      nome: json['nome'] ?? json['name'] ?? '',
    );
  }

  // Converter objeto Categoria para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}

class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final String status;
  final String prioridade;
  final String categoria;
  final DateTime dataAbertura;
  final String? imagemUrl;
  final String usuarioNome;
  final String? tecnicoNome;

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.prioridade,
    required this.categoria,
    required this.dataAbertura,
    this.imagemUrl,
    required this.usuarioNome,
    this.tecnicoNome,
  });

  // Converter JSON da API para objeto Chamado
  factory Chamado.fromJson(Map<String, dynamic> json) {
    return Chamado(
      id: json['id'].toString(),
      titulo: json['titulo'] ?? json['title'] ?? '',
      descricao: json['descricao'] ?? json['description'] ?? '',
      status: json['status'] ?? 'Aberto',
      prioridade: json['prioridade'] ?? json['priority'] ?? 'Média',
      categoria: json['categoria'] ?? json['category'] ?? '',
      dataAbertura: DateTime.parse(json['data_abertura'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String()),
      imagemUrl: json['imagem_url'] ?? json['image_url'],
      usuarioNome: json['usuario_nome'] ?? json['user_name'] ?? 'Usuário',
      tecnicoNome: json['tecnico_nome'] ?? json['technician_name'],
    );
  }

  // Cores para o status
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'aberto':
        return 'blue';
      case 'em andamento':
        return 'orange';
      case 'aguardando':
        return 'yellow';
      case 'resolvido':
        return 'green';
      case 'fechado':
        return 'grey';
      default:
        return 'blue';
    }
  }

  // Cores para a prioridade
  String getPrioridadeColor() {
    switch (prioridade.toLowerCase()) {
      case 'baixa':
        return 'green';
      case 'média':
        return 'yellow';
      case 'alta':
        return 'orange';
      case 'urgente':
        return 'red';
      default:
        return 'grey';
    }
  }
}

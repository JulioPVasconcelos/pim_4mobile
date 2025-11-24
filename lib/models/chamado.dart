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

  // AJUSTADO PARA A API SISTEC
  factory Chamado.fromJson(Map<String, dynamic> json) {
    // Extrair título do campo descricao_detalhada se existir
    String titulo = json['titulo_chamado'] ?? 'Sem título';
    String descricao = json['descricao_detalhada'] ?? '';

    // Converter prioridade numérica para string
    String prioridade = _converterPrioridade(json['prioridade_chamado']);

    return Chamado(
      id: json['id_chamado'].toString(),
      titulo: titulo,
      descricao: descricao,
      status: json['descricao_status_chamado'] ?? 'Aberto',
      prioridade: prioridade,
      categoria: json['descricao_categoria_chamado'] ?? '',
      dataAbertura: DateTime.parse(
          json['data_abertura'] ?? DateTime.now().toIso8601String()),
      imagemUrl: null, // API não suporta imagem ainda
      usuarioNome: json['usuario_abertura'] ?? 'Usuário',
      tecnicoNome: json['usuario_resolucao'],
    );
  }

  static String _converterPrioridade(dynamic valor) {
    if (valor is String) return valor;

    switch (valor) {
      case 1:
        return 'Baixa';
      case 2:
        return 'Média';
      case 3:
        return 'Alta';
      case 4:
        return 'Urgente';
      default:
        return 'Média';
    }
  }

  // Resto do código igual...
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'aberto':
        return 'blue';
      case 'aprovado':
      case 'com analista':
        return 'orange';
      case 'aguardando resposta':
        return 'yellow';
      case 'resolvido':
        return 'green';
      case 'fechado':
        return 'grey';
      case 'rejeitado':
        return 'red';
      default:
        return 'blue';
    }
  }

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

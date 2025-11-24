class Chamado {
  final String id;
  final String tituloChamado;
  final String descricaoDetalhada;
  final String descricaoStatusChamado;
  final String prioridadeChamado;
  final String descricaoCategoria;
  final DateTime dataAbertura;
  final DateTime? dataFechamento;
  final String? imagemUrl;
  final String usuarioNome;
  final String? tecnicoNome;

  Chamado({
    required this.id,
    required this.tituloChamado,
    required this.descricaoDetalhada,
    required this.descricaoStatusChamado,
    required this.prioridadeChamado,
    required this.descricaoCategoria,
    required this.dataAbertura,
    this.dataFechamento,
    this.imagemUrl,
    required this.usuarioNome,
    this.tecnicoNome,
  });

  factory Chamado.fromJson(Map<String, dynamic> json) {
    // títulos e descrições possíveis na API
    String titulo = json['titulo_chamado'] ?? json['titulo'] ?? 'Sem título';
    String descricao = json['descricao_detalhada'] ?? json['descricao'] ?? '';
    String status = json['descricao_status_chamado'] ?? json['status'] ?? 'Aberto';
    String categoria = json['descricao_categoria_chamado'] ?? json['categoria'] ?? 'Geral';

    String id = json['id_chamado']?.toString() ?? json['id']?.toString() ?? '0';

    dynamic prioridadeRaw = json['prioridade_chamado'] ?? json['prioridade'];
    String prioridade = _converterPrioridade(prioridadeRaw);

    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return fallback;
      }
    }

    DateTime dataAbert = parseDate(json['data_abertura'] ?? json['created_at'] ?? json['createdAt'], DateTime.now());
    DateTime? dataFech = json['data_fechamento'] != null
        ? (DateTime.tryParse(json['data_fechamento'].toString()))
        : (json['closed_at'] != null ? DateTime.tryParse(json['closed_at'].toString()) : null);

    String usuario = json['usuario_abertura'] ?? json['usuario'] ?? json['user_name'] ?? 'Usuário';
    String? tecnico = json['usuario_resolucao'] ?? json['tecnico'] ?? json['assigned_to']?.toString();

    String? imagem = json['imagem_url'] ?? json['imagem'] ?? json['image'];

    return Chamado(
      id: id,
      tituloChamado: titulo,
      descricaoDetalhada: descricao,
      descricaoStatusChamado: status,
      prioridadeChamado: prioridade,
      descricaoCategoria: categoria,
      dataAbertura: dataAbert,
      dataFechamento: dataFech,
      imagemUrl: imagem,
      usuarioNome: usuario,
      tecnicoNome: tecnico,
    );
  }

  static String _converterPrioridade(dynamic valor) {
    if (valor == null) return 'Média';
    if (valor is String) return valor;
    if (valor is int) {
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
    // tentativas de parse de string numérica
    final parsed = int.tryParse(valor.toString());
    if (parsed != null) return _converterPrioridade(parsed);
    return valor.toString();
  }
}
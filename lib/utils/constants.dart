class Constants {
  // URL da API Sistec
  static const String baseUrl = 'http://10.0.2.2:3001'; // Emulador Android
  // static const String baseUrl = 'http://localhost:3001'; // iOS/Chrome
  // static const String baseUrl = 'http://SEU_IP:3001'; // Celular físico

  // Endpoints (sem /api, a API Sistec não usa prefixo)
  static const String loginEndpoint = '/login';
  static const String chamadosEndpoint = '/chamados';

  // Storage Keys (mantém igual)
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Níveis de usuário Sistec
  static const int nivelUsuario = 1;
  static const int nivelAnalista = 2;
  static const int nivelGestor = 3;
  static const int nivelGerente = 4;
  static const int nivelAdmin = 5;

  // Status dos chamados
  static const List<String> statusChamados = [
    'Aberto',
    'Aprovado',
    'Rejeitado',
    'Triagem IA',
    'Aguardando Resposta',
    'Com Analista',
    'Escalado',
    'Resolvido',
    'Fechado',
  ];

  // Prioridades
  static const List<String> prioridades = [
    'Baixa',
    'Média',
    'Alta',
    'Urgente',
  ];
}

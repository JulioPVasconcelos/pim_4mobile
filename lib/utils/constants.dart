class Constants {
  // URL base da API
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Endpoints da API
  static const String loginEndpoint = '/auth/login';
  static const String chamadosEndpoint = '/chamados';
  static const String categoriasEndpoint = '/categorias';

  // Chaves para armazenamento local
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Níveis de usuário
  static const int nivelUsuarioComum = 1;
  static const int nivelTecnico = 2;
  static const int nivelAdmin = 5;

  // Status dos chamados
  static const List<String> statusChamados = [
    'Aberto',
    'Em Andamento',
    'Aguardando',
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

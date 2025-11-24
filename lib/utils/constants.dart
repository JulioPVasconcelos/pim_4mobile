class Constants {
  // -------------------------------------------------------------------------
  // 1. CONFIGURAÇÃO DE URL BASE
  // -------------------------------------------------------------------------
  
  // Como você está rodando no CHROME (Web), use localhost:
  static const String baseUrl = 'http://localhost:3001';
  
  // Se for rodar no EMULADOR Android futuramente, troque para:
  // static const String baseUrl = 'http://10.0.2.2:3001'; 
  
  // Se for rodar no CELULAR FÍSICO, troque para o IP do PC:
  // static const String baseUrl = 'http://192.168.15.5:3001';


  // -------------------------------------------------------------------------
  // 2. ENDPOINTS (Corrigidos conforme seu Swagger)
  // -------------------------------------------------------------------------
  
  // O Swagger diz: "/api/auth/login"
  static const String loginEndpoint = '/api/auth/login'; 
  
  // O Swagger diz: "/api/chamados"
  static const String chamadosEndpoint = '/api/chamados';


  // -------------------------------------------------------------------------
  // 3. KEYS E CONFIGURAÇÕES GERAIS (Mantido igual)
  // -------------------------------------------------------------------------
  
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Níveis de usuário Sistec
  static const int nivelUsuario = 1;
  static const int nivelAnalista = 2;
  static const int nivelGestor = 3;
  static const int nivelGerente = 4;
  static const int nivelAdmin = 5;

   // Status dos Chamados (valores exatos que o backend aceita)
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
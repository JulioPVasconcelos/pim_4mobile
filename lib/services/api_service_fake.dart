import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/chamado.dart';
import '../models/categoria.dart';
import '../models/user.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Interceptor para adicionar token em todas as requisições
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.response?.statusCode} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Definir o token de autenticação
  void setToken(String token) {
    _token = token;
  }

  // ========================================
  // MÉTODOS FAKE PARA TESTES (SEM API REAL)
  // ========================================

  // Login FAKE
  Future<Map<String, dynamic>> login(String email, String senha) async {
    // Simula delay da rede (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    // Simula validação de credenciais
    if (email.isEmpty || senha.isEmpty) {
      throw 'Email e senha são obrigatórios';
    }

    if (senha.length < 4) {
      throw 'Senha inválida';
    }

    // Simula diferentes tipos de usuários
    Map<String, dynamic> userData;

    if (email.contains('tecnico') || email.contains('tech')) {
      // Usuário TÉCNICO
      userData = {
        'id': 2,
        'nome': 'Carlos Técnico',
        'email': email,
        'nivel': 2,
      };
    } else if (email.contains('admin')) {
      // Usuário ADMIN
      userData = {
        'id': 3,
        'nome': 'Admin Sistema',
        'email': email,
        'nivel': 5,
      };
    } else {
      // Usuário COMUM (padrão)
      userData = {
        'id': 1,
        'nome': 'João Silva',
        'email': email,
        'nivel': 1,
      };
    }

    // Simula resposta da API
    return {
      'token': 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': userData,
    };
  }

  // Buscar categorias FAKE
  Future<List<Categoria>> getCategorias() async {
    // Simula delay da rede
    await Future.delayed(const Duration(seconds: 1));

    // Lista de categorias fake
    return [
      Categoria(id: '1', nome: 'Hardware'),
      Categoria(id: '2', nome: 'Software'),
      Categoria(id: '3', nome: 'Rede'),
      Categoria(id: '4', nome: 'Impressora'),
      Categoria(id: '5', nome: 'E-mail'),
      Categoria(id: '6', nome: 'Telefonia'),
    ];
  }

  // Buscar chamados FAKE
  Future<List<Chamado>> getChamados({
    String? status,
    String? prioridade,
    DateTime? dataInicio,
    DateTime? dataFim,
    User? usuarioLogado,
  }) async {
    // Simula delay da rede
    await Future.delayed(const Duration(seconds: 1));

    // Lista de chamados fake
    List<Chamado> todosChamados = [
      Chamado(
        id: '1',
        titulo: 'Computador não liga',
        descricao:
            'O computador da sala 203 não está ligando. Tentei apertar o botão várias vezes mas nada acontece.',
        status: 'Aberto',
        prioridade: 'Alta',
        categoria: 'Hardware',
        dataAbertura: DateTime.now().subtract(const Duration(hours: 2)),
        usuarioNome: 'João Silva',
        tecnicoNome: null,
        imagemUrl: null,
      ),
      Chamado(
        id: '2',
        titulo: 'Impressora com problema',
        descricao:
            'A impressora não imprime em cores, apenas preto e branco. Já verifiquei os cartuchos e estão cheios.',
        status: 'Em Andamento',
        prioridade: 'Média',
        categoria: 'Impressora',
        dataAbertura: DateTime.now().subtract(const Duration(days: 1)),
        usuarioNome: 'João Silva',
        tecnicoNome: 'Carlos Técnico',
        imagemUrl: null,
      ),
      Chamado(
        id: '3',
        titulo: 'Internet lenta',
        descricao:
            'A internet está muito lenta no setor administrativo. Páginas demoram muito para carregar.',
        status: 'Aberto',
        prioridade: 'Baixa',
        categoria: 'Rede',
        dataAbertura: DateTime.now().subtract(const Duration(hours: 5)),
        usuarioNome: 'Ana Costa',
        tecnicoNome: null,
        imagemUrl: null,
      ),
      Chamado(
        id: '4',
        titulo: 'Senha do e-mail expirada',
        descricao:
            'Minha senha do e-mail corporativo expirou e não consigo redefinir.',
        status: 'Aguardando',
        prioridade: 'Média',
        categoria: 'E-mail',
        dataAbertura: DateTime.now().subtract(const Duration(hours: 8)),
        usuarioNome: 'Pedro Lima',
        tecnicoNome: 'Carlos Técnico',
        imagemUrl: null,
      ),
      Chamado(
        id: '5',
        titulo: 'Excel travando',
        descricao:
            'O Excel trava toda vez que abro planilhas grandes. Já tentei reiniciar o computador.',
        status: 'Resolvido',
        prioridade: 'Alta',
        categoria: 'Software',
        dataAbertura: DateTime.now().subtract(const Duration(days: 2)),
        usuarioNome: 'Carla Mendes',
        tecnicoNome: 'Carlos Técnico',
        imagemUrl: 'https://picsum.photos/500/300',
      ),
      Chamado(
        id: '6',
        titulo: 'Ramal sem sinal',
        descricao:
            'O ramal 2045 está sem sinal. Não consigo fazer nem receber ligações.',
        status: 'Fechado',
        prioridade: 'Urgente',
        categoria: 'Telefonia',
        dataAbertura: DateTime.now().subtract(const Duration(days: 3)),
        usuarioNome: 'Roberto Silva',
        tecnicoNome: 'Ana Suporte',
        imagemUrl: 'https://picsum.photos/500/301',
      ),
    ];

    // FILTRO POR NÍVEL DE USUÁRIO
    List<Chamado> chamadosFiltrados = todosChamados;

    if (usuarioLogado != null) {
      if (usuarioLogado.nivel == 1) {
        // USUÁRIO COMUM: Vê apenas seus próprios chamados
        chamadosFiltrados = chamadosFiltrados
            .where((c) => c.usuarioNome == usuarioLogado.nome)
            .toList();
      } else if (usuarioLogado.nivel == 2) {
        // TÉCNICO: Vê apenas chamados atribuídos a ele
        chamadosFiltrados = chamadosFiltrados
            .where((c) => c.tecnicoNome == usuarioLogado.nome)
            .toList();
      }
      // nivel >= 5 (ADMIN): Vê todos (não filtra)
    }

    // Aplicar filtros adicionais
    if (status != null) {
      chamadosFiltrados = chamadosFiltrados
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
    }

    if (prioridade != null) {
      chamadosFiltrados = chamadosFiltrados
          .where((c) => c.prioridade.toLowerCase() == prioridade.toLowerCase())
          .toList();
    }

    if (dataInicio != null) {
      chamadosFiltrados = chamadosFiltrados
          .where((c) => c.dataAbertura.isAfter(dataInicio))
          .toList();
    }

    if (dataFim != null) {
      chamadosFiltrados = chamadosFiltrados
          .where((c) => c.dataAbertura.isBefore(dataFim))
          .toList();
    }

    return chamadosFiltrados;
  }

  // Criar novo chamado FAKE
  Future<Chamado> criarChamado({
    required String titulo,
    required String descricao,
    required String categoriaId,
    required String prioridade,
    String? imagemPath,
  }) async {
    // Simula delay da rede
    await Future.delayed(const Duration(seconds: 2));

    // Validações
    if (titulo.trim().isEmpty) {
      throw 'Título é obrigatório';
    }

    if (descricao.trim().isEmpty) {
      throw 'Descrição é obrigatória';
    }

    // Busca nome da categoria pelo ID
    final categorias = await getCategorias();
    final categoria = categorias.firstWhere(
      (c) => c.id == categoriaId,
      orElse: () => Categoria(id: categoriaId, nome: 'Outros'),
    );

    // Cria novo chamado
    return Chamado(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      titulo: titulo,
      descricao: descricao,
      status: 'Aberto',
      prioridade: prioridade,
      categoria: categoria.nome,
      dataAbertura: DateTime.now(),
      usuarioNome: 'João Silva', // Usuário logado
      tecnicoNome: null,
      imagemUrl: imagemPath, // Em produção seria URL do servidor
    );
  }

  // Buscar detalhes de um chamado específico FAKE
  Future<Chamado> getChamadoById(String id) async {
    // Simula delay da rede
    await Future.delayed(const Duration(seconds: 1));

    // Busca na lista de todos os chamados
    final chamados = await getChamados();

    try {
      return chamados.firstWhere((c) => c.id == id);
    } catch (e) {
      throw 'Chamado não encontrado';
    }
  }

  // ========================================
  // MÉTODO ORIGINAL (comentado para referência)
  // ========================================

  /*
  // VERSÃO REAL - USE QUANDO TIVER A API
  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        Constants.loginEndpoint,
        data: {
          'email': email,
          'senha': senha,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await _dio.get(Constants.categoriasEndpoint);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Categoria.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Chamado>> getChamados({
    String? status,
    String? prioridade,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (status != null) queryParams['status'] = status;
      if (prioridade != null) queryParams['prioridade'] = prioridade;
      if (dataInicio != null) queryParams['data_inicio'] = dataInicio.toIso8601String();
      if (dataFim != null) queryParams['data_fim'] = dataFim.toIso8601String();
      
      final response = await _dio.get(
        Constants.chamadosEndpoint,
        queryParameters: queryParams,
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Chamado.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Chamado> criarChamado({
    required String titulo,
    required String descricao,
    required String categoriaId,
    required String prioridade,
    String? imagemPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'titulo': titulo,
        'descricao': descricao,
        'categoria_id': categoriaId,
        'prioridade': prioridade,
      });
      
      if (imagemPath != null) {
        formData.files.add(
          MapEntry(
            'imagem',
            await MultipartFile.fromFile(imagemPath),
          ),
        );
      }
      
      final response = await _dio.post(
        Constants.chamadosEndpoint,
        data: formData,
      );
      
      return Chamado.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Chamado> getChamadoById(String id) async {
    try {
      final response = await _dio.get('${Constants.chamadosEndpoint}/$id');
      return Chamado.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  */

  // ========================================
  // TRATAMENTO DE ERROS (comentado - só necessário na versão real)
  // ========================================

  /*
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] ?? error.response!.data['error'];
      
      switch (statusCode) {
        case 400:
          return message ?? 'Requisição inválida';
        case 401:
          return 'Não autorizado. Faça login novamente';
        case 403:
          return 'Acesso negado';
        case 404:
          return 'Recurso não encontrado';
        case 500:
          return 'Erro no servidor. Tente novamente mais tarde';
        default:
          return message ?? 'Erro desconhecido';
      }
    }
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet';
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return 'Erro de conexão. Verifique sua internet';
    }
    
    return 'Erro ao conectar com o servidor';
  }
  */
}

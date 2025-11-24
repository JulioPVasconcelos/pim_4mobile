import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/chamado.dart';
import '../models/categoria.dart';
import '../models/user.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
      // IMPORTANTE: A API usa SESSÃO, não JWT!
      // Precisamos manter cookies entre requisições
      followRedirects: true,
      validateStatus: (status) => status! < 500,
    ));

    // Interceptor para log e tratamento de erros
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('📤 ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ API Error: ${error.response?.statusCode} - ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Não precisa de setToken pois usa sessão!
  // A sessão é mantida automaticamente pelos cookies

  // ========================================
  // AUTENTICAÇÃO
  // ========================================

  /// POST /login
  /// Body: { email, senha }
  /// Response: { message, usuario }
  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'senha': senha,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw response.data['error'] ?? 'Erro ao fazer login';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /logout
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      print('Erro ao fazer logout: $e');
      // Ignora erros de logout
    }
  }

  // ========================================
  // CATEGORIAS
  // ========================================

  /// GET /categorias (ou endpoint correto)
  /// NOTA: Não vi endpoint de categorias no Swagger!
  /// Você terá que confirmar o endpoint correto ou usar lista fixa
  Future<List<Categoria>> getCategorias() async {
    try {
      // TEMPORÁRIO: Lista fixa baseada no Swagger
      // As categorias são: hardware, software, rede, email, acesso, sistema
      return [
        Categoria(id: 'hardware', nome: 'Hardware'),
        Categoria(id: 'software', nome: 'Software'),
        Categoria(id: 'rede', nome: 'Rede'),
        Categoria(id: 'email', nome: 'E-mail'),
        Categoria(id: 'acesso', nome: 'Acesso'),
        Categoria(id: 'sistema', nome: 'Sistema'),
      ];

      // Se tiver endpoint real, use:
      // final response = await _dio.get('/categorias');
      // if (response.data is List) {
      //   return (response.data as List)
      //       .map((json) => Categoria.fromJson(json))
      //       .toList();
      // }
      // return [];
    } catch (e) {
      print('Erro ao buscar categorias: $e');
      // Retorna lista padrão em caso de erro
      return [
        Categoria(id: 'hardware', nome: 'Hardware'),
        Categoria(id: 'software', nome: 'Software'),
        Categoria(id: 'rede', nome: 'Rede'),
        Categoria(id: 'email', nome: 'E-mail'),
        Categoria(id: 'acesso', nome: 'Acesso'),
        Categoria(id: 'sistema', nome: 'Sistema'),
      ];
    }
  }

  // ========================================
  // CHAMADOS
  // ========================================

  /// GET /chamados
  /// Query params opcionais: status, prioridade, etc
  Future<List<Chamado>> getChamados({
    String? status,
    String? prioridade,
    DateTime? dataInicio,
    DateTime? dataFim,
    User? usuarioLogado,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      // Adicione filtros se necessário
      if (status != null) queryParams['status'] = status;
      if (prioridade != null) queryParams['prioridade'] = prioridade;
      if (dataInicio != null) {
        queryParams['data_inicio'] = dataInicio.toIso8601String();
      }
      if (dataFim != null) {
        queryParams['data_fim'] = dataFim.toIso8601String();
      }

      final response = await _dio.get(
        '/chamados',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => Chamado.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /chamados/:id
  Future<Chamado> getChamadoById(String id) async {
    try {
      final response = await _dio.get('/chamados/$id');

      if (response.statusCode == 200) {
        return Chamado.fromJson(response.data);
      } else {
        throw 'Chamado não encontrado';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /chamados
  /// Body: { id_usuario_abertura, prioridade_chamado, descricao_categoria, descricao_problema, descricao_detalhada }
  Future<Chamado> criarChamado({
    required int idUsuario,
    required String titulo,
    required String descricao,
    required String categoriaId,
    required String prioridade,
    String? imagemPath,
  }) async {
    try {
      // Formatar descrição detalhada em markdown
      String descricaoDetalhada =
          '**Título:** $titulo\n\n**Descrição:** $descricao';

      // Converter prioridade para lowercase
      String prioridadeLower = prioridade.toLowerCase();

      // NOTA: A API não suporta upload de imagem diretamente no endpoint de criar chamado!
      // Você precisará adicionar um endpoint separado ou modificar o backend

      final response = await _dio.post(
        '/chamados',
        data: {
          'id_usuario_abertura': idUsuario,
          'prioridade_chamado':
              prioridadeLower, // 'baixa', 'media', 'alta', 'urgente'
          'descricao_categoria': categoriaId, // 'hardware', 'software', etc
          'descricao_problema':
              _gerarSlugProblema(titulo), // Gera slug do título
          'descricao_detalhada': descricaoDetalhada,
        },
      );

      if (response.statusCode == 201) {
        return Chamado.fromJson(response.data);
      } else {
        throw response.data['error'] ?? 'Erro ao criar chamado';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========================================
  // HELPERS
  // ========================================

  /// Gera slug do título (ex: "PC não liga" -> "pc-nao-liga")
  String _gerarSlugProblema(String titulo) {
    return titulo
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// Tratamento de erros
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Tentar extrair mensagem de erro
      String? message;
      if (data is Map) {
        message = data['error'] ?? data['message'] ?? data['details'];
      }

      switch (statusCode) {
        case 400:
          return message ?? 'Requisição inválida';
        case 401:
          return message ?? 'Não autorizado. Faça login novamente';
        case 403:
          return message ?? 'Acesso negado';
        case 404:
          return message ?? 'Recurso não encontrado';
        case 500:
          return message ?? 'Erro no servidor. Tente novamente mais tarde';
        default:
          return message ?? 'Erro desconhecido';
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Erro de conexão. Verifique se a API está rodando';
    }

    return 'Erro ao conectar com o servidor';
  }
}

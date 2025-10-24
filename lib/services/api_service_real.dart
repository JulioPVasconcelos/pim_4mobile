import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/chamado.dart';
import '../models/categoria.dart';

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

  // Login
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

  // Buscar categorias
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

  // Buscar chamados
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
      if (dataInicio != null) {
        queryParams['data_inicio'] = dataInicio.toIso8601String();
      }
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

  // Criar novo chamado
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

      // Se tiver imagem, adiciona ao FormData
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

  // Buscar detalhes de um chamado específico
  Future<Chamado> getChamadoById(String id) async {
    try {
      final response = await _dio.get('${Constants.chamadosEndpoint}/$id');
      return Chamado.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tratamento de erros
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message =
          error.response!.data['message'] ?? error.response!.data['error'];

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
}

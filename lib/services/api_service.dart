import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../utils/constants.dart';
import '../models/chamado.dart';
import '../models/categoria.dart';


class ApiService {
  late Dio _dio;
  late CookieJar _cookieJar;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      extra: kIsWeb ? {'withCredentials': true} : null,
      validateStatus: (status) => status! < 500,
    ));

    _initInterceptors();
  }

  Future<void> _initInterceptors() async {
    if (!kIsWeb) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final path = '${appDocDir.path}/.cookies/';
        await Directory(path).create(recursive: true);
        
        _cookieJar = PersistCookieJar(storage: FileStorage(path));
        _dio.interceptors.add(CookieManager(_cookieJar));
      } catch (e) {
        print('⚠️ Erro ao inicializar cookies no mobile: $e');
      }
    }

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

  // ========================================
  // AUTENTICAÇÃO
  // ========================================

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        Constants.loginEndpoint,
        data: {
          'email': email,
          'password': senha,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw response.data['message'] ?? response.data['error'] ?? 'Erro ao fazer login';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
      if (!kIsWeb) {
        await _cookieJar.deleteAll();
      }
    } catch (e) {
      print('Erro logout: $e');
    }
  }

  // ========================================
  // CATEGORIAS
  // ========================================

  Future<List<Categoria>> getCategorias() async {
    try {
      return [
        Categoria(id: 'hardware', nome: 'Hardware'),
        Categoria(id: 'software', nome: 'Software'),
        Categoria(id: 'rede', nome: 'Rede'),
        Categoria(id: 'email', nome: 'E-mail'),
        Categoria(id: 'acesso', nome: 'Acesso'),
        Categoria(id: 'sistema', nome: 'Sistema'),
      ];
    } catch (e) {
      return [];
    }
  }

  // ========================================
  // CHAMADOS
  // ========================================

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

      if (response.statusCode == 200) {
        var rawData = response.data;
        if (rawData is Map && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }

        if (rawData is List) {
          return rawData.map((json) => Chamado.fromJson(json)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Chamado> getChamadoById(String id) async {
    try {
      final response = await _dio.get('${Constants.chamadosEndpoint}/$id');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map && data.containsKey('data')) {
           data = data['data'];
        }
        return Chamado.fromJson(data);
      } else {
        throw 'Chamado não encontrado';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Chamado> criarChamado({
    required int idUsuario,
    required String titulo,
    required String descricao,
    required String categoriaId,
    required String prioridade,
    String? imagemPath,
  }) async {
    try {
      String descricaoDetalhada = '**Título:** $titulo\n\n**Descrição:** $descricao';
      String prioridadeLower = prioridade.toLowerCase();

      final response = await _dio.post(
        Constants.chamadosEndpoint,
        data: {
          'id_usuario_abertura': idUsuario,
          'prioridade_chamado': prioridadeLower,
          'descricao_categoria': categoriaId,
          'descricao_problema': _gerarSlugProblema(titulo),
          'descricao_detalhada': descricaoDetalhada,
        },
      );

      if (response.statusCode == 201) {
        var data = response.data;
        if (data is Map && data.containsKey('data')) {
           data = data['data'];
        }
        return Chamado.fromJson(data);
      } else {
        throw response.data['error'] ?? 'Erro ao criar chamado';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========================================
  // INTEGRAÇÃO IA (GEMINI)
  // ========================================

  Future<Map<String, dynamic>> getSolucaoIA(String idChamado) async {
    try {
      final response = await _dio.get('${Constants.chamadosEndpoint}/$idChamado/solucao-ia');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw 'Solução não encontrada';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'A IA ainda está analisando este chamado. Tente novamente em alguns instantes.';
      }
      throw _handleError(e);
    }
  }

  // CORRIGIDO: Converte ID para int e usa formato correto
  Future<void> enviarFeedbackIA(String idChamado, bool funcionou, String comentario) async {
    try {
      // Converte o ID para int para evitar erro 403
      final idNumerico = int.parse(idChamado);
      
      await _dio.post(
        '/api/chamados/$idNumerico/feedback-ia',
        data: {
          'feedback': funcionou ? 'DEU_CERTO' : 'DEU_ERRADO'
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========================================
  // HELPERS
  // ========================================

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

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String? message;
      if (data is Map) {
        message = data['error'] ?? data['message'] ?? data['details'];
      }

      switch (statusCode) {
        case 400: return message ?? 'Requisição inválida (Dados incorretos)';
        case 401: return message ?? 'Sessão expirada. Faça login novamente.';
        case 403: return message ?? 'Acesso negado';
        case 404: return message ?? 'Recurso não encontrado';
        case 500: return message ?? 'Erro no servidor';
        default: return message ?? 'Erro desconhecido: $statusCode';
      }
    }
    return 'Erro de conexão';
  }
}

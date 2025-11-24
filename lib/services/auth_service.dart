import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Verificar se há autenticação salva
  Future<bool> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(Constants.rememberMeKey) ?? false;

      if (!rememberMe) {
        return false;
      }

      // Buscar usuário salvo (NÃO precisa de token, a sessão é via cookie)
      final userJson = prefs.getString(Constants.userKey);

      if (userJson != null) {
        try {
          _currentUser = User.fromJson(json.decode(userJson));
          _isAuthenticated = true;
          notifyListeners();
          return true;
        } catch (e) {
          print('Erro ao decodificar usuário salvo: $e');
          await logout(); // Limpa dados corrompidos
          return false;
        }
      }

      return false;
    } catch (e) {
      print('Erro ao verificar autenticação: $e');
      return false;
    }
  }

  // Fazer login
  Future<void> login(String email, String senha, bool rememberMe) async {
    try {
      final response = await _apiService.login(email, senha);

      print('🔍 DEBUG LOGIN RESPONSE: $response');

      // ============================================================
      // LÓGICA DE EXTRAÇÃO ROBUSTA (Resolve o problema do JSON)
      // ============================================================
      dynamic userData;

      // 1. Tenta pegar dentro de 'data' (ex: { success: true, data: { user: ... } })
      if (response.containsKey('data')) {
        final data = response['data'];
        if (data is Map) {
          userData = data['user'] ?? data['usuario'] ?? data;
        } else {
          userData = data;
        }
      } 
      // 2. Tenta pegar na raiz (ex: { usuario: ... })
      else {
        userData = response['usuario'] ?? response['user'];
      }

      if (userData == null) {
        throw 'Dados do usuário não encontrados na resposta. Chaves: ${response.keys}';
      }

      // 3. Garante que é um Map
      Map<String, dynamic> userMap;
      if (userData is List) {
         if (userData.isEmpty) throw 'Lista de usuários vazia';
         userMap = userData.first;
      } else {
         userMap = Map<String, dynamic>.from(userData);
      }

      // Converte para Modelo
      try {
        _currentUser = User.fromJson(userMap);
      } catch (e) {
        print('❌ Erro conversão User.fromJson: $e');
        print('Dados recebidos: $userMap');
        throw 'Erro ao processar dados do usuário';
      }
      
      _isAuthenticated = true;

      // Persistir dados
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Constants.rememberMeKey, rememberMe);

      if (rememberMe) {
        await prefs.setString(Constants.userKey, json.encode(userMap));
      }

      notifyListeners();
    } catch (e) {
      print('❌ Erro no Login (AuthService): $e');
      rethrow;
    }
  }

  // Fazer logout
  Future<void> logout() async {
    try {
      await _apiService.logout();

      await _secureStorage.delete(key: Constants.tokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userKey);
      await prefs.remove(Constants.rememberMeKey);

      _currentUser = null;
      _isAuthenticated = false;

      notifyListeners();
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  ApiService get apiService => _apiService;
}
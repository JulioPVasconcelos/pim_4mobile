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

      // Buscar usuário salvo (NÃO precisa de token!)
      final userJson = prefs.getString(Constants.userKey);

      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
        _isAuthenticated = true;
        notifyListeners();
        return true;
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

      // A API Sistec retorna: { message, usuario }
      final userData = response['usuario'];

      if (userData == null) {
        throw 'Resposta inválida do servidor';
      }

      // A sessão já está ativa automaticamente (via cookies)!
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;

      // Persistir se "lembrar senha" estiver marcado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Constants.rememberMeKey, rememberMe);

      if (rememberMe) {
        await prefs.setString(Constants.userKey, json.encode(userData));
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Fazer logout
  Future<void> logout() async {
    try {
      // Chamar API para encerrar sessão
      await _apiService.logout();

      // Limpar dados salvos
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

  // Obter API Service
  ApiService get apiService => _apiService;
}

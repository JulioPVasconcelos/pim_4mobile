import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chamado.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';


class DetalhesChamadoScreen extends StatefulWidget {
  final Chamado chamado;

  const DetalhesChamadoScreen({
    super.key,
    required this.chamado,
  });

  @override
  State<DetalhesChamadoScreen> createState() => _DetalhesChamadoScreenState();
}


class _DetalhesChamadoScreenState extends State<DetalhesChamadoScreen> {
  late Chamado _chamado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chamado = widget.chamado;
  }

  Future<void> _atualizarChamado() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final atualizado = await authService.apiService.getChamadoById(_chamado.id.toString());
      setState(() {
        _chamado = atualizado;
      });
    } catch (e) {
      print("Erro ao atualizar chamado: $e");
    }
  }

  Color _getStatusColor() {
    switch (_chamado.descricaoStatusChamado.toLowerCase()) {
      case 'aberto':
        return AppTheme.vibrantViolet;
      case 'em andamento':
      case 'com analista':
        return AppTheme.peachOrange;
      case 'aguardando resposta':
      case 'triagem ia':
        return AppTheme.atomicTangerine;
      case 'resolvido':
      case 'fechado':
        return const Color(0xFF4CAF50);
      case 'rejeitado':
        return Colors.red;
      default:
        return AppTheme.coolGray;
    }
  }

  Color _getPrioridadeColor() {
    switch (_chamado.prioridadeChamado.toLowerCase()) {
      case 'baixa':
        return const Color(0xFF4CAF50);
      case 'média':
      case 'media':
        return AppTheme.atomicTangerine;
      case 'alta':
        return AppTheme.peachOrange;
      case 'urgente':
        return Colors.red;
      default:
        return AppTheme.coolGray;
    }
  }

  // ===============================================
  // LÓGICA DA SOLUÇÃO IA
  // ===============================================

  Future<void> _mostrarSolucaoIA() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final dadosIA = await authService.apiService.getSolucaoIA(_chamado.id);
      
      final solucaoTexto = dadosIA['data']?['solucao_ia']
                          ?? dadosIA['solucao_ia']
                          ?? 'Nenhuma solução gerada ainda.';

      print('Resposta completa da API: $dadosIA');
      print('Solução extraída: $solucaoTexto');

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.vibrantViolet, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sugestão da IA',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.midnightNavy,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: MarkdownBody(
                        data: solucaoTexto,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                          h1: const TextStyle(color: AppTheme.vibrantViolet, fontWeight: FontWeight.bold),
                          h2: const TextStyle(color: AppTheme.vibrantViolet, fontWeight: FontWeight.bold),
                          strong: const TextStyle(fontWeight: FontWeight.w900),
                          code: TextStyle(backgroundColor: Colors.grey[200], fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Essa solução resolveu seu problema?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.thumb_down),
                          label: const Text('Não Funcionou'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _enviarFeedback(false),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.thumb_up),
                          label: const Text('Funcionou!'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _enviarFeedback(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar solução: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enviarFeedback(bool funcionou) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await authService.apiService.enviarFeedbackIA(
        _chamado.id.toString(),
        funcionou,
        funcionou 
            ? 'Usuário confirmou que a solução funcionou.' 
            : 'Usuário informou que a solução falhou e solicitou analista.',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(funcionou 
            ? 'Que bom! Chamado marcado como resolvido.' 
            : 'Entendido. Um analista assumirá o caso.'),
          backgroundColor: funcionou ? Colors.green : AppTheme.peachOrange,
          duration: const Duration(seconds: 3),
        ),
      );

      await _atualizarChamado();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar feedback: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(_chamado.dataAbertura);
    
    final bool mostrarBotaoIA = _chamado.descricaoStatusChamado.toLowerCase() == 'aguardando resposta' || 
                                _chamado.descricaoStatusChamado.toLowerCase() == 'triagem ia';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _atualizarChamado,
            tooltip: 'Atualizar',
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(
                        color: _getStatusColor(),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _chamado.descricaoStatusChamado.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        _chamado.tituloChamado,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.midnightNavy,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Chamado #${_chamado.id}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppTheme.coolGray),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (mostrarBotaoIA) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.vibrantViolet.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.vibrantViolet.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: AppTheme.vibrantViolet, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Sugestão Inteligente Disponível',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.midnightNavy),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A nossa IA analisou seu problema e encontrou uma possível solução.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _mostrarSolucaoIA,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.vibrantViolet,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'VER SOLUÇÃO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Descrição do Problema'),
                      const SizedBox(height: 8),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: MarkdownBody(
                          data: _chamado.descricaoDetalhada,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 15),
                            strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      _buildSectionTitle('Informações'),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: Icons.category_outlined,
                        label: 'Categoria',
                        value: _chamado.descricaoCategoria,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Prioridade',
                        value: _chamado.prioridadeChamado,
                        valueColor: _getPrioridadeColor(),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: 'Aberto em',
                        value: dataFormatada,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Pessoas'),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Solicitante',
                        value: _chamado.usuarioNome,
                      ),

                      if (_chamado.tecnicoNome != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.engineering_outlined,
                          label: 'Técnico Responsável',
                          value: _chamado.tecnicoNome!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.midnightNavy,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.coolGray,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.coolGray,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.midnightNavy,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

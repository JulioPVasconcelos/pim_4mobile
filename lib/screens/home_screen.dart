import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/chamado.dart';
import '../utils/constants.dart';
import '../widgets/chamado_card.dart';
import 'novo_chamado_screen.dart';
import 'detalhes_chamado_screen.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  List<Chamado> _chamados = [];
  bool _isLoading = false;
  String? _filtroStatus;
  String? _filtroPrioridade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarChamados();
    });
  }

  Future<void> _carregarChamados() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Converte os filtros para lowercase antes de enviar para a API
      final statusLower = _filtroStatus?.toLowerCase();
      final prioridadeLower = _filtroPrioridade?.toLowerCase();
      
      print('🔍 Filtrando: status=$statusLower, prioridade=$prioridadeLower');
      
      final chamados = await authService.apiService.getChamados(
        status: statusLower,
        prioridade: prioridadeLower,
      );

      setState(() {
        _chamados = chamados;
      });
      
      print('✅ ${chamados.length} chamados carregados');
    } catch (e) {
      print('❌ Erro: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar chamados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String? tempStatus = _filtroStatus;
        String? tempPrioridade = _filtroPrioridade;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16, 
                  right: 16, 
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (tempStatus != null || tempPrioridade != null)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempStatus = null;
                                tempPrioridade = null;
                              });
                            },
                            child: const Text('Limpar'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Filtro de Status
                    DropdownButtonFormField<String>(
                      value: tempStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...Constants.statusChamados.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setModalState(() => tempStatus = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Filtro de Prioridade
                    DropdownButtonFormField<String>(
                      value: tempPrioridade,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ...Constants.prioridades.map((prioridade) {
                          return DropdownMenuItem(
                            value: prioridade,
                            child: Text(prioridade),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setModalState(() => tempPrioridade = value);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filtroStatus = tempStatus;
                                _filtroPrioridade = tempPrioridade;
                              });
                              Navigator.pop(context);
                              _carregarChamados();
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    final isTecnico = user?.isTecnico ?? false; 
    final showFab = !isTecnico; 

    // Mostra badge com filtros ativos
    final filtrosAtivos = (_filtroStatus != null ? 1 : 0) + (_filtroPrioridade != null ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _mostrarFiltros,
                tooltip: 'Filtros',
              ),
              if (filtrosAtivos > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$filtrosAtivos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarChamados,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chamados.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                filtrosAtivos > 0
                                    ? 'Nenhum chamado encontrado com esses filtros'
                                    : 'Nenhum chamado encontrado',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (filtrosAtivos > 0) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Limpar filtros'),
                                  onPressed: () {
                                    setState(() {
                                      _filtroStatus = null;
                                      _filtroPrioridade = null;
                                    });
                                    _carregarChamados();
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _chamados.length,
                      itemBuilder: (context, index) {
                        final chamado = _chamados[index];
                        return ChamadoCard(
                          chamado: chamado,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalhesChamadoScreen(
                                  chamado: chamado,
                                ),
                              ),
                            );
                            _carregarChamados();
                          },
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovoChamadoScreen(),
                  ),
                );
                _carregarChamados();
              },
              icon: const Icon(Icons.add),
              label: const Text('Novo Chamado'),
            )
          : null,
    );
  }
}

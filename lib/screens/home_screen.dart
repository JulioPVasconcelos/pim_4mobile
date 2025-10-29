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
    _carregarChamados();
  }

  Future<void> _carregarChamados() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final chamados = await authService.apiService.getChamados(
        status: _filtroStatus,
        prioridade: _filtroPrioridade,
        usuarioLogado: authService.currentUser, // ← ADICIONE ESTA LINHA
      );

      setState(() {
        _chamados = chamados;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar chamados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String? tempStatus = _filtroStatus;
        String? tempPrioridade = _filtroPrioridade;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              // ← ENVOLVA COM SafeArea
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Filtro de Status
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
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
                      initialValue: tempPrioridade,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16), // ← ESPAÇO EXTRA
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

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final showFab = user?.isTecnico == false;
    final bottomListPadding = 16.0 + MediaQuery.of(context).padding.bottom + (showFab ? 88.0 : 0.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        // ← ENVOLVA O BODY COM SafeArea
        child: RefreshIndicator(
          onRefresh: _carregarChamados,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chamados.isEmpty
                  ? Center(
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
                            'Nenhum chamado encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomListPadding),
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
      floatingActionButton: user?.isTecnico == false
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

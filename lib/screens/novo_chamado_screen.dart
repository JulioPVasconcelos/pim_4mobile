import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../models/categoria.dart';
import '../utils/constants.dart';

class NovoChamadoScreen extends StatefulWidget {
  const NovoChamadoScreen({super.key});

  @override
  State<NovoChamadoScreen> createState() => _NovoChamadoScreenState();
}

class _NovoChamadoScreenState extends State<NovoChamadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  List<Categoria> _categorias = [];
  Categoria? _categoriaSelecionada;
  String _prioridadeSelecionada = 'Média';

  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingCategorias = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    setState(() => _isLoadingCategorias = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final categorias = await authService.apiService.getCategorias();

      setState(() {
        _categorias = categorias;
        if (_categorias.isNotEmpty) {
          _categoriaSelecionada = _categorias.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar categorias: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingCategorias = false);
    }
  }

  Future<void> _selecionarImagem() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagemSelecionada != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagemSelecionada = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagemSelecionada = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _criarChamado() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma categoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.apiService.criarChamado(
        idUsuario:
            int.parse(authService.currentUser!.id), // ← ID do usuário logado
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoriaId: _categoriaSelecionada!.id,
        prioridade: _prioridadeSelecionada,
        imagemPath: _imagemSelecionada?.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar chamado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Novo Chamado'),
      ),
      body: _isLoadingCategorias
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 +
                      MediaQuery.of(context).padding.bottom +
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          hintText: 'Ex: Computador não liga',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite um título';
                          }
                          if (value.trim().length < 5) {
                            return 'Título muito curto (mín. 5 caracteres)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      TextFormField(
                        controller: _descricaoController,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Descreva o problema detalhadamente',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite uma descrição';
                          }
                          if (value.trim().length < 10) {
                            return 'Descrição muito curta (mín. 10 caracteres)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Label Categoria
                      const Text(
                        'Categoria',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Categoria
                      DropdownButtonFormField<Categoria>(
                        initialValue: _categoriaSelecionada,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.category,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _categorias.map((categoria) {
                          return DropdownMenuItem<Categoria>(
                            value: categoria,
                            child: Text(categoria.nome),
                          );
                        }).toList(),
                        onChanged: (Categoria? nova) {
                          setState(() {
                            _categoriaSelecionada = nova;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Label Prioridade
                      const Text(
                        'Prioridade',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Prioridade
                      DropdownButtonFormField<String>(
                        initialValue: _prioridadeSelecionada,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.flag,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: Constants.prioridades.map((prioridade) {
                          return DropdownMenuItem<String>(
                            value: prioridade,
                            child: Text(prioridade),
                          );
                        }).toList(),
                        onChanged: (String? nova) {
                          setState(() {
                            _prioridadeSelecionada = nova ?? 'Média';
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Seção de imagem
                      Text(
                        'Imagem (opcional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      // Preview da imagem ou botão
                      if (_imagemSelecionada != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imagemSelecionada!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: _selecionarImagem,
                              ),
                            ),
                          ],
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _selecionarImagem,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Adicionar foto'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Botão de criar
                      ElevatedButton(
                        onPressed: _isLoading ? null : _criarChamado,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Criar Chamado',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

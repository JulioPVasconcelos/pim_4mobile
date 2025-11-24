import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chamado.dart';
import '../utils/app_theme.dart';


class ChamadoCard extends StatelessWidget {
  final Chamado chamado;
  final VoidCallback onTap;

  const ChamadoCard({
    super.key,
    required this.chamado,
    required this.onTap,
  });

  Color _getStatusColor() {
    final s = chamado.descricaoStatusChamado.toLowerCase();
    if (s.contains('aberto')) return AppTheme.vibrantViolet;
    if (s.contains('em andamento') || s.contains('com analista') || s.contains('andamento')) return AppTheme.peachOrange;
    if (s.contains('aguardando') || s.contains('triagem')) return AppTheme.atomicTangerine;
    if (s.contains('resolvido') || s.contains('fechado')) return const Color(0xFF4CAF50);
    if (s.contains('rejeitado')) return AppTheme.coolGray;
    return AppTheme.vibrantViolet;
  }

  Color _getPrioridadeColor() {
    final p = chamado.prioridadeChamado.toLowerCase();
    if (p.contains('baixa')) return const Color(0xFF4CAF50);
    if (p.contains('média') || p.contains('media')) return AppTheme.atomicTangerine;
    if (p.contains('alta')) return AppTheme.peachOrange;
    if (p.contains('urgente')) return Colors.red;
    return AppTheme.coolGray;
  }

  // Função para processar \n literal
  String _processarTexto(String texto) {
    return texto.replaceAll(r'\n', '\n');
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(chamado.dataAbertura);
    
    // Processa o texto para converter \n literais em quebras reais
    final descricaoProcessada = _processarTexto(chamado.descricaoDetalhada);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha 1: Título e Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chamado.tituloChamado,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      chamado.descricaoStatusChamado,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Linha 2: Descrição COM MARKDOWN (SEM ALTURA FIXA)
              LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 60, // Altura máxima
                      maxWidth: constraints.maxWidth,
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: MarkdownBody(
                        data: descricaoProcessada,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.midnightNavy,
                          ),
                        ),
                        shrinkWrap: true,
                        fitContent: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Linha 3: Categoria e Prioridade
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    chamado.descricaoCategoria,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPrioridadeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 12,
                          color: _getPrioridadeColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chamado.prioridadeChamado,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPrioridadeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 4: Data e Usuário
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dataFormatada,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      chamado.usuarioNome,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Linha 5: Técnico (se houver)
              if (chamado.tecnicoNome != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.engineering_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Técnico: ${chamado.tecnicoNome}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

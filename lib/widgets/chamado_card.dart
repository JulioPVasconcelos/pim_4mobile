import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    switch (chamado.getStatusColor()) {
      case 'blue':
        return AppTheme.vibrantViolet; // ← USE AS CORES DO TEMA
      case 'orange':
        return AppTheme.peachOrange;
      case 'yellow':
        return AppTheme.atomicTangerine;
      case 'green':
        return const Color(0xFF4CAF50);
      case 'grey':
        return AppTheme.coolGray;
      default:
        return AppTheme.vibrantViolet;
    }
  }

  Color _getPrioridadeColor() {
    switch (chamado.getPrioridadeColor()) {
      case 'green':
        return const Color(0xFF4CAF50);
      case 'yellow':
        return AppTheme.atomicTangerine;
      case 'orange':
        return AppTheme.peachOrange;
      case 'red':
        return Colors.red;
      default:
        return AppTheme.coolGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        DateFormat('dd/MM/yyyy HH:mm').format(chamado.dataAbertura);

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
                      chamado.titulo,
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
                      chamado.status,
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

              // Linha 2: Descrição
              Text(
                chamado.descricao,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                    chamado.categoria,
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
                          chamado.prioridade,
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
                  Text(
                    chamado.usuarioNome,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
                    Text(
                      'Técnico: ${chamado.tecnicoNome}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

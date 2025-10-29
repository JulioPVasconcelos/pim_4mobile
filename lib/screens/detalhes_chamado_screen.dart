import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chamado.dart';
import '../utils/app_theme.dart';

class DetalhesChamadoScreen extends StatelessWidget {
  final Chamado chamado;

  const DetalhesChamadoScreen({
    super.key,
    required this.chamado,
  });

  Color _getStatusColor() {
    switch (chamado.getStatusColor()) {
      case 'blue':
        return AppTheme.vibrantViolet;
      case 'orange':
        return AppTheme.peachOrange;
      case 'yellow':
        return AppTheme.atomicTangerine;
      case 'green':
        return const Color(0xFF4CAF50);
      case 'grey':
        return AppTheme.coolGray;
      case 'red':
        return Colors.red;
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
        DateFormat('dd/MM/yyyy \'às\' HH:mm').format(chamado.dataAbertura);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
      ),
      body: SafeArea(
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
            // Header com status
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
                  // Status badge
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
                      chamado.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título
                  Text(
                    chamado.titulo,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),

                  // ID do chamado
                  Text(
                    'Chamado #${chamado.id}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppTheme.coolGray),
                  ),
                ],
              ),
            ),

            // Imagem (se houver)
            if (chamado.imagemUrl != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    chamado.imagemUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Informações principais
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  _buildSectionTitle('Descrição'),
                  const SizedBox(height: 8),
                  Text(
                    chamado.descricao,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Informações do chamado
                  _buildSectionTitle('Informações'),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    icon: Icons.category_outlined,
                    label: 'Categoria',
                    value: chamado.categoria,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    icon: Icons.flag_outlined,
                    label: 'Prioridade',
                    value: chamado.prioridade,
                    valueColor: _getPrioridadeColor(),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Aberto em',
                    value: dataFormatada,
                  ),
                  const SizedBox(height: 24),

                  // Pessoas envolvidas
                  _buildSectionTitle('Pessoas'),
                  const SizedBox(height: 12),

                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Solicitante',
                    value: chamado.usuarioNome,
                  ),

                  if (chamado.tecnicoNome != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.engineering_outlined,
                      label: 'Técnico Responsável',
                      value: chamado.tecnicoNome!,
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


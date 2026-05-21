import 'package:afterlife_projects/widgets/cards/afterlife_card.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseSplitter extends StatefulWidget {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>>? existingExpenses;
  final ValueChanged<List<Map<String, dynamic>>> onExpensesChanged;

  const ExpenseSplitter({
    super.key,
    required this.players,
    this.existingExpenses,
    required this.onExpensesChanged,
  });

  @override
  State<ExpenseSplitter> createState() => _ExpenseSplitterState();
}

class _ExpenseSplitterState extends State<ExpenseSplitter> {
  final List<Map<String, dynamic>> _expenses = [];
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpenses != null && widget.existingExpenses!.isNotEmpty) {
      _expenses.addAll(widget.existingExpenses!);
    }
  }

  void _addExpense() {
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    if (_selectedPlayerId == null) return;
    if (_conceptController.text.trim().isEmpty) return;

    setState(() {
      _expenses.add({
        'concept': _conceptController.text.trim(),
        'amount': amount,
        'paidBy': _selectedPlayerId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      _conceptController.clear();
      _amountController.clear();
      _selectedPlayerId = null;
    });
    HapticFeedback.lightImpact();
    widget.onExpensesChanged(_expenses);
  }

  void _removeExpense(int index) {
    setState(() => _expenses.removeAt(index));
    HapticFeedback.mediumImpact();
    widget.onExpensesChanged(_expenses);
  }

  Map<String, double> _calculateDebts() {
    if (_expenses.isEmpty || widget.players.isEmpty) return {};

    final total = _expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as double));
    final share = total / widget.players.length;

    final balances = <String, double>{};
    for (final p in widget.players) {
      balances[p['userId'] ?? p['uid'] ?? ''] = 0.0;
    }

    for (final e in _expenses) {
      final payer = e['paidBy'] as String? ?? '';
      final amount = e['amount'] as double;
      balances[payer] = (balances[payer] ?? 0) + amount;
    }

    final debts = <String, double>{};
    for (final entry in balances.entries) {
      debts[entry.key] = entry.value - share;
    }
    return debts;
  }

  String _playerName(String id) {
    final p = widget.players.firstWhere(
      (x) => (x['userId'] ?? x['uid'] ?? '') == id,
      orElse: () => {'username': 'Desconocido'},
    );
    return p['username'] ?? p['name'] ?? 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    final debts = _calculateDebts();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Añadir gasto
        AfterlifeCard(
          child: Column(
            children: [
              TextField(
                controller: _conceptController,
                decoration: const InputDecoration(
                  labelText: 'Concepto (ej: Botella, Taxi)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))],
                      decoration: const InputDecoration(
                        labelText: 'Cantidad €',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPlayerId,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Pagado por',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: widget.players.map<DropdownMenuItem<String>>((p) {
                        final id = p['userId'] ?? p['uid'] ?? '';
                        return DropdownMenuItem<String>(value: id, child: Text(p['username'] ?? p['name'] ?? '', overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedPlayerId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addExpense,
                  icon: const Icon(Icons.add),
                  label: const Text('AÑADIR GASTO'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Lista de gastos
        if (_expenses.isNotEmpty)
          Column(
            children: _expenses.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return ListTile(
                dense: true,
                leading: const Icon(Icons.receipt, color: AfterlifeColors.cyanBlue),
                title: Text(e['concept'], style: const TextStyle(fontSize: 13)),
                subtitle: Text('Pagado por ${_playerName(e['paidBy'])}', style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(e['amount'] as double).toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                      onPressed: () => _removeExpense(i),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const Divider(),
        // Resumen de deudas
        if (debts.isNotEmpty)
          AfterlifeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RESUMEN', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...debts.entries.map((entry) {
                  final name = _playerName(entry.key);
                  final balance = entry.value;
                  Color color = AfterlifeColors.acidGreen;
                  String text;
                  if (balance > 0.01) {
                    text = 'Le deben ${balance.toStringAsFixed(2)}€';
                    color = AfterlifeColors.acidGreen;
                  } else if (balance < -0.01) {
                    text = 'Debe ${(-balance).toStringAsFixed(2)}€';
                    color = AfterlifeColors.neonPink;
                  } else {
                    text = 'Está a mano';
                    color = AfterlifeColors.cyanBlue;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
                        Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}

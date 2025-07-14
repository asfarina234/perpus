import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/loan_service.dart';

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  final LoanService _loanService = LoanService();
  List<Loan> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    try {
      final data = await _loanService.fetchLoanHistoryAll();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Peminjaman Buku')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _history.isEmpty
              ? const Center(child: Text('Belum ada riwayat peminjaman'))
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.deepPurple.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Jurusan')),
                    DataColumn(label: Text('Gender')),
                    DataColumn(label: Text('Buku')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows:
                      _history.map((loan) {
                        return DataRow(
                          cells: [
                            DataCell(Text(loan.nama)),
                            DataCell(Text(loan.jurusan)),
                            DataCell(Text(loan.gender)),
                            DataCell(Text(loan.judulBuku)),
                            DataCell(Text(loan.status)),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

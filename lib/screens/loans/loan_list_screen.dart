import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/loan_service.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final LoanService _loanService = LoanService();
  List<Loan> _loans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  Future<void> _fetchLoans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loans = await _loanService.fetchLoans();
      setState(() {
        _loans = loans;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Peminjaman Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLoans,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _loans.isEmpty
              ? const Center(child: Text('Tidak ada data peminjaman.'))
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
                  ],
                  rows:
                      _loans.map((loan) {
                        return DataRow(
                          cells: [
                            DataCell(Text(loan.nama)),
                            DataCell(Text(loan.jurusan)),
                            DataCell(Text(loan.gender)),
                            DataCell(Text(loan.judulBuku)),
                          ],
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

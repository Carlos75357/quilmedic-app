import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

class SelectorHospital extends StatefulWidget {
  final List<Hospital> hospitales;
  final Hospital? selectedHospital;
  final Function(Hospital) onHospitalSelected;

  const SelectorHospital({
    super.key,
    required this.hospitales,
    this.selectedHospital,
    required this.onHospitalSelected,
  });

  @override
  State<SelectorHospital> createState() => _SelectorHospitalState();
}

class _SelectorHospitalState extends State<SelectorHospital> {
  late TextEditingController _hospitalesController;
  Hospital? _selectedHospital;

  @override
  void initState() {
    super.initState();
    _hospitalesController = TextEditingController();
    _selectedHospital = widget.selectedHospital;
    
    if (_selectedHospital != null) {
      _hospitalesController.text = _selectedHospital!.nombre;
    }
  }

  @override
  void didUpdateWidget(SelectorHospital oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedHospital != oldWidget.selectedHospital) {
      _selectedHospital = widget.selectedHospital;
      if (_selectedHospital != null) {
        _hospitalesController.text = _selectedHospital!.nombre;
      } else {
        _hospitalesController.clear();
      }
    }
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seleccionar Hospital',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Hospital>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Seleccionar Hospital',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),
              ),
              value: _selectedHospital,
              items: widget.hospitales.map<DropdownMenuItem<Hospital>>(
                (Hospital value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.nombre),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHospital = value;
                    _hospitalesController.text = value.nombre;
                  });
                  widget.onHospitalSelected(value);
                  BlocProvider.of<EscanerBloc>(
                    context,
                  ).add(ElegirHospitalEvent(value));
                }
              },
            ),
            if (widget.hospitales.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'No hay hospitales disponibles',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

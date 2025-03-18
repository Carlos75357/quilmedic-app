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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Seleccionar Hospital',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Hospital>(
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Seleccionar Hospital',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: isSmallScreen ? 18 : 24,
                ),
              ),
              value: _selectedHospital,
              items: widget.hospitales.map<DropdownMenuItem<Hospital>>(
                (Hospital value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value.nombre,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

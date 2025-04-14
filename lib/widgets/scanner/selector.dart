import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/widgets/scanner/selector_locations.dart';

class Selector extends StatefulWidget {
  final List<Hospital> hospitales;
  final List<Location> locations;
  final Hospital? selectedHospital;
  final Function(Hospital) onOptionsSelected;
  final Location? selectedLocation;
  final Function(Location) onLocationSelected;

  const Selector({
    super.key,
    required this.hospitales,
    required this.locations,
    this.selectedHospital,
    required this.onOptionsSelected,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  late TextEditingController _hospitalesController;
  Hospital? _selectedHospital;
  Location? _selectedLocation;
  final TextEditingController _locationsController = TextEditingController();
  
  // Clave para forzar la reconstrucción del widget SelectorLocations
  Key _locationSelectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _hospitalesController = TextEditingController();
    _selectedHospital = widget.selectedHospital;

    if (_selectedHospital != null) {
      _hospitalesController.text = _selectedHospital!.description;
    }
  }

  @override
  void didUpdateWidget(Selector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedHospital = widget.selectedHospital;
    _selectedLocation = widget.selectedLocation;
    
    if (_selectedHospital != null) {
      _hospitalesController.text = _selectedHospital!.description;
    } else {
      _hospitalesController.clear();
    }
    
    if (_selectedLocation != null) {
      _locationsController.text = _selectedLocation!.name;
    } else {
      _locationsController.clear();
    }
  }

  @override
  void dispose() {
    _hospitalesController.dispose();
    _locationsController.dispose();
    _selectedHospital = null;
    _selectedLocation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Seleccionar Almacén',
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
              items:
                  widget.hospitales.map<DropdownMenuItem<Hospital>>((
                    Hospital value,
                  ) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value.description,
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHospital = value;
                    _hospitalesController.text = value.description;
                    
                    // Siempre limpiar la localización seleccionada y regenerar el widget
                    // incluso cuando se selecciona el mismo hospital
                    _selectedLocation = null;
                    _locationsController.clear();
                    
                    // Generar una nueva clave para forzar la reconstrucción del widget
                    _locationSelectorKey = UniqueKey();
                  });
                  
                  widget.onOptionsSelected(value);
                  
                  // Cargar las nuevas localizaciones para el hospital seleccionado
                  BlocProvider.of<EscanerBloc>(
                    context,
                  ).add(ChooseStoreEvent(value));
                  BlocProvider.of<EscanerBloc>(context).add(LoadLocations());
                } else {
                  setState(() {
                    _selectedHospital = null;
                    _hospitalesController.clear();
                    _selectedLocation = null;
                    _locationsController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            if (_selectedHospital != null)
              SelectorLocations(
                key: _locationSelectorKey, // Usar la clave única para forzar la reconstrucción
                locations: widget.locations,
                selectedLocation: _selectedLocation,
                onOptionsSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                    _locationsController.text = location.name;
                  });
                  widget.onLocationSelected(location);
                },
              ),
          ],
        ),
      ),
    );
  }
}

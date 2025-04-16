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

  // Widget para construir el encabezado de cada selector
  Widget _buildSelectorHeader({
    required IconData icon,
    required String title,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectorHeader(
            icon: Icons.store,
            title: 'Almacén',
            theme: theme,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: DropdownButtonFormField<Hospital>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                hintText: 'Seleccionar hospital',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHospital = value;
                    _hospitalesController.text = value.description;
                    
                    _selectedLocation = null;
                    _locationsController.clear();
                  });

                  widget.onOptionsSelected(value);

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
          ),
          if (widget.hospitales.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Text(
                'No hay hospitales disponibles',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),

          if (_selectedHospital != null) ...[
            _buildSelectorHeader(
              icon: Icons.location_on,
              title: 'Ubicación',
              theme: theme,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: BlocConsumer<EscanerBloc, EscanerState>(
                listener: (context, state) {
                  if (state is LocationsCargadas) {
                    setState(() {
                      if (_selectedLocation != null) {
                        final bool exists = state.locations.any((loc) => loc.id == _selectedLocation!.id);
                        if (!exists) {
                          _selectedLocation = null;
                          _locationsController.clear();
                        }
                      }
                    });
                  }
                },
                builder: (context, state) {
                  final bool isLoading = state is EscanerLoading;
                  final bool hasLocations = widget.locations.isNotEmpty;
                  
                  if (isLoading || !hasLocations) {
                    return DropdownButtonFormField<int>(
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        hintText: isLoading ? 'Cargando ubicaciones...' : 'No hay ubicaciones disponibles',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      items: [],
                      onChanged: null,
                    );
                  }

                  return SelectorLocations(
                    locations: widget.locations,
                    selectedLocation: _selectedLocation,
                    enabled: true,
                    onOptionsSelected: (location) {
                      setState(() {
                        _selectedLocation = location;
                        _locationsController.text = location.name;
                      });
                      
                      widget.onLocationSelected(location);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

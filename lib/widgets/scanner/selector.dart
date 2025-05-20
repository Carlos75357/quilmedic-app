import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/widgets/scanner/selector_locations.dart';

/// Widget que permite seleccionar un hospital y una ubicación
/// Muestra dos selectores desplegables para elegir el almacén (hospital)
/// y la ubicación donde se realizará el escaneo de productos

class Selector extends StatefulWidget {
  /// Lista de hospitales disponibles para seleccionar
  final List<Hospital> hospitales;
  /// Lista de ubicaciones disponibles para seleccionar
  final List<Location> locations;
  /// Hospital seleccionado actualmente (puede ser null)
  final Hospital? selectedHospital;
  /// Función que se ejecuta cuando se selecciona un hospital
  final Function(Hospital) onOptionsSelected;
  /// Ubicación seleccionada actualmente (puede ser null)
  final Location? selectedLocation;
  /// Función que se ejecuta cuando se selecciona una ubicación
  final Function(Location) onLocationSelected;

  /// Constructor del widget Selector
  /// @param hospitales Lista de hospitales disponibles
  /// @param locations Lista de ubicaciones disponibles
  /// @param selectedHospital Hospital seleccionado inicialmente
  /// @param onOptionsSelected Función que se ejecuta al seleccionar un hospital
  /// @param selectedLocation Ubicación seleccionada inicialmente
  /// @param onLocationSelected Función que se ejecuta al seleccionar una ubicación
  const Selector({
    super.key,
    required this.hospitales,
    required this.locations,
    this.selectedHospital,
    required this.onOptionsSelected,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  /// Crea el estado mutable para este widget
  @override
  State<Selector> createState() => _SelectorState();
}

/// Estado interno del widget Selector
/// Maneja la lógica de selección y los controladores de texto
class _SelectorState extends State<Selector> {
  /// Controlador para el campo de texto del selector de hospitales
  late TextEditingController _hospitalesController;
  /// Hospital seleccionado actualmente en el estado interno
  Hospital? _selectedHospital;
  /// Ubicación seleccionada actualmente en el estado interno
  Location? _selectedLocation;
  /// Controlador para el campo de texto del selector de ubicaciones
  final TextEditingController _locationsController = TextEditingController();

  /// Inicializa el estado del widget
  /// Configura los controladores y valores iniciales
  @override
  void initState() {
    super.initState();
    _hospitalesController = TextEditingController();
    _selectedHospital = widget.selectedHospital;

    if (_selectedHospital != null) {
      _hospitalesController.text = _selectedHospital!.description;
    }
  }

  /// Se llama cuando el widget padre se reconstruye
  /// Actualiza los valores seleccionados cuando cambian las propiedades
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

    // if (_selectedLocation != null) {
    //   _locationsController.text = _selectedLocation!.name;
    // } else {
    //   _locationsController.clear();
    // }
  }

  /// Libera recursos cuando el widget se elimina
  /// Limpia los controladores de texto y referencias
  @override
  void dispose() {
    _hospitalesController.dispose();
    _locationsController.dispose();
    _selectedHospital = null;
    _selectedLocation = null;
    super.dispose();
  }

  /// Widget para construir el encabezado de cada selector
  /// @param icon Icono a mostrar en el encabezado
  /// @param title Título del selector
  /// @param theme Tema actual de la aplicación
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

  /// Construye la interfaz del selector
  /// Muestra los selectores de hospital y ubicación
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

/// Widget que permite seleccionar una ubicación de una lista desplegable
/// Muestra un menú desplegable con las ubicaciones disponibles y maneja
/// la selección y actualización del valor seleccionado

class SelectorLocations extends StatefulWidget {
  /// Lista de ubicaciones disponibles para seleccionar
  final List<Location> locations;
  /// Ubicación seleccionada actualmente (puede ser null)
  final Location? selectedLocation;
  /// Función que se ejecuta cuando se selecciona una ubicación
  final Function(Location) onOptionsSelected;
  /// Indica si el selector está habilitado para interacción del usuario
  final bool enabled;
  
  /// Constructor del widget SelectorLocations
  /// @param locations Lista de ubicaciones disponibles
  /// @param selectedLocation Ubicación seleccionada inicialmente
  /// @param onOptionsSelected Función que se ejecuta al seleccionar una ubicación
  /// @param enabled Indica si el selector está habilitado (por defecto es true)
  const SelectorLocations({
    super.key,
    required this.locations,
    this.selectedLocation,
    required this.onOptionsSelected,
    this.enabled = true,
  });
  /// Crea el estado mutable para este widget
  @override
  State<SelectorLocations> createState() => _SelectorLocationsState();
}

/// Estado interno del widget SelectorLocations
/// Maneja la lógica de selección y los controladores de texto
class _SelectorLocationsState extends State<SelectorLocations> {
  /// Controlador para el campo de texto del selector de ubicaciones
  late TextEditingController _locationsController;
  /// Ubicación seleccionada actualmente en el estado interno
  Location? _selectedLocation;

  /// Inicializa el estado del widget
  /// Configura el controlador de texto y el valor inicial seleccionado
  @override
  void initState() {
    super.initState();
    _locationsController = TextEditingController();
    _selectedLocation = widget.selectedLocation;

    if (_selectedLocation != null) {
      _locationsController.text = _selectedLocation!.name;
    }
  }

  /// Se llama cuando el widget padre se reconstruye
  /// Actualiza la ubicación seleccionada cuando cambian las propiedades
  /// Maneja cambios en la lista de ubicaciones disponibles
  @override
  void didUpdateWidget(SelectorLocations oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si hay una ubicación seleccionada actualmente, la preservamos
    if (_selectedLocation != null) {
      // Solo actualizamos si el widget.selectedLocation ha cambiado explícitamente
      if (widget.selectedLocation != null && 
          widget.selectedLocation!.id != _selectedLocation!.id) {
        setState(() {
          _selectedLocation = widget.selectedLocation;
          _locationsController.text = _selectedLocation!.name;
        });
      }
      return;
    }
    
    // Si no hay ubicación seleccionada, seguimos la lógica normal
    bool locationsChanged = oldWidget.locations != widget.locations;
    
    if (locationsChanged && widget.selectedLocation == null) {
      setState(() {
        _selectedLocation = null;
        _locationsController.clear();
      });
      return;
    }
    
    setState(() {
      _selectedLocation = widget.selectedLocation;
    
      if (_selectedLocation != null) {
        bool locationExistsInList = widget.locations.any((location) => 
          location.id == _selectedLocation!.id);
        
        if (locationExistsInList) {
          _locationsController.text = _selectedLocation!.name;
        } else if (widget.locations.isNotEmpty) {
          // En lugar de restablecer a null, mantenemos la ubicación si existe en la lista
          _selectedLocation = null;
          _locationsController.clear();
        }
      } else {
        _locationsController.clear();
      }
    });
  }

  /// Libera recursos cuando el widget se elimina
  /// Limpia el controlador de texto
  @override
  void dispose() {
    _locationsController.dispose();
    super.dispose();
  }

  /// Construye la interfaz del selector de ubicaciones
  /// Muestra un menú desplegable con las ubicaciones disponibles
  /// Filtra ubicaciones duplicadas por ID para mostrar solo valores únicos
  @override
  Widget build(BuildContext context) {
    final List<Location> uniqueLocations = [];
    final Set<int> addedIds = {};
    
    for (var location in widget.locations) {
      if (!addedIds.contains(location.id)) {
        uniqueLocations.add(location);
        addedIds.add(location.id);
      }
    }
    
    return DropdownButtonFormField<int>(
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down, 
        size: 20,
        color: widget.enabled ? null : Colors.grey.shade400,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: widget.enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        hintText: 'Seleccionar ubicación',
        hintStyle: TextStyle(
          fontSize: 13, 
          color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
      value: null,
      items: uniqueLocations.isEmpty 
          ? [] 
          : uniqueLocations.map<DropdownMenuItem<int>>(
              (Location location) {
                return DropdownMenuItem(
                  value: location.id,
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
      onChanged: widget.enabled ? (locationId) {
        if (locationId != null) {
          final selectedLocation = uniqueLocations.firstWhere(
            (location) => location.id == locationId,
            orElse: () => uniqueLocations.first,
          );
          
          setState(() {
            _selectedLocation = selectedLocation;
            _locationsController.text = selectedLocation.name;
          });
          
          widget.onOptionsSelected(selectedLocation);
          BlocProvider.of<EscanerBloc>(
            context,
          ).add(ChooseLocationEvent(selectedLocation));
        }
      } : null,
    );
  }
}

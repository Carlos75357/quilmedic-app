import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

class SelectorLocations extends StatefulWidget {
  final List<Location> locations;
  final Location? selectedLocation;
  final Function(Location) onOptionsSelected;
  const SelectorLocations({
    super.key,
    required this.locations,
    this.selectedLocation,
    required this.onOptionsSelected,
  });
  @override
  State<SelectorLocations> createState() => _SelectorLocationsState();
}

class _SelectorLocationsState extends State<SelectorLocations> {
  late TextEditingController _locationsController;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _locationsController = TextEditingController();
    _selectedLocation = widget.selectedLocation;

    if (_selectedLocation != null) {
      _locationsController.text = _selectedLocation!.name;
    }
  }

  @override
  void didUpdateWidget(SelectorLocations oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool locationsChanged = oldWidget.locations != widget.locations;
    
    if (locationsChanged) {
      setState(() {
        _selectedLocation = null;
        _locationsController.clear();
      });
      return;
    }
    
    _selectedLocation = widget.selectedLocation;
    
    if (_selectedLocation != null) {
      bool locationExistsInList = widget.locations.any((location) => 
        location.id == _selectedLocation!.id);
      
      if (locationExistsInList) {
        _locationsController.text = _selectedLocation!.name;
      } else {
        _selectedLocation = null;
        _locationsController.clear();
      }
    } else {
      _locationsController.clear();
    }
  }

  @override
  void dispose() {
    _locationsController.dispose();
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
                    'Seleccionar Ubicación',
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
            DropdownButtonFormField<Location>(
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
                hintText: 'Seleccionar Ubicación',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: isSmallScreen ? 18 : 24,
                ),
              ),
              value: (_selectedLocation != null && 
                     widget.locations.any((loc) => loc.id == _selectedLocation!.id)) 
                     ? _selectedLocation 
                     : null,
              items: widget.locations.isEmpty 
                  ? [] 
                  : widget.locations.map<DropdownMenuItem<Location>>(
                      (Location value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value.name,
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
                    _selectedLocation = value;
                    _locationsController.text = value.name;
                  });
                  widget.onOptionsSelected(value);
                  BlocProvider.of<EscanerBloc>(
                    context,
                  ).add(ChooseLocationEvent(value));
                }
              },
            ),
            const SizedBox(height: 8),
            if (widget.locations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'No hay ubicaciones disponibles',
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

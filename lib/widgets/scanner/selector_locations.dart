import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/domain/location.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';

class SelectorLocations extends StatefulWidget {
  final List<Location> locations;
  final Location? selectedLocation;
  final Function(Location) onOptionsSelected;
  final bool enabled;
  
  const SelectorLocations({
    super.key,
    required this.locations,
    this.selectedLocation,
    required this.onOptionsSelected,
    this.enabled = true,
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
    
    setState(() {
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
    });
  }

  @override
  void dispose() {
    _locationsController.dispose();
    super.dispose();
  }

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
                print('Location: ${location}');
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

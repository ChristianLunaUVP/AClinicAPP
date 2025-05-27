// lib/pages/patients_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:sqflite/sqflite.dart'; // Para DatabaseException
import '../models/patient.dart';
import '../services/database_service.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final DatabaseService _dbService = DatabaseService.instance;
  late Future<List<Patient>> _patientsFuture;

  // Controladores para el formulario
  final _nameController = TextEditingController();
  final _dobController = TextEditingController(); // Date of Birth
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender; // Para el Dropdown de género
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final List<String> _genderOptions = ['Masculino', 'Femenino', 'Otro', 'Prefiero no decirlo'];

  @override
  void initState() {
    super.initState();
    _refreshPatientsList();
  }

  void _refreshPatientsList() {
    setState(() {
      _patientsFuture = _dbService.getPatients();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _clearFormControllers() {
    _nameController.clear();
    _dobController.clear();
    _contactController.clear();
    _addressController.clear();
    _selectedGender = null;
    _emergencyContactNameController.clear();
    _emergencyContactPhoneController.clear();
    _bloodTypeController.clear();
    _allergiesController.clear();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    DateTime initial = DateTime.now();
    if (_dobController.text.isNotEmpty) {
      try {
        initial = DateFormat('yyyy-MM-dd').parse(_dobController.text);
      } catch (_) {} // Ignorar error de parseo y usar DateTime.now()
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _showPatientFormDialog({Patient? patient}) async {
    if (patient != null) {
      _nameController.text = patient.name;
      _dobController.text = patient.dateOfBirth;
      _contactController.text = patient.contactInfo;
      _addressController.text = patient.address ?? '';
      _selectedGender = _genderOptions.contains(patient.gender) ? patient.gender : null;
      _emergencyContactNameController.text = patient.emergencyContactName ?? '';
      _emergencyContactPhoneController.text = patient.emergencyContactPhone ?? '';
      _bloodTypeController.text = patient.bloodType ?? '';
      _allergiesController.text = patient.allergies ?? '';
    } else {
      _clearFormControllers();
    }
    // Para asegurar que el Dropdown se reconstruya con el valor correcto al editar
    // Si no se hace, puede que no muestre el valor preseleccionado correctamente la primera vez.
    // Esto se puede mejorar usando un StatefulWidget para el diálogo si se vuelve muy complejo.
    if (mounted) setState((){});


    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Usar StatefulBuilder para que el Dropdown dentro del AlertDialog pueda actualizar su estado interno
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: Text(patient == null ? 'Añadir Paciente' : 'Editar Paciente'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre Completo*', icon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese el nombre' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Fecha de Nacimiento*',
                          icon: const Icon(Icons.cake_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month_outlined),
                            onPressed: () => _pickDateOfBirth(dialogContext),
                          )
                        ),
                        readOnly: true,
                        validator: (value) => (value == null || value.isEmpty) ? 'Seleccione la fecha' : null,
                      ),
                      const SizedBox(height: 16),
                       DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Género',
                          icon: Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Seleccionar género'),
                        items: _genderOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          stfSetState(() { // Actualiza el estado del StatefulBuilder
                            _selectedGender = newValue;
                          });
                           // Y también el estado de la página si es necesario (aunque aquí StatefulBuilder es suficiente)
                           setState(() {
                             _selectedGender = newValue;
                           });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contacto Principal (Tel/Email)*', icon: Icon(Icons.contact_phone_outlined), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese información de contacto' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Dirección', icon: Icon(Icons.home_work_outlined), border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactNameController,
                        decoration: const InputDecoration(labelText: 'Nombre Contacto Emergencia', icon: Icon(Icons.health_and_safety_outlined), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emergencyContactPhoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono Contacto Emergencia', icon: Icon(Icons.phone_in_talk_outlined), border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                       TextFormField(
                        controller: _bloodTypeController,
                        decoration: const InputDecoration(labelText: 'Tipo de Sangre', icon: Icon(Icons.bloodtype_outlined), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: const InputDecoration(labelText: 'Alergias', icon: Icon(Icons.healing_outlined), border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _clearFormControllers();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newPatient = Patient(
                        id: patient?.id,
                        name: _nameController.text.trim(),
                        dateOfBirth: _dobController.text,
                        contactInfo: _contactController.text.trim(),
                        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
                        gender: _selectedGender,
                        emergencyContactName: _emergencyContactNameController.text.trim().isNotEmpty ? _emergencyContactNameController.text.trim() : null,
                        emergencyContactPhone: _emergencyContactPhoneController.text.trim().isNotEmpty ? _emergencyContactPhoneController.text.trim() : null,
                        bloodType: _bloodTypeController.text.trim().isNotEmpty ? _bloodTypeController.text.trim() : null,
                        allergies: _allergiesController.text.trim().isNotEmpty ? _allergiesController.text.trim() : null,
                      );

                      try {
                        if (patient == null) {
                          await _dbService.addPatient(newPatient);
                          if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Paciente añadido'), backgroundColor: Colors.green));
                        } else {
                          await _dbService.updatePatient(newPatient);
                          if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Paciente actualizado'), backgroundColor: Colors.blue));
                        }
                        _refreshPatientsList();
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        _clearFormControllers();
                      } catch (e) {
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _deletePatient(int patientId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres eliminar este paciente?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _dbService.deletePatient(patientId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente eliminado'), backgroundColor: Colors.redAccent));
        _refreshPatientsList();
      } on DatabaseException catch (e) {
        String errorMessage = 'Error al eliminar paciente.';
        if (e.isForeignKeyConstraintError()) {
          errorMessage = 'No se puede eliminar: el paciente tiene citas asociadas.';
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.orangeAccent));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Patient>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No hay pacientes registrados.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Toca el botón + para añadir uno.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final patients = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P', style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nac: ${patient.dateOfBirth} - ${patient.gender ?? "No espec."}', style: TextStyle(color: Colors.grey[700])),
                      Text('Contacto: ${patient.contactInfo}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      if(patient.address != null && patient.address!.isNotEmpty)
                         Text('Dir: ${patient.address}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  isThreeLine: true, // Ajusta según la cantidad de info
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueGrey[600]),
                        tooltip: 'Editar',
                        onPressed: () => _showPatientFormDialog(patient: patient),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                        tooltip: 'Eliminar',
                        onPressed: () => _deletePatient(patient.id!),
                      ),
                    ],
                  ),
                  onTap: () => _showPatientFormDialog(patient: patient),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPatientFormDialog(),
        tooltip: 'Añadir Paciente',
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Añadir Paciente'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

extension on DatabaseException {
  bool isForeignKeyConstraintError() {
    // Puedes personalizar la lógica según el mensaje de error de tu base de datos
    // Por ejemplo, para SQLite:
    return this.toString().contains('FOREIGN KEY constraint failed');
  }
}
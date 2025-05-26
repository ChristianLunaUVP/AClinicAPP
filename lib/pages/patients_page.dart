// lib/pages/patients_page.dart
import 'package:flutter/material.dart';
import '../models/patient.dart'; // Ajusta la ruta
import '../services/database_service.dart'; // Ajusta la ruta
import 'package:intl/intl.dart'; // Para el DatePicker

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
  final _formKey = GlobalKey<FormState>();

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
    super.dispose();
  }

  void _clearFormControllers() {
    _nameController.clear();
    _dobController.clear();
    _contactController.clear();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    } else {
      _clearFormControllers();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(patient == null ? 'Añadir Paciente' : 'Editar Paciente'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre Completo', icon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese el nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      icon: const Icon(Icons.cake_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () => _pickDateOfBirth(dialogContext),
                      )
                    ),
                    readOnly: true, // Para forzar el uso del DatePicker
                    validator: (value) => (value == null || value.isEmpty) ? 'Seleccione la fecha de nacimiento' : null,
                  ),
                   const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Información de Contacto (Tel/Email)', icon: Icon(Icons.contact_phone_outlined), border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese información de contacto' : null,
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
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                 if (_formKey.currentState!.validate()) {
                  final newPatient = Patient(
                    id: patient?.id,
                    name: _nameController.text.trim(),
                    dateOfBirth: _dobController.text,
                    contactInfo: _contactController.text.trim(),
                  );

                  if (patient == null) {
                    await _dbService.addPatient(newPatient);
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paciente añadido exitosamente'), backgroundColor: Colors.green),
                    );
                  } else {
                    await _dbService.updatePatient(newPatient);
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paciente actualizado exitosamente'), backgroundColor: Colors.blue),
                    );
                  }
                  _refreshPatientsList();
                  Navigator.of(dialogContext).pop();
                  _clearFormControllers();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePatient(int patientId) async {
     final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres eliminar este paciente? Esto también podría eliminar citas asociadas.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmDelete == true) {
      await _dbService.deletePatient(patientId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente eliminado'), backgroundColor: Colors.redAccent),
      );
      _refreshPatientsList();
    }
  }


  @override
  Widget build(BuildContext context) {
    // Similar al build de DoctorsPage, pero usando _patientsFuture y mostrando datos de Patient
    // Recuerda implementar el FutureBuilder, ListView.builder, Cards, ListTiles, etc.
    // Y el FloatingActionButton para llamar a _showPatientFormDialog()
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
                    child: Text(patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P', style: TextStyle(color: Theme.of(context).primaryColorDark)),
                  ),
                  title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Nac: ${patient.dateOfBirth}\nContacto: ${patient.contactInfo}'),
                  isThreeLine: true,
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
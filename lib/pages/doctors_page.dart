// lib/pages/doctors_page.dart
import 'package:flutter/material.dart';
import '../models/doctor.dart'; // Ajusta la ruta a tu modelo Doctor
import '../services/database_service.dart'; // Ajusta la ruta a tu DatabaseService

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final DatabaseService _dbService = DatabaseService.instance;
  late Future<List<Doctor>> _doctorsFuture;

  // Controladores para los campos del formulario
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Para validación del formulario

  @override
  void initState() {
    super.initState();
    _refreshDoctorsList();
  }

  void _refreshDoctorsList() {
    setState(() {
      _doctorsFuture = _dbService.getDoctors();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  void _clearFormControllers() {
    _nameController.clear();
    _specialtyController.clear();
  }

  Future<void> _showDoctorFormDialog({Doctor? doctor}) async {
    if (doctor != null) {
      _nameController.text = doctor.name;
      _specialtyController.text = doctor.specialty;
    } else {
      _clearFormControllers();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón para cerrar
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(doctor == null ? 'Añadir Doctor' : 'Editar Doctor'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Doctor',
                      icon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _specialtyController,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      icon: Icon(Icons.star_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, ingrese la especialidad';
                      }
                      return null;
                    },
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
                  final newDoctor = Doctor(
                    id: doctor?.id, // Mantener el ID si es una edición
                    name: _nameController.text.trim(),
                    specialty: _specialtyController.text.trim(),
                  );

                  if (doctor == null) {
                    await _dbService.addDoctor(newDoctor);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Doctor añadido exitosamente'), backgroundColor: Colors.green),
                    );
                  } else {
                    await _dbService.updateDoctor(newDoctor);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Doctor actualizado exitosamente'), backgroundColor: Colors.blue),
                    );
                  }
                  _refreshDoctorsList();
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

  Future<void> _deleteDoctor(int doctorId) async {
    // Confirmación antes de borrar
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres eliminar este doctor? Esto también podría eliminar citas asociadas.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _dbService.deleteDoctor(doctorId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor eliminado'), backgroundColor: Colors.redAccent),
      );
      _refreshDoctorsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture,
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
                  Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No hay doctores registrados.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Toca el botón + para añadir uno.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final doctors = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: CircleAvatar( // Icono representativo
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D', style: TextStyle(color: Theme.of(context).primaryColorDark)),
                  ),
                  title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(doctor.specialty),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blueGrey[600]),
                        tooltip: 'Editar',
                        onPressed: () => _showDoctorFormDialog(doctor: doctor),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                        tooltip: 'Eliminar',
                        onPressed: () => _deleteDoctor(doctor.id!),
                      ),
                    ],
                  ),
                  onTap: () { // Opcional: podría mostrar una vista de detalle del doctor
                     _showDoctorFormDialog(doctor: doctor); // O abrir un diálogo de edición directamente
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDoctorFormDialog(),
        tooltip: 'Añadir Doctor',
        icon: const Icon(Icons.add),
        label: const Text('Añadir Doctor'),
        backgroundColor: Theme.of(context).colorScheme.secondary, // Usar color secundario del tema
      ),
    );
  }
}
// lib/pages/doctors_page.dart
import 'package:flutter/material.dart';
import '../models/doctor.dart'; // Ajusta la ruta a tu modelo Doctor
import '../services/database_service.dart'; // Ajusta la ruta a tu DatabaseService
import 'package:sqflite/sqflite.dart'; 

// Constante para la validación de email a nivel de archivo (patrón completo en una sola cadena)
final String _kDoctorEmailValidationPattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*)@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])";



class DoctorsPage extends StatefulWidget {
  const DoctorsPage({super.key});

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final DatabaseService _dbService = DatabaseService.instance;
  late Future<List<Doctor>> _doctorsFuture;

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _officeHoursController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _phoneNumberController.dispose();
    _emailController.dispose();
    _officeHoursController.dispose();
    super.dispose();
  }

  void _clearFormControllers() {
    _nameController.clear();
    _specialtyController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _officeHoursController.clear();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; 
    }
    final regex = RegExp(_kDoctorEmailValidationPattern); // Usar la constante renombrada
    if (!regex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  Future<void> _showDoctorFormDialog({Doctor? doctor}) async {
    if (doctor != null) {
      _nameController.text = doctor.name;
      _specialtyController.text = doctor.specialty;
      _phoneNumberController.text = doctor.phoneNumber ?? '';
      _emailController.text = doctor.email ?? '';
      _officeHoursController.text = doctor.officeHours ?? '';
    } else {
      _clearFormControllers();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Estilos de AlertDialog (backgroundColor, shape, titleTextStyle) aplicados por el Tema
          title: Text(doctor == null ? 'Añadir Doctor' : 'Editar Doctor'),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Ajustar padding
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration( // Estilo de InputDecoration aplicado por el Tema
                        labelText: 'Nombre del Doctor*',
                        prefixIcon: Icon(Icons.person_outline, color: Theme.of(dialogContext).colorScheme.primary),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese el nombre' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _specialtyController,
                      decoration: InputDecoration(
                        labelText: 'Especialidad*',
                        prefixIcon: Icon(Icons.star_outline, color: Theme.of(dialogContext).colorScheme.primary),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese la especialidad' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número de Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined, color: Theme.of(dialogContext).colorScheme.primary),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: Theme.of(dialogContext).colorScheme.primary),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _officeHoursController,
                      decoration: InputDecoration(
                        labelText: 'Horario de Oficina',
                        hintText: 'Ej: Lun-Vie 9am-5pm',
                        prefixIcon: Icon(Icons.access_time_outlined, color: Theme.of(dialogContext).colorScheme.primary),
                      ),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16), // Ajustar padding de acciones
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton( // Estilo de TextButton aplicado por el Tema
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearFormControllers();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon( // Estilo de ElevatedButton aplicado por el Tema
              icon: const Icon(Icons.save_alt_outlined, size: 18),
              label: const Text('Guardar'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newDoctor = Doctor(
                    id: doctor?.id,
                    name: _nameController.text.trim(),
                    specialty: _specialtyController.text.trim(),
                    phoneNumber: _phoneNumberController.text.trim().isNotEmpty ? _phoneNumberController.text.trim() : null,
                    email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
                    officeHours: _officeHoursController.text.trim().isNotEmpty ? _officeHoursController.text.trim() : null,
                  );
                  try {
                    if (doctor == null) {
                      await _dbService.addDoctor(newDoctor);
                      if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Doctor añadido'), backgroundColor: Colors.green));
                    } else {
                      await _dbService.updateDoctor(newDoctor);
                      if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Doctor actualizado'), backgroundColor: Colors.blueAccent));
                    }
                    _refreshDoctorsList();
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    _clearFormControllers();
                  } on DatabaseException catch (e) {
                    String errorMessage = 'Error al guardar.';
                    if (e.isUniqueConstraintError() && (e.toString().toLowerCase().contains('email'))) {
                       errorMessage = 'El email ya existe.';
                    } else if (e.isUniqueConstraintError()){
                       errorMessage = 'Error de unicidad. Verifique los datos.';
                    }
                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.orangeAccent));
                  } catch (e) {
                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDoctor(int doctorId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres eliminar este doctor?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _dbService.deleteDoctor(doctorId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor eliminado'), backgroundColor: Colors.red));
        _refreshDoctorsList();
      } on DatabaseException catch (e) {
        String errorMessage = 'Error al eliminar.';
        if (e.isForeignKeyConstraintError()) {
          errorMessage = 'No se puede eliminar: Doctor con citas asociadas.';
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.orangeAccent));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Widget _buildDoctorInfoRow(BuildContext context, IconData icon, String? text, {Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar es manejado por MainScreen
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error al cargar doctores: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
              )
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services_outlined, size: 80, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)),
                    const SizedBox(height: 20),
                    Text('No hay doctores registrados.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8))),
                    const SizedBox(height: 8),
                    Text('Toca el botón + para añadir el primero.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6))),
                  ],
                ),
              ),
            );
          }

          final doctors = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            itemCount: doctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                // Estilo de Card (elevation, shape, color) aplicado por el Tema
                clipBehavior: Clip.antiAlias, // Para que el InkWell no se salga de los bordes redondeados
                child: InkWell( // Para dar efecto visual al tocar
                  onTap: () => _showDoctorFormDialog(doctor: doctor),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                            style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor.name, style: Theme.of(context).textTheme.titleLarge),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                                child: Text(
                                  doctor.specialty,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              _buildDoctorInfoRow(context, Icons.phone_outlined, doctor.phoneNumber, iconColor: Theme.of(context).colorScheme.secondary),
                              _buildDoctorInfoRow(context, Icons.email_outlined, doctor.email, iconColor: Theme.of(context).colorScheme.secondary),
                              _buildDoctorInfoRow(context, Icons.access_time_outlined, doctor.officeHours, iconColor: Theme.of(context).colorScheme.secondary),
                            ],
                          ),
                        ),
                        Column( // Para los botones de acción
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             IconButton(
                                icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                tooltip: 'Editar',
                                onPressed: () => _showDoctorFormDialog(doctor: doctor),
                                splashRadius: 20,
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error.withOpacity(0.8)),
                                tooltip: 'Eliminar',
                                onPressed: () => _deleteDoctor(doctor.id!),
                                splashRadius: 20,
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Estilo de FAB aplicado por el Tema
        onPressed: () => _showDoctorFormDialog(),
        tooltip: 'Añadir Doctor',
        icon: const Icon(Icons.add),
        label: const Text('Añadir Doctor'),
      ),
    );
  }
}

extension on DatabaseException {
  bool isForeignKeyConstraintError() {
    // Implement your logic here, for now return false by default
    return false;
  }
}
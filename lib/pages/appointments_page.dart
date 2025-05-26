import 'package:flutter/material.dart';
// Asegúrate de que la ruta a tus modelos y servicios sea correcta
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Para los desplegables en el diálogo de añadir cita
  List<Doctor> _doctorsList = [];
  List<Patient> _patientsList = [];

  // Para el formulario de añadir cita
  Doctor? _selectedDoctor;
  Patient? _selectedPatient;
  final TextEditingController _appointmentDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedStatus = 'scheduled'; // Estado por defecto

  final List<String> _appointmentStatuses = ['scheduled', 'completed', 'canceled'];

  @override
  void initState() {
    super.initState();
    _loadDoctorsAndPatients();
  }

  @override
  void dispose() {
    _appointmentDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorsAndPatients() async {
    // Carga doctores y pacientes para los Dropdowns del diálogo
    // No es necesario llamar a setState aquí si no se usan directamente en el build principal
    // pero sí es crucial que estén cargados antes de mostrar el diálogo.
    _doctorsList = await _databaseService.getDoctors();
    _patientsList = await _databaseService.getPatients();
    if (mounted) { // Asegura que el widget sigue montado antes de llamar a setState
      setState(() {}); // Para actualizar los dropdowns si el diálogo se muestra inmediatamente
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Opcionalmente, puedes pedir la hora también
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
        setState(() {
          _appointmentDateController.text = formattedDateTime;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) { // Corregido: BuildContext context
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Citas Clínica'),
      ),
      floatingActionButton: _addAppointmentButton(context), // Pasar context
      body: _appointmentList(),
    );
  }

  Widget _addAppointmentButton(BuildContext dialogContext) { // Renombrar context para evitar shadowing
    return FloatingActionButton(
      onPressed: () {
        // Resetear campos del formulario antes de mostrar el diálogo
        _selectedDoctor = null;
        _selectedPatient = null;
        _appointmentDateController.clear();
        _reasonController.clear();
        _selectedStatus = 'scheduled';

        // Asegurarse de que las listas de doctores y pacientes estén cargadas
        if (_doctorsList.isEmpty && _patientsList.isEmpty) {
           // Recargar por si acaso, aunque initState debería haberlo hecho
          _loadDoctorsAndPatients().then((_) {
            if (mounted) setState(() {}); // Actualizar para los dropdowns
             _showAddAppointmentDialog(dialogContext);
          });
        } else {
          if (mounted) setState(() {}); // Para refrescar los valores de los dropdowns por si acaso
          _showAddAppointmentDialog(dialogContext);
        }
      },
      child: const Icon(Icons.add),
    );
  }
  
  void _showAddAppointmentDialog(BuildContext dialogContext) {
     showDialog(
          context: dialogContext, // Usar el context pasado
          builder: (_) => AlertDialog(
            title: const Text('Agendar Nueva Cita'),
            content: SingleChildScrollView( // Para evitar overflow si hay muchos campos
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown para Pacientes
                  if (_patientsList.isNotEmpty)
                    DropdownButtonFormField<Patient>(
                      decoration: const InputDecoration(labelText: 'Paciente'),
                      value: _selectedPatient,
                      hint: const Text('Seleccionar Paciente'),
                      items: _patientsList.map((patient) {
                        return DropdownMenuItem<Patient>(
                          value: patient,
                          child: Text(patient.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPatient = value;
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un paciente' : null,
                    )
                  else
                    const Text('No hay pacientes. Añada pacientes primero.'),
                  
                  const SizedBox(height: 10),

                  // Dropdown para Doctores
                  if (_doctorsList.isNotEmpty)
                    DropdownButtonFormField<Doctor>(
                      decoration: const InputDecoration(labelText: 'Doctor'),
                      value: _selectedDoctor,
                      hint: const Text('Seleccionar Doctor'),
                      items: _doctorsList.map((doctor) {
                        return DropdownMenuItem<Doctor>(
                          value: doctor,
                          child: Text(doctor.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDoctor = value;
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un doctor' : null,
                    )
                  else
                    const Text('No hay doctores. Añada doctores primero.'),

                  const SizedBox(height: 10),

                  // Campo de Fecha y Hora
                  TextField(
                    controller: _appointmentDateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha y Hora de la Cita',
                      hintText: 'YYYY-MM-DD HH:MM',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(dialogContext), // Usar el context del diálogo
                      ),
                    ),
                    readOnly: true, // Para forzar el uso del picker
                  ),
                  const SizedBox(height: 10),

                  // Campo de Razón
                  TextField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Razón de la Cita',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),

                  // Dropdown para Estado
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Estado'),
                    value: _selectedStatus,
                    items: _appointmentStatuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(), // Usar el context del diálogo
                child: const Text('Cancelar'),
              ),
              MaterialButton(
                color: Theme.of(dialogContext).primaryColor,
                onPressed: () async {
                  if (_selectedPatient != null &&
                      _selectedDoctor != null &&
                      _appointmentDateController.text.isNotEmpty &&
                      _selectedStatus != null) {
                    
                    final newAppointment = Appointment(
                      patientId: _selectedPatient!.id!,
                      doctorId: _selectedDoctor!.id!,
                      appointmentDate: _appointmentDateController.text,
                      reason: _reasonController.text,
                      status: _selectedStatus!,
                    );
                    await _databaseService.addAppointment(newAppointment);
                    setState(() {
                      // Limpiar campos después de guardar
                      _selectedDoctor = null;
                      _selectedPatient = null;
                      _appointmentDateController.clear();
                      _reasonController.clear();
                      _selectedStatus = 'scheduled';
                    });
                    Navigator.of(dialogContext).pop(); // Cerrar diálogo
                    // La lista se actualizará automáticamente gracias al FutureBuilder
                  } else {
                    // Mostrar algún feedback al usuario si faltan campos
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Por favor, complete todos los campos requeridos.'))
                    );
                  }
                },
                child: const Text(
                  'Guardar Cita',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
  }

  Widget _appointmentList() {
    return FutureBuilder<List<dynamic>>(
      // Future.wait para obtener todas las listas necesarias a la vez
      future: Future.wait([
        _databaseService.getAppointments(),
        _databaseService.getDoctors(), // Necesitamos doctores para mostrar nombres
        _databaseService.getPatients(), // Necesitamos pacientes para mostrar nombres
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay citas programadas.'));
        }

        final List<Appointment> appointments = snapshot.data![0] as List<Appointment>;
        final List<Doctor> doctors = snapshot.data![1] as List<Doctor>;
        final List<Patient> patients = snapshot.data![2] as List<Patient>;

        // Funciones helper para obtener nombres a partir de IDs
        String getDoctorName(int doctorId) {
          final doctor = doctors.firstWhere((doc) => doc.id == doctorId,
              orElse: () => Doctor(id: 0, name: 'Desconocido', specialty: 'N/A'));
          return doctor.name;
        }

        String getPatientName(int patientId) {
          final patient = patients.firstWhere((pat) => pat.id == patientId,
              orElse: () => Patient(id: 0, name: 'Desconocido', dateOfBirth: '', contactInfo: ''));
          return patient.name;
        }
        
        if (appointments.isEmpty) {
          return const Center(child: Text('No hay citas. ¡Añade una!'));
        }

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            Appointment appointment = appointments[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(
                  'Cita: ${getPatientName(appointment.patientId)} con Dr. ${getDoctorName(appointment.doctorId)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Fecha: ${appointment.appointmentDate}\nRazón: ${appointment.reason.isNotEmpty ? appointment.reason : "No especificada"}\nEstado: ${appointment.status}'),
                isThreeLine: true, // Permite más espacio para el subtítulo
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    // Confirmación antes de borrar
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        title: const Text('Confirmar Borrado'),
                        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true && appointment.id != null) {
                      await _databaseService.deleteAppointment(appointment.id!);
                      setState(() {}); // Para que FutureBuilder recargue la lista
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cita eliminada'))
                      );
                    }
                  },
                ),
                // Podrías añadir un onTap para ver detalles o editar
                onTap: () {
                  // Lógica para editar o ver detalles de la cita
                  // Por ejemplo, podrías abrir un diálogo similar al de "añadir cita" pero pre-llenado.
                },
              ),
            );
          },
        );
      },
    );
  }
}
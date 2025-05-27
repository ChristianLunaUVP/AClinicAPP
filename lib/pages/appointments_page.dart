// lib/pages/appointments_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final DatabaseService _dbService = DatabaseService.instance;

  List<Doctor> _doctorsList = [];
  List<Patient> _patientsList = [];

  // Para el formulario de añadir/editar cita
  Doctor? _selectedDialogDoctor;
  Patient? _selectedDialogPatient;
  final _appointmentDateController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedDialogStatus = 'scheduled';
  // Nuevos campos para el formulario de citas
  String? _selectedDialogAppointmentType;
  final _notesController = TextEditingController();
  final _durationMinutesController = TextEditingController();
  bool _isDialogAppointmentConfirmed = false;


  final _formKey = GlobalKey<FormState>();
  final List<String> _appointmentStatuses = ['scheduled', 'completed', 'canceled', 'rescheduled', 'no-show'];
  final List<String> _appointmentTypes = ['Consulta', 'Seguimiento', 'Estudio', 'Urgencia', 'Otro'];


  @override
  void initState() {
    super.initState();
    _loadDoctorsAndPatientsForDialog();
  }

  @override
  void dispose() {
    _appointmentDateController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    _durationMinutesController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorsAndPatientsForDialog() async {
    _doctorsList = await _dbService.getDoctors();
    _patientsList = await _dbService.getPatients();
    if (mounted) setState(() {});
  }

  void _clearAppointmentFormFields() {
    _selectedDialogDoctor = null;
    _selectedDialogPatient = null;
    _appointmentDateController.clear();
    _reasonController.clear();
    _selectedDialogStatus = 'scheduled';
    _selectedDialogAppointmentType = null;
    _notesController.clear();
    _durationMinutesController.clear();
    _isDialogAppointmentConfirmed = false;
  }

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime initialDate = DateTime.now();
     if (_appointmentDateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd HH:mm').parse(_appointmentDateController.text);
      } catch (_) {}
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
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
        setState(() { // Actualiza el estado de la página si es necesario
          _appointmentDateController.text = formattedDateTime;
        });
      }
    }
  }

  Future<void> _showAppointmentFormDialog({Appointment? appointment}) async {
    if (appointment != null) {
      // Pre-llenar para editar
      _selectedDialogPatient = _patientsList.firstWhere(
        (p) => p.id == appointment.patientId,
        orElse: () => _patientsList.isNotEmpty
            ? _patientsList.first
            : Patient(id: 0, name: 'Desconocido', dateOfBirth: '', contactInfo: ''),
      );
      _selectedDialogDoctor = _doctorsList.firstWhere(
        (d) => d.id == appointment.doctorId,
        orElse: () => _doctorsList.isNotEmpty
            ? _doctorsList.first
            : Doctor(id: 0, name: 'Desconocido', specialty: 'N/A'),
      );
      _appointmentDateController.text = appointment.appointmentDate;
      _reasonController.text = appointment.reason;
      _selectedDialogStatus = _appointmentStatuses.contains(appointment.status) ? appointment.status : 'scheduled';
      _selectedDialogAppointmentType = _appointmentTypes.contains(appointment.appointmentType) ? appointment.appointmentType : null;
      _notesController.text = appointment.notes ?? '';
      _durationMinutesController.text = appointment.durationMinutes?.toString() ?? '';
      _isDialogAppointmentConfirmed = appointment.isConfirmed ?? false;
    } else {
      _clearAppointmentFormFields();
    }
    if (mounted) setState((){});


    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Usar StatefulBuilder para manejar el estado interno del diálogo (Switch, Dropdowns)
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: Text(appointment == null ? 'Agendar Nueva Cita' : 'Editar Cita'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Patient>(
                        value: _selectedDialogPatient,
                        decoration: const InputDecoration(labelText: 'Paciente*', icon: Icon(Icons.person_search_outlined), border: OutlineInputBorder()),
                        hint: const Text('Seleccionar Paciente'),
                        items: _patientsList.map((patient) => DropdownMenuItem<Patient>(value: patient, child: Text(patient.name))).toList(),
                        onChanged: (value) => stfSetState(() => _selectedDialogPatient = value),
                        validator: (value) => value == null ? 'Seleccione un paciente' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Doctor>(
                        value: _selectedDialogDoctor,
                        decoration: const InputDecoration(labelText: 'Doctor*', icon: Icon(Icons.medical_services_outlined), border: OutlineInputBorder()),
                        hint: const Text('Seleccionar Doctor'),
                        items: _doctorsList.map((doctor) => DropdownMenuItem<Doctor>(value: doctor, child: Text(doctor.name))).toList(),
                        onChanged: (value) => stfSetState(() => _selectedDialogDoctor = value),
                        validator: (value) => value == null ? 'Seleccione un doctor' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _appointmentDateController,
                        decoration: InputDecoration(labelText: 'Fecha y Hora*', icon: const Icon(Icons.calendar_month_outlined), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () => _pickDateTime(dialogContext))),
                        readOnly: true,
                        validator: (value) => (value == null || value.isEmpty) ? 'Seleccione fecha y hora' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDialogAppointmentType,
                        decoration: const InputDecoration(labelText: 'Tipo de Cita', icon: Icon(Icons.category_outlined), border: OutlineInputBorder()),
                        hint: const Text('Seleccionar tipo'),
                        items: _appointmentTypes.map((type) => DropdownMenuItem<String>(value: type, child: Text(type))).toList(),
                        onChanged: (value) => stfSetState(() => _selectedDialogAppointmentType = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(labelText: 'Razón Principal*', icon: Icon(Icons.short_text_outlined), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese la razón' : null,
                      ),
                      const SizedBox(height: 12),
                       TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notas Adicionales', icon: Icon(Icons.notes_outlined), border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                       TextFormField(
                        controller: _durationMinutesController,
                        decoration: const InputDecoration(labelText: 'Duración (minutos)', icon: Icon(Icons.timer_outlined), border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDialogStatus,
                        decoration: const InputDecoration(labelText: 'Estado de la Cita*', icon: Icon(Icons.check_circle_outline), border: OutlineInputBorder()),
                        items: _appointmentStatuses.map((status) => DropdownMenuItem<String>(value: status, child: Text(status))).toList(),
                        onChanged: (value) => stfSetState(() => _selectedDialogStatus = value),
                        validator: (value) => value == null ? 'Seleccione un estado' : null,
                      ),
                       SwitchListTile(
                        title: const Text('Cita Confirmada'),
                        value: _isDialogAppointmentConfirmed,
                        onChanged: (bool value) => stfSetState(() => _isDialogAppointmentConfirmed = value),
                        secondary: Icon(_isDialogAppointmentConfirmed ? Icons.event_available : Icons.event_busy),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(appointment == null ? 'Agendar' : 'Actualizar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(dialogContext).primaryColor, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newAppointment = Appointment(
                        id: appointment?.id,
                        patientId: _selectedDialogPatient!.id!,
                        doctorId: _selectedDialogDoctor!.id!,
                        appointmentDate: _appointmentDateController.text,
                        reason: _reasonController.text.trim(),
                        status: _selectedDialogStatus!,
                        appointmentType: _selectedDialogAppointmentType,
                        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                        durationMinutes: _durationMinutesController.text.isNotEmpty ? int.tryParse(_durationMinutesController.text) : null,
                        isConfirmed: _isDialogAppointmentConfirmed,
                      );
                      try {
                        if (appointment == null) {
                          await _dbService.addAppointment(newAppointment);
                           if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Cita agendada'), backgroundColor: Colors.green));
                        } else {
                          await _dbService.updateAppointment(newAppointment);
                          if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Cita actualizada'), backgroundColor: Colors.blue));
                        }
                        _refreshAppointmentsPageData(); // Llama a setState en la página principal
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                         // _clearAppointmentFormFields(); // Limpiar después de guardar
                      } catch (e) {
                        if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Error al guardar cita: $e'), backgroundColor: Colors.red));
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

  void _refreshAppointmentsPageData() {
    // Esta función ahora solo necesita llamar a setState para que el FutureBuilder se reconstruya.
    // Los datos de doctores y pacientes ya se cargan en initState o cuando se abre el diálogo.
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteAppointment(int appointmentId) async {
     final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmDelete == true) {
      try {
        await _dbService.deleteAppointment(appointmentId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita eliminada'), backgroundColor: Colors.redAccent));
        _refreshAppointmentsPageData();
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar cita: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _dbService.getAppointments(),
          _dbService.getDoctors(), // Re-fetch for consistency, though _doctorsList might be up-to-date
          _dbService.getPatients(),// Re-fetch for consistency
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
          // Usar las listas de doctores y pacientes del snapshot para la visualización
          final List<Doctor> currentDoctors = snapshot.data![1] as List<Doctor>;
          final List<Patient> currentPatients = snapshot.data![2] as List<Patient>;

          // Actualizar _doctorsList y _patientsList si es necesario para el diálogo
          // (aunque se cargan en initState, esto asegura que estén sincronizadas con la lista principal)
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   if (mounted) {
          //     setState(() {
          //       _doctorsList = currentDoctors;
          //       _patientsList = currentPatients;
          //     });
          //   }
          // });


          String getDoctorName(int doctorId) {
            final doctor = currentDoctors.firstWhere((doc) => doc.id == doctorId, orElse: () => Doctor(id: 0, name: 'Desconocido', specialty: 'N/A'));
            return doctor.name;
          }
          String getPatientName(int patientId) {
            final patient = currentPatients.firstWhere((pat) => pat.id == patientId, orElse: () => Patient(id: 0, name: 'Desconocido', dateOfBirth: '', contactInfo: ''));
            return patient.name;
          }

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No hay citas programadas.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Toca el botón + para agendar una.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              Appointment appointment = appointments[index];
              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: appointment.isConfirmed == true ? Colors.green[100] : Colors.orange[100],
                    child: Icon(
                      appointment.isConfirmed == true ? Icons.check_circle_outline : Icons.hourglass_empty_outlined,
                      color: appointment.isConfirmed == true ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    '${getPatientName(appointment.patientId)} con Dr. ${getDoctorName(appointment.doctorId)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${appointment.appointmentDate}', style: TextStyle(color: Colors.grey[700])),
                      Text('Tipo: ${appointment.appointmentType ?? "No espec."} - Razón: ${appointment.reason}'),
                      Text('Estado: ${appointment.status} ${appointment.isConfirmed == true ? "(Confirmada)" : "(No Confirmada)"}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                      if (appointment.notes != null && appointment.notes!.isNotEmpty)
                        Text('Notas: ${appointment.notes}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                     children: [
                      IconButton(
                        icon: Icon(Icons.edit_calendar_outlined, color: Colors.blueGrey[600]),
                        tooltip: 'Editar Cita',
                        onPressed: () => _showAppointmentFormDialog(appointment: appointment),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                        tooltip: 'Eliminar Cita',
                        onPressed: () => _deleteAppointment(appointment.id!),
                      ),
                    ],
                  ),
                  onTap: () => _showAppointmentFormDialog(appointment: appointment),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAppointmentFormDialog(), // Llama al mismo diálogo, sin pasar 'appointment' para "añadir"
        tooltip: 'Agendar Cita',
        icon: const Icon(Icons.add_alarm_outlined),
        label: const Text('Agendar Cita'),
         backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
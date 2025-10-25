import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/appointment_model.dart';
import '../models/doctor_availability_model.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  DateTime? _selectedDate;
  String? _selectedEspecialidad;
  DoctorAvailabilityModel? _selectedSlot;
  List<DoctorAvailabilityModel> _availableSlots = [];
  bool _isLoading = false;
  bool _isLoadingSlots = false;

  final List<String> _especialidades = [
    'Cardiología',
    'Dermatología',
    'Pediatría',
    'Oftalmología',
    'Neurología',
    'Medicina General',
    'Ginecología',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Agendar Nueva Cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade600, Colors.blue.shade600],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Paso 1: Seleccionar Especialidad
              _buildSectionTitle('1. Selecciona la Especialidad'),
              const SizedBox(height: 12),
              _buildEspecialidadSelector(),

              const SizedBox(height: 24),

              // Paso 2: Seleccionar Fecha
              _buildSectionTitle('2. Selecciona la Fecha'),
              const SizedBox(height: 12),
              _buildDateSelector(),

              const SizedBox(height: 24),

              // Paso 3: Seleccionar Horario
              if (_selectedDate != null && _selectedEspecialidad != null) ...[
                _buildSectionTitle('3. Selecciona el Horario'),
                const SizedBox(height: 12),
                _isLoadingSlots
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSlotsSelector(),
              ],

              const SizedBox(height: 24),

              // Paso 4: Motivo de la Consulta
              if (_selectedSlot != null) ...[
                _buildSectionTitle('4. Motivo de la Consulta'),
                const SizedBox(height: 12),
                _buildMotivoField(),
              ],

              const SizedBox(height: 32),

              // Botón de Agendar
              if (_selectedSlot != null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Agendar Cita',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEspecialidadSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEspecialidad,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.medical_services, color: Colors.purple),
          hintText: 'Selecciona una especialidad',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _especialidades.map((especialidad) {
          return DropdownMenuItem(
            value: especialidad,
            child: Text(especialidad),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedEspecialidad = value;
            _selectedSlot = null;
            _availableSlots = [];
            if (_selectedDate != null && value != null) {
              _loadAvailableSlots();
            }
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Por favor selecciona una especialidad';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.purple,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _selectedSlot = null;
            _availableSlots = [];
            if (_selectedEspecialidad != null) {
              _loadAvailableSlots();
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Selecciona una fecha'
                    : _formatDate(_selectedDate!),
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsSelector() {
    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay horarios disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra fecha o especialidad',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableSlots.map((slot) {
        final isSelected = _selectedSlot?.id == slot.id;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedSlot = slot;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.horaInicio} - ${slot.horaFin}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slot.medicoNombre,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMotivoField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _motivoController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Ej: Dolor de cabeza persistente, revisión general...',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.notes, color: Colors.purple),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor ingresa el motivo de la consulta';
          }
          if (value.trim().length < 10) {
            return 'El motivo debe tener al menos 10 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDate == null || _selectedEspecialidad == null) return;

    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final slots = await _firestoreService.getAvailableSlots(
        fecha: _selectedDate,
        especialidad: _selectedEspecialidad,
      );

      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar horarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear el objeto de cita
      final appointment = AppointmentModel(
        pacienteId: user.uid,
        medicoId: _selectedSlot!.medicoId,
        medicoNombre: _selectedSlot!.medicoNombre,
        especialidad: _selectedSlot!.especialidad,
        fechaHora: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          int.parse(_selectedSlot!.horaInicio.split(':')[0]),
          int.parse(_selectedSlot!.horaInicio.split(':')[1]),
        ),
        motivo: _motivoController.text.trim(),
        estado: 'pendiente',
        fechaCreacion: DateTime.now(),
      );

      // Guardar la cita y marcar el horario como ocupado
      await _firestoreService.bookAppointment(
        appointment: appointment,
        availabilityId: _selectedSlot!.id!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita agendada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agendar cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

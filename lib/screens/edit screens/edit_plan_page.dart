
import 'package:assignment_1/screens/add_screen/widgets/custom_text_field.dart';
import 'package:assignment_1/screens/trips/util/trip_detail_utils.dart'; // for PlanType enum + helpers if you have them
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Map PlanType -> subcollection name (same mapping used elsewhere)
const Map<PlanType, String> _planTypeToColl = {
  PlanType.activity:   'activityPlans',
  PlanType.travel:     'travelPlans',
  PlanType.lodging:    'lodgingPlans',
  PlanType.restaurant: 'restaurantPlans',
};

class EditPlanPage extends StatefulWidget {
  final String userId;
  final String tripId;
  final PlanType planType;
  final String planId;

  const EditPlanPage({
    super.key,
    required this.userId,
    required this.tripId,
    required this.planType,
    required this.planId,
  });

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  // loading state
  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _data;


  void _popWithResult(bool updated) {
    Navigator.of(context).pop(updated);
  }


  // ---- common date/time formatters ----
  final _dateFmt = DateFormat('dd-MM-yyyy');

  // ---------- controllers / state for all possible fields ----------
  // Activity
  final _eventNameCtrl = TextEditingController();
  final _venueCtrl     = TextEditingController();
  final _actPhoneCtrl  = TextEditingController();
  final _actEmailCtrl  = TextEditingController();
  final _actWebCtrl    = TextEditingController();
  DateTime? _actStartDate;
  DateTime? _actEndDate;
  TimeOfDay? _actStartTime;
  TimeOfDay? _actEndTime;

  // Travel
  String    _travelMode = 'flight'; // flight | train
  final _travelNameCtrl   = TextEditingController(); // airline/train name
  final _travelNumCtrl    = TextEditingController(); // flight#/train#
  final _travelSeatCtrl   = TextEditingController();
  final _travelSourceCtrl = TextEditingController();
  final _travelDestCtrl   = TextEditingController();
  DateTime? _travelDepDate;
  TimeOfDay? _travelDepTime;
  DateTime? _travelArrDate;
  TimeOfDay? _travelArrTime;

  // Lodging
  final _lodgingNameCtrl  = TextEditingController();
  final _lodgingAddrCtrl  = TextEditingController();
  final _lodgingPhoneCtrl = TextEditingController();
  final _lodgingEmailCtrl = TextEditingController();
  DateTime? _lodgingInDate;
  TimeOfDay? _lodgingInTime;
  DateTime? _lodgingOutDate;
  TimeOfDay? _lodgingOutTime;

  // Restaurant
  final _restNameCtrl  = TextEditingController();
  final _restAddrCtrl  = TextEditingController();
  final _restPhoneCtrl = TextEditingController();
  final _restEmailCtrl = TextEditingController();
  DateTime? _restDate;
  TimeOfDay? _restTime;
  bool _restConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    // controllers
    _eventNameCtrl.dispose();
    _venueCtrl.dispose();
    _actPhoneCtrl.dispose();
    _actEmailCtrl.dispose();
    _actWebCtrl.dispose();

    _travelNameCtrl.dispose();
    _travelNumCtrl.dispose();
    _travelSeatCtrl.dispose();
    _travelSourceCtrl.dispose();
    _travelDestCtrl.dispose();

    _lodgingNameCtrl.dispose();
    _lodgingAddrCtrl.dispose();
    _lodgingPhoneCtrl.dispose();
    _lodgingEmailCtrl.dispose();

    _restNameCtrl.dispose();
    _restAddrCtrl.dispose();
    _restPhoneCtrl.dispose();
    _restEmailCtrl.dispose();

    super.dispose();
  }

  // --------------------------------------------------------------
  // Load existing plan doc
  // --------------------------------------------------------------
  Future<void> _loadPlan() async {
    try {
      final collName = _planTypeToColl[widget.planType]!;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('trips')
          .doc(widget.tripId)
          .collection(collName)
          .doc(widget.planId);

      final snap = await docRef.get();
      if (!snap.exists) {
        setState(() {
          _data = null; // not found
          _loading = false;
        });
        return;
      }

      final data = snap.data()!;
      _data = data;

      // hydrate UI state by type
      switch (widget.planType) {
        case PlanType.activity:
          _eventNameCtrl.text = (data['eventName'] ?? '') as String;
          _venueCtrl.text     = (data['venue'] ?? '') as String;
          _actPhoneCtrl.text  = (data['phone'] ?? '') as String;
          _actEmailCtrl.text  = (data['email'] ?? '') as String;
          _actWebCtrl.text    = (data['website'] ?? '') as String;

          _actStartDate = _tsOrNull(data['startDate']);
          _actEndDate   = _tsOrNull(data['endDate']);
          _actStartTime = _timeStrToTOD(data['startTime']);
          _actEndTime   = _timeStrToTOD(data['endTime']);
          break;

        case PlanType.travel:
          _travelMode     = (data['modeOfTravel'] ?? 'flight') as String;
          _travelNameCtrl.text = (data['name'] ?? data['travelName'] ?? '') as String;
          _travelNumCtrl.text  = (data['travelNumber'] ?? '') as String;
          _travelSeatCtrl.text = (data['seatNumber'] ?? '') as String;
          _travelSourceCtrl.text = (data['source'] ?? '') as String;
          _travelDestCtrl.text   = (data['destination'] ?? '') as String;

          _travelDepDate = _tsOrNull(data['departureDate']);
          _travelDepTime = _timeStrToTOD(data['departureTime']);
          _travelArrDate = _tsOrNull(data['arrivalDate']);
          _travelArrTime = _timeStrToTOD(data['arrivalTime']);
          break;

        case PlanType.lodging:
          _lodgingNameCtrl.text  = (data['lodgingName'] ?? '') as String;
          _lodgingAddrCtrl.text  = (data['address'] ?? '') as String;
          _lodgingPhoneCtrl.text = (data['phone'] ?? '') as String;
          _lodgingEmailCtrl.text = (data['email'] ?? '') as String;

          _lodgingInDate  = _tsOrNull(data['checkInDate']);
          _lodgingInTime  = _timeStrToTOD(data['checkInTime']);
          _lodgingOutDate = _tsOrNull(data['checkOutDate']);
          _lodgingOutTime = _timeStrToTOD(data['checkOutTime']);
          break;

        case PlanType.restaurant:
          _restNameCtrl.text  = (data['restaurantName'] ?? '') as String;
          _restAddrCtrl.text  = (data['address'] ?? '') as String;
          _restPhoneCtrl.text = (data['phone'] ?? '') as String;
          _restEmailCtrl.text = (data['email'] ?? '') as String;

          _restDate       = _tsOrNull(data['date']);
          _restTime       = _timeStrToTOD(data['time']);
          _restConfirmed  = data['confirmation'] == true;
          break;
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  // --------------------------------------------------------------
  // Save -> update Firestore
  // --------------------------------------------------------------
  Future<void> _save() async {
    final collName = _planTypeToColl[widget.planType]!;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('trips')
        .doc(widget.tripId)
        .collection(collName)
        .doc(widget.planId);

    Map<String, dynamic> updateData;

    switch (widget.planType) {
      case PlanType.activity:
        if (_eventNameCtrl.text.trim().isEmpty) {
          _showSnack('Event name required');
          return;
        }
        updateData = {
          'eventName': _eventNameCtrl.text.trim(),
          'venue': _emptyToNull(_venueCtrl.text),
          'phone': _emptyToNull(_actPhoneCtrl.text),
          'email': _emptyToNull(_actEmailCtrl.text),
          'website': _emptyToNull(_actWebCtrl.text),
          'startDate': _actStartDate != null ? Timestamp.fromDate(_actStartDate!) : null,
          'endDate':   _actEndDate   != null ? Timestamp.fromDate(_actEndDate!)   : null,
          'startTime': _todToTimeStr(_actStartTime),
          'endTime':   _todToTimeStr(_actEndTime),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        break;

      case PlanType.travel:
        if (_travelNameCtrl.text.trim().isEmpty) {
          _showSnack('Name required');
          return;
        }
        updateData = {
          'modeOfTravel': _travelMode,
          'name': _travelNameCtrl.text.trim(),
          'travelNumber': _emptyToNull(_travelNumCtrl.text),
          'seatNumber': _emptyToNull(_travelSeatCtrl.text),
          'source': _emptyToNull(_travelSourceCtrl.text),
          'destination': _emptyToNull(_travelDestCtrl.text),
          'departureDate': _travelDepDate != null ? Timestamp.fromDate(_travelDepDate!) : null,
          'departureTime': _todToTimeStr(_travelDepTime),
          'arrivalDate': _travelArrDate != null ? Timestamp.fromDate(_travelArrDate!) : null,
          'arrivalTime': _todToTimeStr(_travelArrTime),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        break;

      case PlanType.lodging:
        if (_lodgingNameCtrl.text.trim().isEmpty) {
          _showSnack('Lodging name required');
          return;
        }
        if (_lodgingInDate == null || _lodgingOutDate == null) {
          _showSnack('Check-in & check-out dates required');
          return;
        }
        updateData = {
          'lodgingName': _lodgingNameCtrl.text.trim(),
          'address': _emptyToNull(_lodgingAddrCtrl.text),
          'phone': _emptyToNull(_lodgingPhoneCtrl.text),
          'email': _emptyToNull(_lodgingEmailCtrl.text),
          'checkInDate': Timestamp.fromDate(_lodgingInDate!),
          'checkInTime': _todToTimeStr(_lodgingInTime),
          'checkOutDate': Timestamp.fromDate(_lodgingOutDate!),
          'checkOutTime': _todToTimeStr(_lodgingOutTime),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        break;

      case PlanType.restaurant:
        if (_restNameCtrl.text.trim().isEmpty) {
          _showSnack('Restaurant name required');
          return;
        }
        updateData = {
          'restaurantName': _restNameCtrl.text.trim(),
          'address': _emptyToNull(_restAddrCtrl.text),
          'phone': _emptyToNull(_restPhoneCtrl.text),
          'email': _emptyToNull(_restEmailCtrl.text),
          'date': _restDate != null ? Timestamp.fromDate(_restDate!) : null,
          'time': _todToTimeStr(_restTime),
          'confirmation': _restConfirmed,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        break;
    }

    try {
      await docRef.update(updateData);
      if (!mounted) return;
      _showSnack('Saved');
      _popWithResult(true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Save failed: $e');
    }
  }

  // --------------------------------------------------------------
  // Pickers
  // --------------------------------------------------------------
  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final now = DateTime.now();
    final init = current ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime({
    required TimeOfDay? current,
    required ValueChanged<TimeOfDay?> onPicked,
  }) async {
    final now = TimeOfDay.now();
    final init = current ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: init,
    );
    if (picked != null) onPicked(picked);
  }

  // --------------------------------------------------------------
  // Build
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }
    if (_data == null) {
      return const Scaffold(
        body: Center(child: Text('Plan not found')),
      );
    }

    final title = switch (widget.planType) {
      PlanType.activity   => 'Edit Activity Plan',
      PlanType.travel     => 'Edit Travel Plan',
      PlanType.lodging    => 'Edit Lodging Plan',
      PlanType.restaurant => 'Edit Restaurant Plan',
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _buildFormForType(widget.planType),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormForType(PlanType type) {
    switch (type) {
      case PlanType.activity:
        return _buildActivityForm();
      case PlanType.travel:
        return _buildTravelForm();
      case PlanType.lodging:
        return _buildLodgingForm();
      case PlanType.restaurant:
        return _buildRestaurantForm();
    }
  }

  // ------------------------------------------------------------------
  // Activity form
  // ------------------------------------------------------------------
  Widget _buildActivityForm() {
    return _FormScroll(
      children: [
        CustomTextField(
          controller: _eventNameCtrl,
          showLabel: true,
          labelText: 'Event Name*',
          hintText: 'e.g., Meeting, Sightseeing',
        ),
        const SizedBox(height: 16),
        const Text('Start (optional)'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _actStartDate,
                  onPicked: (d) => setState(() => _actStartDate = d),
                ),
                child: Text(_fmtDateOrPick(_actStartDate, 'Start Date'), style: const TextStyle(color: Colors.black),),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _actStartTime,
                  onPicked: (t) => setState(() => _actStartTime = t),
                ),
                child: Text(_fmtTimeOrPick(_actStartTime, 'Start Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('End (optional)'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _actEndDate,
                  onPicked: (d) => setState(() => _actEndDate = d),
                ),
                child: Text(_fmtDateOrPick(_actEndDate, 'End Date'), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _actEndTime,
                  onPicked: (t) => setState(() => _actEndTime = t),
                ),
                child: Text(_fmtTimeOrPick(_actEndTime, 'End Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _venueCtrl,
          showLabel: true,
          labelText: 'Venue / Address (optional)',
          hintText: 'Type the venue / address here',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _actPhoneCtrl,
          showLabel: true,
          labelText: 'Phone (optional)',
          hintText: 'Contact phone number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _actEmailCtrl,
          showLabel: true,
          labelText: 'Email (optional)',
          hintText: 'Contact email',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _actWebCtrl,
          showLabel: true,
          labelText: 'Website (optional)',
          hintText: 'Website URL',
        ),
        const SizedBox(height: 80), // spacer for bottom button
      ],
    );
  }

  // ------------------------------------------------------------------
  // Travel form
  // ------------------------------------------------------------------
  Widget _buildTravelForm() {
    return _FormScroll(
      children: [
        const Text('Mode of Travel*'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _travelMode,
          decoration: _dropdownDecoration(),
          items: const [
            DropdownMenuItem(value: 'flight', child: Text('Flight')),
            DropdownMenuItem(value: 'train',  child: Text('Train')),
          ],
          onChanged: (v) => setState(() => _travelMode = v ?? 'flight'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _travelNameCtrl,
          showLabel: true,
          labelText: 'Name*',
          hintText: 'Airline / Train name',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _travelNumCtrl,
          showLabel: true,
          labelText: 'Flight / Train # (optional)',
          hintText: 'Travel number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _travelSeatCtrl,
          showLabel: true,
          labelText: 'Seat # (optional)',
          hintText: 'Seat number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _travelSourceCtrl,
          showLabel: true,
          labelText: 'Source (optional)',
          hintText: 'Source airport / station',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _travelDestCtrl,
          showLabel: true,
          labelText: 'Destination (optional)',
          hintText: 'Destination airport / station',
        ),
        const SizedBox(height: 16),
        const Text('Departure (optional)'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _travelDepDate,
                  onPicked: (d) => setState(() => _travelDepDate = d),
                ),
                child: Text(_fmtDateOrPick(_travelDepDate, 'Date'), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _travelDepTime,
                  onPicked: (t) => setState(() => _travelDepTime = t),
                ),
                child: Text(_fmtTimeOrPick(_travelDepTime, 'Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Arrival (optional)'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _travelArrDate,
                  onPicked: (d) => setState(() => _travelArrDate = d),
                ),
                child: Text(_fmtDateOrPick(_travelArrDate, 'Date'), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _travelArrTime,
                  onPicked: (t) => setState(() => _travelArrTime = t),
                ),
                child: Text(_fmtTimeOrPick(_travelArrTime, 'Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Lodging form
  // ------------------------------------------------------------------
  Widget _buildLodgingForm() {
    return _FormScroll(
      children: [
        CustomTextField(
          controller: _lodgingNameCtrl,
          showLabel: true,
          labelText: 'Lodging Name*',
          hintText: 'Hotel / Stay name',
        ),
        const SizedBox(height: 16),
        const Text('Check-in*'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _lodgingInDate,
                  onPicked: (d) => setState(() => _lodgingInDate = d),
                ),
                child: Text(_fmtDateOrPick(_lodgingInDate, 'Date'), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _lodgingInTime,
                  onPicked: (t) => setState(() => _lodgingInTime = t),
                ),
                child: Text(_fmtTimeOrPick(_lodgingInTime, 'Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Check-out*'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(
                  current: _lodgingOutDate,
                  onPicked: (d) => setState(() => _lodgingOutDate = d),
                ),
                child: Text(_fmtDateOrPick(_lodgingOutDate, 'Date'), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(
                  current: _lodgingOutTime,
                  onPicked: (t) => setState(() => _lodgingOutTime = t),
                ),
                child: Text(_fmtTimeOrPick(_lodgingOutTime, 'Time'), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lodgingAddrCtrl,
          showLabel: true,
          labelText: 'Address (optional)',
          hintText: 'Street / City / Country',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lodgingPhoneCtrl,
          showLabel: true,
          labelText: 'Phone (optional)',
          hintText: 'Contact number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _lodgingEmailCtrl,
          showLabel: true,
          labelText: 'Email (optional)',
          hintText: 'Contact email',
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Restaurant form
  // ------------------------------------------------------------------
  Widget _buildRestaurantForm() {
    return _FormScroll(
      children: [
        CustomTextField(
          controller: _restNameCtrl,
          showLabel: true,
          labelText: 'Restaurant Name*',
          hintText: 'Restaurant',
        ),
        const SizedBox(height: 16),
        const Text('Date (optional)'),
        OutlinedButton(
          onPressed: () => _pickDate(
            current: _restDate,
            onPicked: (d) => setState(() => _restDate = d),
          ),
          child: Text(_fmtDateOrPick(_restDate, 'Date'), style: const TextStyle(color: Colors.black)),
        ),
        const SizedBox(height: 16),
        const Text('Time (optional)'),
        OutlinedButton(
          onPressed: () => _pickTime(
            current: _restTime,
            onPicked: (t) => setState(() => _restTime = t),
          ),
          child: Text(_fmtTimeOrPick(_restTime, 'Time'), style: TextStyle(color: Colors.black),),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _restConfirmed,
          title: const Text('Reservation Confirmed?'),
          activeColor: Colors.black,
          onChanged: (v) => setState(() => _restConfirmed = v),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _restAddrCtrl,
          showLabel: true,
          labelText: 'Address (optional)',
          hintText: 'Street / City / Country',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _restPhoneCtrl,
          showLabel: true,
          labelText: 'Phone (optional)',
          hintText: 'Contact number',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _restEmailCtrl,
          showLabel: true,
          labelText: 'Email (optional)',
          hintText: 'Contact email',
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // --------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _dropdownDecoration() => const InputDecoration(
    border: OutlineInputBorder(),
    isDense: true,
  );

  String _fmtDateOrPick(DateTime? dt, String fallbackLabel) =>
      dt == null ? fallbackLabel : _dateFmt.format(dt);

  String _fmtTimeOrPick(TimeOfDay? tod, String fallbackLabel) =>
      tod == null ? fallbackLabel : tod.format(context);
}

// ======================================================================
// SHARED SMALL WIDGET: scroll container for forms
// ======================================================================
class _FormScroll extends StatelessWidget {
  final List<Widget> children;
  const _FormScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // bottom room for save btn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ======================================================================
// Small utility fns
// ======================================================================
DateTime? _tsOrNull(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

String? _emptyToNull(String? s) =>
    (s == null || s.trim().isEmpty) ? null : s.trim();

TimeOfDay? _timeStrToTOD(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  // Expect "HH:mm" or "H:M"
  final parts = s.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return TimeOfDay(hour: h, minute: m);
}

String? _todToTimeStr(TimeOfDay? t) {
  if (t == null) return null;
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

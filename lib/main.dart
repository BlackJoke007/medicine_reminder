import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.rtl,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'یادآور دارو',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazir',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _medicines = [];

  void _addMedicine(String type, String name, String dosage, int intervalHours,
      int durationDays, String alarmSound) {
    final now = DateTime.now();
    final startTime = now;
    setState(() {
      _medicines.add({
        'type': type,
        'name': name,
        'dosage': dosage,
        'interval': intervalHours,
        'duration': durationDays,
        'remainingDays': durationDays,
        'remainingDoses': 24 ~/ intervalHours,
        'startTime': startTime,
        'alarmSound': alarmSound,
      });
    });
    _scheduleReminders(name, intervalHours, durationDays);
  }

  void _scheduleReminders(
      String medicineName, int intervalHours, int durationDays) {
    int totalDoses = (durationDays * 24) ~/ intervalHours;
    DateTime reminderTime = DateTime.now();
    for (int i = 0; i < totalDoses; i++) {
      Timer(Duration(hours: intervalHours * i), () {
        _showReminderDialog(medicineName, intervalHours);
      });
    }
  }

  void _showReminderDialog(String medicineName, int intervalHours) {
    int medicineIndex =
        _medicines.indexWhere((medicine) => medicine['name'] == medicineName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "یادآوری",
            style: TextStyle(fontFamily: "Vazir.ttf"),
          ),
          content: Text(
              "زمان مصرف دارو $medicineName فرا رسیده است! لطفاً دارو را مصرف کنید."),
          actions: [
            TextButton(
              child: Text(
                "مصرف دارو",
                style: TextStyle(color: Colors.lightBlue),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _confirmConsumption(medicineIndex);
                _confirmNextReminder(medicineName, intervalHours);
              },
            ),
            TextButton(
              child: Text(
                "لغو",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Timer(Duration(minutes: 10), () {
                  _showReminderDialog(medicineName, intervalHours);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmNextReminder(String medicineName, int intervalHours) {
    DateTime nextReminder = DateTime.now().add(Duration(hours: intervalHours));
    Timer(nextReminder.difference(DateTime.now()), () {
      _showReminderDialog(medicineName, intervalHours);
    });
  }

  void _confirmConsumption(int index) {
    setState(() {
      if (_medicines[index]['remainingDoses'] > 0) {
        _medicines[index]['remainingDoses'] -= 1;
      } else if (_medicines[index]['remainingDays'] > 0) {
        _medicines[index]['remainingDays'] -= 1;
        _medicines[index]['remainingDoses'] =
            24 ~/ _medicines[index]['interval'];
      }
    });
  }

  void _openAddMedicineDialog() {
    String? selectedType;
    String medicineName = "";
    String dosage = "";
    String interval = "";
    String duration = "";
    String selectedAlarm = "پیش‌فرض";
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.medication, color: Colors.blue, size: 24),
                ),
                SizedBox(width: 8),
                Text(
                  "افزودن دارو",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "نوع دارو",
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "قرص",
                            child: Text("قرص"),
                          ),
                          DropdownMenuItem(
                            value: "شربت",
                            child: Text("شربت"),
                          ),
                          DropdownMenuItem(
                            value: "قطره",
                            child: Text("قطره"),
                          ),
                          DropdownMenuItem(
                            value: "پماد",
                            child: Text("پماد"),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedType = value),
                        validator: (value) =>
                            value == null ? "نوع دارو را انتخاب کنید" : null,
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        "نام دارو",
                        Icons.edit,
                        (value) => medicineName = value,
                        "نام دارو را وارد کنید",
                        initialValue: '',
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        selectedType == "قرص"
                            ? "دوز مصرف (mg)"
                            : "دوز مصرف (cc)",
                        Icons.local_hospital,
                        (value) => dosage = value,
                        "دوز مصرف را وارد کنید",
                        isNumber: true,
                        initialValue: '',
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        "فاصله زمانی مصرف (ساعت)",
                        Icons.access_time,
                        (value) => interval = value,
                        "فاصله زمانی مصرف را وارد کنید",
                        isNumber: true,
                        initialValue: '',
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        "مدت زمان مصرف (روز)",
                        Icons.calendar_today,
                        (value) => duration = value,
                        "مدت زمان مصرف را وارد کنید",
                        isNumber: true,
                        initialValue: '',
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "صدای هشدار",
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelStyle: TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "پیش‌فرض",
                            child: Text("پیش‌فرض"),
                          ),
                          DropdownMenuItem(
                            value: "زنگ 1",
                            child: Text("زنگ اول"),
                          ),
                          DropdownMenuItem(
                            value: "زنگ 2",
                            child: Text("زنگ دوم"),
                          ),
                          DropdownMenuItem(
                            value: "زنگ 3",
                            child: Text("زنگ سوم"),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedAlarm = value!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton.icon(
                label: Text("افزودن"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addMedicine(
                      selectedType!,
                      medicineName,
                      dosage,
                      int.parse(interval),
                      int.parse(duration),
                      selectedAlarm,
                    );
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              ElevatedButton.icon(
                label: Text("لغو"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    IconData icon,
    Function(String) onChanged,
    String errorMessage, {
    bool isNumber = false,
    required String initialValue,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        if (isNumber && double.tryParse(value) == null) {
          return "لطفاً مقدار عددی وارد کنید";
        }
        return null;
      },
    );
  }

  // حذف دارو
  void _deleteMedicine(int index) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("حذف دارو"),
          content: Text("آیا مطمئن هستید که می‌خواهید این دارو را حذف کنید؟"),
          actions: [
            TextButton(
              child: Text("حذف", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                setState(() {
                  _medicines.removeAt(index);
                });
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Text("لغو", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editMedicine(int index) {
    String medicineName = _medicines[index]['name'];
    String dosage = _medicines[index]['dosage'];
    String interval = _medicines[index]['interval'].toString();
    String duration = _medicines[index]['duration'].toString();
    String selectedType = _medicines[index]['type'];
    String selectedAlarm = _medicines[index]['alarmSound'];
    int remainingDoses = _medicines[index]['remainingDoses'];
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.medication, color: Colors.blue, size: 24),
                ),
                SizedBox(width: 8),
                Text(
                  "ویرایش دارو",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "نوع دارو",
                        filled: true,
                        fillColor: Colors.grey[100],
                        labelStyle: TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "قرص",
                          child: Text("قرص"),
                        ),
                        DropdownMenuItem(
                          value: "شربت",
                          child: Text("شربت"),
                        ),
                        DropdownMenuItem(
                          value: "قطره",
                          child: Text("قطره"),
                        ),
                        DropdownMenuItem(
                          value: "پماد",
                          child: Text("پماد"),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                      value: selectedType,
                      validator: (value) =>
                          value == null ? "نوع دارو را انتخاب کنید" : null,
                    ),
                    SizedBox(height: 15),
                    _buildTextFormField(
                      "نام دارو",
                      Icons.edit,
                      (value) => medicineName = value,
                      "نام دارو را وارد کنید",
                      initialValue: _medicines[index]['name'],
                    ),
                    SizedBox(height: 15),
                    _buildTextFormField(
                      selectedType == "قرص" ? "دوز مصرف (mg)" : "دوز مصرف (cc)",
                      Icons.local_hospital,
                      (value) => dosage = value,
                      "دوز مصرف را وارد کنید",
                      isNumber: true,
                      initialValue: _medicines[index]['dosage'],
                    ),
                    SizedBox(height: 15),
                    _buildTextFormField(
                      "فاصله زمانی مصرف (ساعت)",
                      Icons.access_time,
                      (value) => interval = value,
                      "فاصله زمانی مصرف را وارد کنید",
                      isNumber: true,
                      initialValue: interval,
                    ),
                    SizedBox(height: 15),
                    _buildTextFormField(
                      "مدت زمان مصرف (روز)",
                      Icons.calendar_today,
                      (value) => duration = value,
                      "مدت زمان مصرف را وارد کنید",
                      isNumber: true,
                      initialValue: duration,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("تعداد باقی‌مانده مصرف: $remainingDoses"),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  if (remainingDoses > 0) {
                                    remainingDoses--;
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  remainingDoses++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: List.generate(
                        24 ~/ int.parse(interval),
                        (i) => Expanded(
                          child: Container(
                            height: 10,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(
                                colors: i < remainingDoses
                                    ? [Colors.green, Colors.lightGreenAccent]
                                    : [Colors.grey[300]!, Colors.grey[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton.icon(
                label: Text("ذخیره"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _medicines[index] = {
                        'name': medicineName,
                        'dosage': dosage,
                        'interval': int.parse(interval),
                        'duration': int.parse(duration),
                        'type': selectedType,
                        'alarmSound': selectedAlarm,
                        'remainingDoses': remainingDoses,
                      };
                    });
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              ElevatedButton.icon(
                label: Text("لغو"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "خانه",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 15, 227, 209),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/medicine.jpg'),
                  fit: BoxFit.cover, // اندازه تصویر
                ),
              ),
            ),
            // محتوای اصلی برنامه
            _medicines.isEmpty
                ? Center(
                    child: Text(
                      "هنوز هیچ دارویی اضافه نشده است!",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(_medicines), // کلید یکتا برای لیست
                    itemCount: _medicines.length,
                    itemBuilder: (ctx, index) => Card(
                      key: ValueKey(
                          _medicines[index]['id']), // کلید یکتا برای هر کارت
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // گوشه‌های گرد
                      ),
                      elevation: 4, // سایه برای کارت
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _medicines[index]['name'], // نمایش نام دارو
                                  key: ValueKey(
                                      "name-${_medicines[index]['id']}"),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                        Colors.blueAccent, // رنگ آبی برای نام
                                  ),
                                ),
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.blueAccent,
                                ), // آیکون مرتبط
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(
                                color: Colors.grey[300],
                                thickness: 1), // خط جداکننده
                            SizedBox(height: 10),
                            Text(
                              "نوع: ${_medicines[index]['type'] ?? 'نامشخص'}",
                              style: TextStyle(fontSize: 16),
                              key: ValueKey("type-${_medicines[index]['id']}"),
                            ),
                            Text(
                              "دوز: ${_medicines[index]['dosage'] ?? 'نامشخص'}",
                              style: TextStyle(fontSize: 16),
                              key:
                                  ValueKey("dosage-${_medicines[index]['id']}"),
                            ),
                            Text(
                              "فاصله با دوز قبلی: ${_medicines[index]['interval'] ?? 'نامشخص'} ساعت",
                              style: TextStyle(fontSize: 16),
                              key: ValueKey(
                                  "interval-${_medicines[index]['id']}"),
                            ),
                            Text(
                              "مدت زمان مصرف: ${_medicines[index]['duration'] ?? 'نامشخص'} روز",
                              style: TextStyle(fontSize: 16),
                              key: ValueKey(
                                  "duration-${_medicines[index]['id']}"),
                            ),
                            Text(
                              "روزهای باقی‌مانده: ${_medicines[index]['remainingDays'] ?? 'نامشخص'} روز",
                              style: TextStyle(fontSize: 16),
                              key: ValueKey(
                                  "remainingDays-${_medicines[index]['id']}"),
                            ),
                            Text(
                              "صدای هشدار: ${_medicines[index]['alarmSound'] ?? 'نامشخص'}",
                              style: TextStyle(fontSize: 16),
                              key: ValueKey(
                                  "alarmSound-${_medicines[index]['id']}"),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: List.generate(
                                24 ~/
                                    (_medicines[index]['interval'] ??
                                        1), // نوار پیشرفت
                                (i) => Expanded(
                                  child: Container(
                                    key: ValueKey(
                                        "progress-$i-${_medicines[index]['id']}"), // کلید یکتا برای هر نوار
                                    height: 10,
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: i <
                                              (_medicines[index]
                                                      ['remainingDoses'] ??
                                                  0)
                                          ? Colors.green
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(
                                          5), // گوشه‌های گرد نوار
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                    key: ValueKey(
                                        "edit-${_medicines[index]['id']}"),
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "ویرایش",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blueAccent, // رنگ دکمه ویرایش
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // گوشه‌های دکمه
                                      ),
                                    ),
                                    onPressed: () {
                                      _editMedicine(index);
                                    }),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  key: ValueKey(
                                      "delete-${_medicines[index]['id']}"),
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "حذف",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.redAccent, // رنگ دکمه حذف
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _deleteMedicine(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 15, 227, 209),
          child: Icon(Icons.medication, color: Colors.white),
          shape: CircleBorder(),
          onPressed: _openAddMedicineDialog,
        ),
      ),
    );
  }
}

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
            title: Row(
              children: [
                Icon(Icons.medication, color: Colors.blue),
                SizedBox(width: 8),
                Text("افزودن دارو"),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: "قرص",
                              child: Text(
                                "قرص",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "شربت",
                              child: Text(
                                "شربت",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "قطره",
                              child: Text(
                                "قطره",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "پماد",
                              child: Text(
                                "پماد",
                                textAlign: TextAlign.right,
                              )),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedType = value),
                        validator: (value) =>
                            value == null ? "نوع دارو را انتخاب کنید" : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "نام دارو",
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        onChanged: (value) => medicineName = value,
                        validator: (value) => value == null || value.isEmpty
                            ? "نام دارو را وارد کنید (مثال: آسپرین)"
                            : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: selectedType == "قرص"
                              ? "دوز مصرف (mg)"
                              : "دوز مصرف (cc)",
                          prefixIcon: Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        onChanged: (value) => dosage = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "دوز مصرف را وارد کنید (مثال: 500 mg یا 10 cc)";
                          } else if (double.tryParse(value) == null) {
                            return "لطفاً مقدار عددی وارد کنید";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "فاصله زمانی مصرف (ساعت)",
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: Colors.lightBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => interval = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "فاصله زمانی مصرف را وارد کنید (مثال: 8 ساعت)";
                          } else if (int.tryParse(value) == null) {
                            return "لطفاً مقدار عددی وارد کنید";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "مدت زمان مصرف (روز)",
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.lightGreen,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => duration = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "مدت زمان مصرف را وارد کنید (مثال: 7 روز)";
                          } else if (int.tryParse(value) == null) {
                            return "لطفاً مقدار عددی وارد کنید";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "صدای هشدار",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 15, 227, 209),
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: "پیش‌فرض",
                              child: Text(
                                "پیش‌فرض",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "زنگ 1",
                              child: Text(
                                "زنگ اول",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "زنگ 2",
                              child: Text(
                                "زنگ دوم",
                                textAlign: TextAlign.right,
                              )),
                          DropdownMenuItem(
                              value: "زنگ 3",
                              child: Text(
                                "زنگ سوم",
                                textAlign: TextAlign.right,
                              )),
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
              TextButton(
                child: Text("افزودن", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addMedicine(
                        selectedType!,
                        medicineName,
                        dosage,
                        int.parse(interval),
                        int.parse(duration),
                        selectedAlarm);
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              TextButton(
                child: Text("لغو", style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
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

  // ویرایش دارو
  void _editMedicine(int index) {
    String medicineName = _medicines[index]['name'] ?? '';
    String dosage = _medicines[index]['dosage'] ?? '';
    String interval = _medicines[index]['interval']?.toString() ?? '1';
    String duration = _medicines[index]['duration']?.toString() ?? '1';
    String selectedType = _medicines[index]['type'] ?? 'قرص';
    String selectedAlarm = _medicines[index]['alarmSound'] ?? 'پیش‌فرض';
    int remainingDoses = _medicines[index]['remainingDoses'] ?? 0;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.medication, color: Colors.blue),
                SizedBox(width: 8),
                Text("ویرایش دارو"),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 15, 227, 209),
                          ),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: "قرص",
                            child: Text(
                              "قرص",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "شربت",
                            child: Text(
                              "شربت",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "قطره",
                            child: Text(
                              "قطره",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "پماد",
                            child: Text(
                              "پماد",
                              textAlign: TextAlign.right,
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedType = value!),
                      value: selectedType,
                      validator: (value) =>
                          value == null ? "نوع دارو را انتخاب کنید" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "نام دارو",
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 15, 227, 209),
                          ),
                        ),
                      ),
                      initialValue: _medicines[index]['name'],
                      onChanged: (value) => medicineName = value,
                      validator: (value) => value == null || value.isEmpty
                          ? "نام دارو را وارد کنید"
                          : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: selectedType == "قرص"
                            ? "دوز مصرف (mg)"
                            : "دوز مصرف (cc)",
                        prefixIcon: Icon(
                          Icons.local_hospital,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 15, 227, 209),
                          ),
                        ),
                      ),
                      initialValue: _medicines[index]['dosage'],
                      onChanged: (value) => dosage = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "دوز مصرف را وارد کنید";
                        } else if (double.tryParse(value) == null) {
                          return "لطفاً مقدار عددی وارد کنید";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "فاصله زمانی مصرف (ساعت)",
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: Colors.lightBlue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 15, 227, 209),
                          ),
                        ),
                      ),
                      initialValue: interval,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => interval = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "فاصله زمانی مصرف را وارد کنید";
                        } else if (int.tryParse(value) == null) {
                          return "لطفاً مقدار عددی وارد کنید";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "مدت زمان مصرف (روز)",
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.lightGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 15, 227, 209),
                          ),
                        ),
                      ),
                      initialValue: duration,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => duration = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "مدت زمان مصرف را وارد کنید";
                        } else if (int.tryParse(value) == null) {
                          return "لطفاً مقدار عددی وارد کنید";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("تعداد باقی‌مانده مصرف: $remainingDoses"),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  remainingDoses++;
                                });
                              },
                            ),
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
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        24 ~/ int.parse(interval),
                        (i) => Expanded(
                          child: Container(
                            height: 10,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            color: i < remainingDoses
                                ? Colors.green
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "صدای هشدار",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedAlarm,
                      items: [
                        DropdownMenuItem(
                            value: "پیش‌فرض",
                            child: Text(
                              "پیش‌فرض",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "زنگ 1",
                            child: Text(
                              "زنگ اول",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "زنگ 2",
                            child: Text(
                              "زنگ دوم",
                              textAlign: TextAlign.right,
                            )),
                        DropdownMenuItem(
                            value: "زنگ 3",
                            child: Text(
                              "زنگ سوم",
                              textAlign: TextAlign.right,
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedAlarm = value!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text("ویرایش", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _medicines[index] = {
                        'type': selectedType,
                        'name': medicineName,
                        'dosage': dosage,
                        'interval': int.tryParse(interval) ?? 1,
                        'duration': int.tryParse(duration) ?? 1,
                        'remainingDays': int.tryParse(duration) ?? 1,
                        'remainingDoses': remainingDoses,
                        'startTime': _medicines[index]['startTime'],
                        'alarmSound': selectedAlarm,
                      };
                      print("Updated medicine: ${_medicines[index]}");
                    });
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              TextButton(
                child: Text("لغو", style: TextStyle(color: Colors.red)),
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
                                  onPressed: () => _editMedicine(index),
                                ),
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

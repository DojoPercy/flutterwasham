import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MaterialApp(home: DeliveryDateTimeScreen()));

class DeliveryDateTimeScreen extends StatefulWidget {
  @override
  State<DeliveryDateTimeScreen> createState() => _DeliveryDateTimeScreenState();
}

class _DeliveryDateTimeScreenState extends State<DeliveryDateTimeScreen> {
  final List<Map<String, dynamic>> deliveryData = [
    {"date": "2025-05-31T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-01T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-01T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-02T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-02T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-03T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-03T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-04T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-04T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-05T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-05T00:00:00.000Z", "period": "AFTERNOON"},
    {"date": "2025-06-06T00:00:00.000Z", "period": "MORNING"},
    {"date": "2025-06-06T00:00:00.000Z", "period": "AFTERNOON"},
  ];

  late Map<String, List<String>> groupedSlots;
  late List<String> dateKeys;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    groupedSlots = {};
    for (var item in deliveryData) {
      final date =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date']));
      groupedSlots.putIfAbsent(date, () => []).add(item['period']);
    }
    dateKeys = groupedSlots.keys.toList();
    if (dateKeys.isNotEmpty) {
      selectedDate = dateKeys.first;
    }
  }

  String formatToDay(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('E').format(date); // Mon, Tue, etc.
  }

  String formatToDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('d MMM').format(date); // 24 FEB
  }

  String formatPeriod(String period) {
    switch (period) {
      case "MORNING":
        return "9am - 11am";
      case "AFTERNOON":
        return "1pm - 3pm";
      default:
        return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Date & Time'),
        centerTitle: true,
        leading: BackButton(key: Key("backButton")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("When would you like your delivery?",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.separated(
                key: Key("dateList"),
                scrollDirection: Axis.horizontal,
                itemCount: dateKeys.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final dateKey = dateKeys[index];
                  final isSelected = selectedDate == dateKey;
                  return GestureDetector(
                    key: Key("date_$dateKey"),
                    onTap: () => setState(() => selectedDate = dateKey),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(formatToDay(dateKey),
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(formatToDate(dateKey).toUpperCase(),
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Text("Available time slots", style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: groupedSlots[selectedDate]!
                  .map((period) => Container(
                        key: Key("time_$period"),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formatPeriod(period),
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

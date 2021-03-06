import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:diabetesapp/models/account.dart';
import 'package:diabetesapp/models/activity.dart';
import 'package:diabetesapp/models/carb.dart';
import 'package:diabetesapp/models/glycemic.dart';
import 'package:diabetesapp/models/medicine.dart';
import 'package:diabetesapp/models/weight.dart';
import 'package:diabetesapp/screens/chart/pdf_viewer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../constants.dart';
import '../../user_current.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
class ReportScreen extends StatefulWidget{
  static String routeName = "/report_screen";
  @override
  _ReportScreenState createState() {
    return _ReportScreenState();
  }
}
class _ReportScreenState extends State<ReportScreen>{
  String _name = "";
  String _email = "";
  List<GlycemicModel> listGlycemics = new List<GlycemicModel>();
  List<ActivityModel> listActivity = new List<ActivityModel>();
  List<CarbModel> listCarbs = new List<CarbModel>();
  List<WeightModel> listWeights = new List<WeightModel>();
  List<MedicineModel> listMedicine = new List<MedicineModel>();

  List<GlycemicModel> listGlycemicsTable = new List<GlycemicModel>();
  List<ActivityModel> listActivityTable = new List<ActivityModel>();
  List<CarbModel> listCarbsTable = new List<CarbModel>();
  List<WeightModel> listWeightsTable = new List<WeightModel>();
  List<MedicineModel> listMedicineTable = new List<MedicineModel>();
  double averageWeight = 0;
  double averageCarbs = 0;
  double averageActivity = 0;
  double averageGlycemic = 0;
  bool isWeight = false;
  bool isCarbs = false;
  bool isActivity = false;
  bool isGlycemic = false;
  bool isMedicine = false;
  DateTime startDate = DateTime.now().subtract(Duration(days: 365));
  DateTime endDate = DateTime.now();
  List _types = ["Tất cả", "Đường huyết", "Hoạt động", "Carbs", "Cân nặng", "Thuốc"];
  DateFormat dateFormat = DateFormat("HH:mm:ss dd-MM-yyyy");
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentType;
  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentType = _dropDownMenuItems[0].value;
    isWeight = true;
    isCarbs = true;
    isGlycemic = true;
    isActivity = true;
    isMedicine = true;
    super.initState();
    fetchUser();
    fetchGlycemics();
    fetchActivities();
    fetchCarbs();
    fetchWeight();
    fetchMedicine();
  }
  Future<void> fetchMedicine() async {
    String url = ip + "/api/getMedicine.php?userID="+UserCurrent.userID.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<MedicineModel> list= items.map<MedicineModel>((json) {
        return MedicineModel.fromJson(json);
      }).toList();

      if (list != null) {
        setState(() {
          listMedicine = list;
        });
        filterMedicine(this.startDate, this.endDate);
      }
    }
    else {
      throw Exception('Failed to load data.');
    }
  }
  void filterMedicine(DateTime startDate, DateTime endDate) {
    listMedicineTable = new List();
    if (listMedicine != null) {
      listMedicine.forEach((element) {
        if(element.measureTime.isAfter(startDate) && element.measureTime.isBefore(endDate)){
          setState(() {
            listMedicineTable.add(element);
          });
        }
      });
    }
  }
  
  Future<void> fetchWeight() async {
    String url = ip + "/api/getWeights.php?userID="+UserCurrent.userID.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<WeightModel> list= items.map<WeightModel>((json) {
        return WeightModel.fromJson(json);
      }).toList();

      if (list != null) {
        setState(() {
          listWeights = list;
        });
        filterWeight(this.startDate, this.endDate);
      }
    }
    else {
      throw Exception('Failed to load data.');
    }
  }
  void filterWeight(DateTime startDate, DateTime endDate) {
    int count = 0;
    double sum = 0;
    averageWeight = 0;
    listWeightsTable = new List();
    if (listWeights != null) {
      listWeights.forEach((element) {
        if(element.measureTime.isAfter(startDate) && element.measureTime.isBefore(endDate)){
          count++;
          setState(() {
            sum += double.tryParse(element.weight);
            listWeightsTable.add(element);
          });
        }
      });
      if (count != 0) {
        setState(() {
          averageWeight = sum/count;
        });
      }
    }
  }

  Future<void> fetchCarbs() async {
    String url = ip + "/api/getCarbs.php?userID="+UserCurrent.userID.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<CarbModel> list= items.map<CarbModel>((json) {
        return CarbModel.fromJson(json);
      }).toList();

      if (list != null) {
        setState(() {
          listCarbs = list;
        });
        filterCarb(this.startDate, this.endDate);
      }
    }
    else {
      throw Exception('Failed to load data.');
    }
  }
  void filterCarb(DateTime startDate, DateTime endDate) {
    int count = 0;
    double sum = 0;
    averageCarbs = 0;
    listCarbsTable = new List();
    if (listCarbs != null) {
      listCarbs.forEach((element) {
        if(element.measureTime.isAfter(startDate) && element.measureTime.isBefore(endDate)){
          count++;
          setState(() {
            sum += double.tryParse(element.carb);
            listCarbsTable.add(element);
          });
        }
      });
      if (count != 0) {
        setState(() {
          averageCarbs = sum/count;
        });
      }
    }
  }

  Future<void> fetchActivities() async {
    String url = ip + "/api/getActivities.php?userID="+UserCurrent.userID.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<ActivityModel> list= items.map<ActivityModel>((json) {
        return ActivityModel.fromJson(json);
      }).toList();

      if (list != null) {
        setState(() {
          listActivity = list;
        });
        filterActivity(this.startDate, this.endDate);
      }
    }
    else {
      throw Exception('Failed to load data.');
    }
  }

  void filterActivity(DateTime startDate, DateTime endDate) {
    int count = 0;
    double sum = 0;
    averageActivity = 0;
    listActivityTable = new List();
    if (listActivity != null) {
      listActivity.forEach((element) {
        if(element.measureTime.isAfter(startDate) && element.measureTime.isBefore(endDate)){
          count++;
          sum += double.tryParse(element.calo);
          setState(() {
            listActivityTable.add(element);
          });
        }
      });
      if (count != 0) {
        setState(() {
          averageActivity = sum/count;
        });
      }
    }
  }


  Future<void> fetchGlycemics() async {
    String url = ip + "/api/getGlycemics.php?userID="+UserCurrent.userID.toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<GlycemicModel> list= items.map<GlycemicModel>((json) {
        return GlycemicModel.fromJson(json);
      }).toList();

      if (list != null) {
        setState(() {
          listGlycemics = list;
        });
        filterGlycemics(this.startDate, this.endDate);
      }
    }
    else {
      throw Exception('Failed to load data.');
    }
  }
  void filterGlycemics(DateTime startDate, DateTime endDate) {
    int count = 0;
    double sum = 0;
    averageGlycemic = 0;
    listGlycemicsTable = new List();
    if (listGlycemics != null) {
      listGlycemics.forEach((element) {
        if(element.measureTime.isAfter(startDate) && element.measureTime.isBefore(endDate)){
          count++;
          sum+= double.tryParse(element.indexG);
          listGlycemicsTable.add(element);
        }
      });
      if (count != 0) {
        setState(() {
          averageGlycemic = sum/count;
        });
      }
    }
  }
  void fetchUser() async {

    String url = ip + "/api/getAccount.php";
    var response = await http.post(url, body: {
      'id': UserCurrent.userID.toString(),
    });

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      AccountModel inforAccount = AccountModel.fromJson(items[0]);
      await setInfor(inforAccount);
    } else {
      throw Exception('Failed to load data.');
    }
  }
  void setInfor(AccountModel inforAccount){
    setState(() {
      _name  = inforAccount.fullname;
      _email  = inforAccount.email;
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String type in _types) {
      items.add(new DropdownMenuItem(
          value: type,
          child: new Text(type)
      ));
    }
    return items;
  }

  generatePdfAndView(context) async {
    final pdfLib.Document pdf = pdfLib.Document(deflate: zlib.encode);
    var data = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    var myFont = pdfLib.Font.ttf(data);
    var myHeaderStyle = pdfLib.TextStyle(font: myFont, fontSize: 40, );
    var myTitleStyle = pdfLib.TextStyle(font: myFont, fontSize: 30, );
    var myStyle = pdfLib.TextStyle(font: myFont, fontSize: 20);
    pdf.addPage(
      pdfLib.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pdfLib.Header(
            child: pdfLib.Center(
              child: pdfLib.Column(
                children: [
                  pdfLib.Text(
                      "Báo cáo chỉ số",
                      style: myHeaderStyle
                  ),
                  pdfLib.Text("Thời gian: ${dateFormat.format(new DateTime.now())}", style: myStyle),
                ]
              )
            )
          ),
          pdfLib.Paragraph(text: "Bệnh nhân: ${_name} - Email: ${_email}", style: myStyle),
          pdfLib.Paragraph(text: "Từ ngày: ${dateFormat.format(startDate)} - Đến ngày: ${dateFormat.format(endDate)}", style: myStyle),
          (isWeight && listWeightsTable.length > 0) ?
                pdfLib.Center(
                  child: pdfLib.Text(
                    "Cân nặng",
                    style: myTitleStyle
                  )
                ): pdfLib.SizedBox(height: 1,),
          (isWeight && listWeightsTable.length > 0) ?
                pdfLib.Table.fromTextArray(context: context, cellStyle: myStyle, headerStyle: myStyle, data: <List<String>>[
                  <String>['Cân nặng', 'Thời gian', 'Chú thích'],
                  ...listWeightsTable.map(
                          (item) => [item.weight + " kg", dateFormat.format(item.measureTime), item.note.toString()])
                ]): pdfLib.SizedBox(height: 1,),
                pdfLib.SizedBox(height: 3,),
          (isWeight && listWeightsTable.length > 0) ?
                pdfLib.Center(
                    child: pdfLib.Text(
                        "Cân nặng trung bình: ${averageWeight.toStringAsFixed(2)} kg",
                        style: myStyle
                    )
                ): pdfLib.SizedBox(height: 1,),
                pdfLib.SizedBox(height: 5,),
          (isGlycemic && listGlycemicsTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Đường huyết",
                            style: myTitleStyle
                        )
                    ) : pdfLib.SizedBox(height: 1,),
          (isGlycemic && listGlycemicsTable.length > 0) ?
                    pdfLib.Table.fromTextArray(context: context, cellStyle: myStyle, headerStyle: myStyle, data: <List<String>>[
                      <String>['Đường huyết', 'Thời gian', 'Chú thích'],
                      ...listGlycemicsTable.map(
                              (item) => [item.indexG + " mg/dL", dateFormat.format(item.measureTime), item.note.toString()])
                    ]): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 5,),
          (isGlycemic && listGlycemicsTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Đường huyết trung bình: ${averageGlycemic.toStringAsFixed(2)} mg/dL",
                            style: myStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 5,),
          (isActivity && listActivityTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Thể thao",
                            style: myTitleStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
    (isActivity && listActivityTable.length > 0) ?
                    pdfLib.Table.fromTextArray(context: context, cellStyle: myStyle, headerStyle: myStyle, data: <List<String>>[
                      <String>['Hoạt động', 'Thời gian luyện tập', 'Năng lượng tiêu hao', 'Ngày', 'Chú thích'],
                      ...listActivityTable.map(
                              (item) => [item.nameActivity, item.timeActivity + " phút", item.calo + " kcal", dateFormat.format(item.measureTime), item.note.toString()])
                    ]): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 3,),
    (isActivity && listActivityTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Năng lượng tiêu hao trung bình: ${averageActivity.toStringAsFixed(2)} kcal",
                            style: myStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 5,),
    (isCarbs && listCarbsTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Lượng Carbon Hidrat tiêu thụ",
                            style: myTitleStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
    (isCarbs && listCarbsTable.length > 0) ?
                    pdfLib.Table.fromTextArray(context: context, cellStyle: myStyle, headerStyle: myStyle, data: <List<String>>[
                      <String>['Carbon Hidrat', 'Thời gian', 'Chú thích'],
                      ...listCarbsTable.map(
                              (item) => [item.carb + " g", dateFormat.format(item.measureTime), item.note.toString()])
                    ]): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 3,),
    (isCarbs && listCarbsTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Carbon Hidrat trung bình: ${averageCarbs.toStringAsFixed(2)} g",
                            style: myStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 5,),
          (isMedicine && listMedicineTable.length > 0) ?
                    pdfLib.Center(
                        child: pdfLib.Text(
                            "Thuốc",
                            style: myTitleStyle
                        )
                    ): pdfLib.SizedBox(height: 1,),
          (isMedicine && listMedicineTable.length > 0) ?
                    pdfLib.Table.fromTextArray(context: context, cellStyle: myStyle, headerStyle: myStyle, data: <List<String>>[
                      <String>['Tên thuốc', 'Liều lượng', 'Thời gian','Chú thích'],
                      ...listMedicineTable.map(
                              (item) => [item.name, item.amount + " " + item.unit, dateFormat.format(item.measureTime), item.note.toString()])
                    ]) : pdfLib.SizedBox(height: 1,),
                    pdfLib.SizedBox(height: 5,),
                  ]
              )
    );
    final String dir = (await getExternalStorageDirectory()).path;
    final String name = "report_${dateFormat.format(startDate)}.pdf";
    final String path = '$dir/${name}';
    final File file = File(path);
    await file.writeAsBytes(pdf.save());
    Fluttertoast.showToast(
        msg: "Lưu file thành công",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(path: path, name: name,),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Báo Cáo"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () => generatePdfAndView(context))
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                    _email
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text("Từ"),
                        FlatButton(onPressed: () async {
                          await DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2000,1,1),
                              maxTime: DateTime(2050,1,1),
                              locale: LocaleType.vi,
                              currentTime: DateTime.now(),
                              onChanged: (date){

                              },
                              onConfirm: (date) async {
                                if (date.isAfter(endDate)) {
                                  Fluttertoast.showToast(
                                      msg: "Ngày bắt đầu không phù hợp",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                } else {
                                  setState(() {
                                    startDate = date;
                                  });
                                  await filterWeight(startDate, endDate);
                                  await filterCarb(startDate, endDate);
                                  await filterActivity(startDate, endDate);
                                  await filterGlycemics(startDate, endDate);
                                  await filterMedicine(startDate, endDate);
                                }
                              }
                          );
                          },
                          child: Text(
                            DateFormat("dd/MM/yyyy").format(
                                startDate),
                            style: TextStyle(
                                color: Colors.blue[800],
                                fontFamily: 'Roboto',
                                fontSize: 16)
                        ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Text("Đến"),
                        FlatButton(onPressed: () async {
                          await DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2000,1,1),
                              maxTime: DateTime(2050,1,1),
                              locale: LocaleType.vi,
                              currentTime: DateTime.now(),
                              onChanged: (date){

                              },
                              onConfirm: (date) async {
                                if (date.isBefore(startDate)) {
                                  Fluttertoast.showToast(
                                      msg: "Ngày kết thúc không phù hợp",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                } else {
                                  setState(() {
                                    endDate = date;
                                  });
                                  await filterWeight(startDate, endDate);
                                  await filterCarb(startDate, endDate);
                                  await filterActivity(startDate, endDate);
                                  await filterGlycemics(startDate, endDate);
                                  await filterMedicine(startDate, endDate);
                                }
                              }
                          );
                        }, child: Text(
                            DateFormat("dd/MM/yyyy").format(
                                endDate),
                            style: TextStyle(
                                color: Colors.blue[800],
                                fontFamily: 'Roboto',
                                fontSize: 16)
                        ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Thông tin:",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton(
                  value: _currentType,
                  items: _dropDownMenuItems,
                  onChanged: changedDropDownItem,
                )
              ],
            ),
            (isWeight == true) ?
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Cân nặng",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.black,
                  ),
                  DataTable(
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Cân nặng (kg)',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Thời gian',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      rows: listWeightsTable.map(
                              (e) => DataRow(
                              cells: <DataCell>[
                                DataCell(Text(e.weight + " kg")),
                                DataCell(Text(dateFormat.format(e.measureTime))),
                              ]
                          )
                      ).toList()
                  ),
                  ListTile(
                    title: Text(
                      "Cân nặng trung bình: ${averageWeight.toStringAsFixed(2)} kg",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
            ):
            SizedBox(height: 1,),
            (isGlycemic == true) ?
            Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Đường huyết",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListTile(
                      leading: Text(
                        "Thấp",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue
                        ),
                        textAlign: TextAlign.center,
                      ),
                      title: Text(
                        "Tốt",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                        ),
                        textAlign: TextAlign.center,
                      ),
                      trailing: Text(
                        "Cao",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                    DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Đường huyết',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Thời gian',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: listGlycemicsTable.map(
                                (e) => DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                      Text(e.indexG + " mg/dL", style: TextStyle(
                                        color: (double.tryParse(e.indexG) < 70) ? Colors.blue : (double.tryParse(e.indexG) > 180) ? Colors.red : Colors.green
                                      ),
                                      )
                                  ),
                                  DataCell(Text(dateFormat.format(e.measureTime))),
                                ]
                            )
                        ).toList()
                    ),
                    ListTile(
                      leading: Text(
                        "Đường huyết trung bình: ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      title: Text(
                        " ${averageGlycemic.toStringAsFixed(2)} mg/dL",
                        style: TextStyle(
                          fontSize: 15,
                            color: (averageGlycemic < 70) ? Colors.yellow : (averageGlycemic > 180) ? Colors.red : Colors.green
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
            ):
            SizedBox(height: 1,),
            (isActivity == true) ?
            Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Hoạt động",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                    DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Tên',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Kcal',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Thời gian',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),

                        ],
                        rows: listActivityTable.map(
                                (e) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(e.nameActivity.toString())),
                                  DataCell(Text(double.tryParse(e.calo).toStringAsFixed(2))),
                                  DataCell(Text(dateFormat.format(e.measureTime))),
                                ]
                            )
                        ).toList()
                    ),
                    ListTile(
                      title: Text(
                        "Năng lượng tiêu hao trung bình: ${averageActivity.toStringAsFixed(2)} Kcal",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
            ):
            SizedBox(height: 1,),
            (isCarbs == true) ?
            Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Thức ăn",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                    DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Carbs (g)',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Thời gian',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: listCarbsTable.map(
                                (e) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(e.carb)),
                                  DataCell(Text(dateFormat.format(e.measureTime))),
                                ]
                            )
                        ).toList()
                    ),
                    ListTile(
                      title: Text(
                        "Carbs trung bình: ${averageCarbs.toStringAsFixed(2)} g",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
            ):
            SizedBox(height: 1,),
            (isMedicine == true) ?
            Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Thuốc",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                    DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Tên',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Lượng',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Thời gian',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: listMedicineTable.map(
                                (e) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(e.name)),
                                  DataCell(Text(e.amount + " ${e.unit}")),
                                  DataCell(Text(dateFormat.format(e.measureTime))),
                                ]
                            )
                        ).toList()
                    ),
                  ],
                )
            ):
            SizedBox(height: 1,),

          ],
        ),
      ),
    );
  }

  void changedDropDownItem(String selectedCity) {
    //"Tất cả", "Đường huyết", "Hoạt động", "Carbs", "Cân nặng"
    setState(() {
      if(selectedCity == "Tất cả"){
        setState(() {
          isWeight = true;
          isCarbs = true;
          isActivity = true;
          isGlycemic = true;
          isMedicine = true;
          _currentType = selectedCity;
        });
      } else if (selectedCity == "Đường huyết"){
        setState(() {
          isWeight = false;
          isCarbs = false;
          isActivity = false;
          isGlycemic = true;
          isMedicine = false;
          _currentType = selectedCity;
        });
      } else if (selectedCity == "Carbs"){
        setState(() {
          isWeight = false;
          isCarbs = true;
          isActivity = false;
          isGlycemic = false;
          isMedicine = false;
          _currentType = selectedCity;
        });
      } else if (selectedCity == "Cân nặng"){
        setState(() {
          isWeight = true;
          isCarbs = false;
          isActivity = false;
          isGlycemic = false;
          isMedicine = false;
          _currentType = selectedCity;
        });
      } else if (selectedCity == "Thuốc"){
        setState(() {
          isWeight = false;
          isCarbs = false;
          isActivity = false;
          isGlycemic = false;
          isMedicine = true;
          _currentType = selectedCity;
        });
      }
      else if (selectedCity == "Hoạt động"){
        setState(() {
          isWeight = false;
          isCarbs = false;
          isActivity = true;
          isGlycemic = false;
          isMedicine = false;
          _currentType = selectedCity;
        });
      }
    });
  }
}
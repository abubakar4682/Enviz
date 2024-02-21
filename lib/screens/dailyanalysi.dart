import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/BoxwithIcon.dart';
import '../widgets/CustomText.dart';
import '../widgets/Cutom_button.dart';
import '../widgets/SideDrawer.dart';



class Dailyanalusic extends StatefulWidget {
  @override
  State<Dailyanalusic> createState() => _DailyanalusicState();
}

class _DailyanalusicState extends State<Dailyanalusic> {
  @override
  Widget build(BuildContext context) {
    DateTime _selectedDate = DateTime.now();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: Sidedrawer(context: context),
          appBar: AppBar(
            title: Center(
              child: CustomText(
                texts: 'daily analysis',
                textColor: const Color(0xff002F46),
              ),
            ),
            actions: [
              BoxwithIcon(),
            ],
          ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  texts: 'select multiple dates',
                  textColor: const Color(0xff002F46),
                ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                padding: EdgeInsets.fromLTRB(26, 4, 26, 0),
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x26000000),
                      offset: Offset(0, 11),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate), // Format the date
                      style: TextStyle(fontSize: 16),
                    ),
          
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.calendar_today, size: 20,),
                      onPressed: () {
                        // Call showDatePicker function
                        showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light(), // You can customize the theme here
                              child: child!,
                            );
                          },
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            setState(() {
                              _selectedDate = selectedDate;
                            });
                          }
                        });
                      },
                    ),
          
                  ],
                ),
              ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: CustomText(
                        texts: 'start time',
                        textColor: const Color(0xff002F46),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: CustomText(
                        texts: 'end time',
                        textColor: const Color(0xff002F46),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child:  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      padding: EdgeInsets.fromLTRB(26, 4, 26, 0),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            offset: Offset(0, 11),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        initialValue: '10',
                        decoration: InputDecoration(
          
                          border: InputBorder.none, // Remove the default border of the input field
                        ),
                      ),
                    ),),
                    Expanded(child:  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      padding: EdgeInsets.fromLTRB(26, 4, 26, 0),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            offset: Offset(0, 11),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        initialValue: '10',
                        decoration: InputDecoration(
          
                          border: InputBorder.none, // Remove the default border of the input field
                        ),
                      ),
                    ),)
                  ],
                ),
          
          
          
          
          
          
                SizedBox(height: 16),
          
                SizedBox(height: 24),
                Text('Energy: 150.77'),
                Text('Avg. Power: 6.28'),
                Text('Min: 1.64'),
                Text('Max: 9.94'),
                SizedBox(height: 24),
                FilledRedButton(
                  onPressed: () {
          
                  },
                  text: 'download',
                ),
                SizedBox(height: 24),
                Text('Multiple PDFs will be downloaded showcasing analytics.',style: TextStyle(
                  fontSize: 10
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

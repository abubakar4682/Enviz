import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';


import '../controller/historical/historical_controller.dart';

class SelectStartndEndingDate extends StatelessWidget {
  const SelectStartndEndingDate({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  final HistoricalController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(left: 10, right: 10,top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Expanded(
            flex: 1,
            child: Container(
              margin:  EdgeInsets.fromLTRB(0, 0, 10, 0),
              padding:  EdgeInsets.fromLTRB(26, 4, 26, 0),
              height:  40,
              decoration:  BoxDecoration (
                color:  Color(0xffffffff),
                borderRadius:  BorderRadius.circular(60),
                boxShadow:  [
                  BoxShadow(
                    color:  Color(0x26000000),
                    offset:  Offset(0, 11),
                    blurRadius:  12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Obx(
                        () => Text('${controller.startDate.value}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_drop_down,size: 30,),
                    onPressed: () =>{ controller.selectStartDate(context)

                    },

                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),



          Expanded(
            flex: 1,
            child: Container(
              margin:  EdgeInsets.fromLTRB(0, 0, 10, 0),
              padding:  EdgeInsets.fromLTRB(26, 4, 26, 0),
              height:  40,
              decoration:  BoxDecoration (
                color:  Color(0xffffffff),
                borderRadius:  BorderRadius.circular(60),
                boxShadow:  [
                  BoxShadow(
                    color:  Color(0x26000000),
                    offset:  Offset(0, 11),
                    blurRadius:  12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Obx(
                        () => Text(' ${controller.endDate.value}'),
                  ),
                  //Text('${controller.endDate}'),
                  IconButton(
                    icon: Icon(Icons.arrow_drop_down,size: 30,),
                    onPressed: () => controller.selectEndDate(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
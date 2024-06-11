
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highcharts_demo/screens/splashe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../JS_Web_View/View/View_for_month.dart';
import '../JS_Web_View/js_coloum_web.dart';
import '../controller/Live/live_controller.dart';
import '../controller/NotificationController/notification_time.dart';
import '../controller/NotificationController/toggle_controller.dart';
import '../controller/Summary_Controller/pie_chart_for_this_month.dart';
import '../controller/Summary_Controller/pie_chart_this_week.dart';
import '../controller/auth_controller/login_controller.dart';
import '../controller/datacontroller.dart';
import '../controller/historical/historical_controller.dart';

import '../screens/SummaryTab/this_month.dart';
import '../screens/SummaryTab/this_week.dart';

import '../today.dart';
import 'custom_text.dart';

class Sidedrawer extends StatelessWidget {
  const Sidedrawer({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  Future<Map<String, String?>> getDrawerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'displayName': prefs.getString('displayName'),
      'email': prefs.getString('email'),
    };
  }

  Future<void> clearAllSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all shared preferences data
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, String?>>(
            future: getDrawerData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return UserAccountsDrawerHeader(
                  accountName: Text(snapshot.data!['displayName'] ?? ''),
                  accountEmail: Text(snapshot.data!['email'] ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xff009F8D), // Replace with your desired color
                  ),
                );
              } else {
                // Display a loading indicator or placeholder
                return const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Loading...'),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Color(0xff009F8D),
            ),
            title: const Text('Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrgChartScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Color(0xff009F8D)),
            trailing: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            title: const Text("Contact Support"),
            onTap: () => _showSupportContact(context),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xff009F8D)),
            title: const Text('Setting'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
              // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xff009F8D)),
            title: const Text('Logout'),
            onTap: () async {
              final MonthColoumDataControllerss monthColoumDataController=Get.put(MonthColoumDataControllerss());
              monthColoumDataController.resetController();

              Get.delete<MonthDataControllerForPieChart>();

              final MonthDataControllerForPieChart monthDataControllerForPieChart =
              Get.put(MonthDataControllerForPieChart());
              monthDataControllerForPieChart.clearUserData();

              Get.delete<MonthColoumDataControllerss>();
              final HistoricalController historicalController =
                  Get.put(HistoricalController());
              final WeekDataControllerForPieChart weekDataControllerForPieChart =
              Get.put(WeekDataControllerForPieChart());
              weekDataControllerForPieChart.logout();
              final LiveDataControllers LiveControler =
              Get.put(LiveDataControllers());
              LiveControler.cleardb();
              final WeekDataControllerss coloumchart =
              Get.put(WeekDataControllerss());
              Get.delete<WeekDataControllerForPieChart>();
              Get.delete<WeekDataControllerss>();
              coloumchart.resetController();
              weekDataControllerForPieChart.clearUserData();


              final DataControllers loginController =
                  Get.put(DataControllers());
              final WeekDataController weekDataController =
                  Get.put(WeekDataController());
              final DataControllerForThisMonth monthDataController =
                  Get.put(DataControllerForThisMonth());
              final LoginControllers loginControllers =
                  Get.put(LoginControllers());
              final NotificationController notificationController =
                  Get.put(NotificationController());

              Get.delete<LiveDataControllers>();
              Get.delete<LoginControllers>();
              Get.delete<HistoricalController>();
              Get.delete<
                  WeekDataController>(); // Clear the WeekDataController from memory
              Get.delete<DataControllerForThisMonth>();
              Get.delete<NotificationController>();

              // Reset the controllers' state
              notificationController.resetNotificationsOnLogout();
              loginControllers.resetloginController();
              loginController.resetloginController();
              historicalController.resetController();
              weekDataController
                  .resetController(); // Reset week data controller
              monthDataController.resetController();
              await clearAllSharedPreferences(); // Clear all SharedPreferences data

              // Navigate to the SplashScreen, and then immediately to the Login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationController controller = Get.put(NotificationController());
  final LimitController limitController = Get.put(LimitController());
  final TextEditingController textEditingController = TextEditingController();
  bool notificationsEnabled = false;
  String selectedHour = 'Not set';
  String notificationLimit = '';

  void _showHourPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Hour"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 24,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text("$index"),
                  onTap: () {
                    controller.updateHour("$index");
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: CustomText(
            texts: 'Settings',
            textColor: const Color(0xff002F46),
          ),
        ),
        actions: [
          SizedBox(
            width: 40,
            height: 30,
            child: Image.asset('assets/images/Vector.png'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: const Color(0xff009F8D).withOpacity(0.5),
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active,
                      color: Color(0xff009F8D)),
                  title: const Text("Enable Notifications",
                      style: TextStyle(color: Color(0xff002F46))),
                  trailing: Obx(() => Switch(
                        //   activeColor: Color(0xff009F8D), // Color of the track when switch is active
                        activeTrackColor: const Color(0xff009F8D),
                        // Color of the thumb when switch is active
                        value: controller.notificationsEnabled.value,
                        onChanged: (bool value) {
                          controller.toggleNotifications(value);
                        },
                      )),
                )
              ],
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: const Color(0xff009F8D).withOpacity(0.5),
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xff009F8D)),
              title: const Text("Notification Hour",
                  style: TextStyle(color: Color(0xff002F46))),
              subtitle: Obx(() => Text(controller.selectedHour.value)),
              onTap: () => _showHourPicker(context),
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: const Color(0xff009F8D).withOpacity(0.5),
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Color(0xff009F8D)),
                    title: const Text("Setting Notification Limit (kW)",
                        style: TextStyle(color: Color(0xff002F46))),
                    subtitle: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: "Enter limit in kW",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Adds some space between the text field and the button
                  ElevatedButton(
                    onPressed: () {
                      // Get the text from the TextEditingController and pass it to the updateLimit method
                      if (textEditingController.text.isNotEmpty) {
                        limitController.updateLimit(textEditingController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xff009F8D), // Button text color
                    ),
                    child: const Text('Set'),
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

void _showSupportContact(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Contact Support"),
        content: RichText(
          text: const TextSpan(
            style: TextStyle(
              // Default text style
              color: Colors.black,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: "For support, email us at ",
              ),
              TextSpan(
                text: "contact@energyinformatics.pk",
                style: TextStyle(
                  // Larger font for email
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " or call us at ",
              ),
              TextSpan(
                text: "(92) 330 163 7589",
                style: TextStyle(
                  // Larger font for phone number
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ".",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}



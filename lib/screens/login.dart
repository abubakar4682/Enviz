import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Theme/theme.dart';
import '../Utils/colors.dart';
import '../controller/datacontroller.dart';
import '../controller/summaryedController.dart';
import '../widgets/Cutom_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final authController = Get.put(DataControllers());
 // final summaryController = Get.put(SummaryysControllers());


  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                  child: SizedBox(
                    height: 78,
                    width: 148,
                    child: Image(
                      image: AssetImage('assets/images/enfologo.png'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'Please authenticate',
                  style: inoTheme.mainHeading,
                ),
              ),
              const SizedBox(
                width: 30,
                height: 10,
              ),
              TextField(
                onChanged: (value) =>
                authController.usernamenameController.text = value,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const SizedBox(
                height: 20,
              ),
              PasswordTextField(),
              const SizedBox(height: 30),
              Obx(() {
                return authController.loading.value
                    ? Center(child: CircularProgressIndicator())
                    : FilledRedButton(
                  onPressed: () {
                    authController.userRegister();
                  //  summaryController.fetchData();
                  },
                  text: 'Login',
                );
              }),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    showForgotPasswordDialog(context);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
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

  void showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Text('Kindly contact the admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}



class PasswordTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<DataControllers>();

    return Obx(() => TextField(
      onChanged: (value) => authController.passwordController.text = value,
      obscureText: !authController.showPassword.value,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: authController.showPassword.value
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
          onPressed: () {
            authController.showPassword.toggle();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    ));
  }
}
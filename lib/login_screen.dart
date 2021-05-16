import 'forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'backend_services.dart';
import 'home_screen.dart';
import 'registration_screen.dart';
import 'common.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Blood Safe",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white
                : Colors.black38,
          ),
        ),
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.grey.shade900
                : Colors.white,
      ),
      body: CustomForm(),
    );
  }
}

class CustomForm extends StatefulWidget {
  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  static final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Image(
              image: AssetImage("images/splash4.png"),
            ),
          ),
          TextBox(
            textController: _emailController,
            validationFunction: (String string) {
              if (string.isEmpty)
                return "Field empty";
              else
                return EmailValidator(errorText: '').isValid(string) != true
                    ? 'Enter a valid email address'
                    : null;
            },
            hintText: "Email ID: eg Mike@gmail.com",
          ),
          TextBox(
            textController: _passwordController,
            validationFunction: MultiValidator([
              RequiredValidator(errorText: 'password is required'),
              MinLengthValidator(8,
                  errorText: 'password must be at least 8 digits long'),
              PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                  errorText:
                      'passwords must have at least one special character')
            ]),
            hintText: "Password",
            obscureText: true,
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () async {
                final task = await (Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => ResetPasswordScreen()),
                ));
              },
              child: Container(
                margin: EdgeInsets.only(top: 5, bottom: 15),
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Button(
              text: "Login",
              onPressed: () async {
                UserRec user;
                if (_formKey.currentState.validate()) {
                  Auth auth = new Auth();
                  await auth
                      .signIn(_emailController.text, _passwordController.text)
                      .then((value) {
                    user = value;
                    //  print("DATA ${user.emailID}");
                  }).whenComplete(() {
                    // print("DATA  ${user.userName} ${user.emailID}");
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        action: auth.state == STATE.SUCCESS &&
                                user.message ==
                                    "Please check your mail for the verification link"
                            ? SnackBarAction(
                                label: "Resend",
                                onPressed: () {
                                  auth.sendVerficationLink(user.user);
                                },
                              )
                            : null,
                        content: Text(
                          "${user.message}",
                        ),
                      ),
                    );
                    if (auth.state == STATE.SUCCESS &&
                        user.message !=
                            "Please check your mail for the verification link")
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => HomeScreen(user)),
                      );
                  });
                } else
                  FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ),
          GestureDetector(
            onTap: () async {
              final task = await (Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => RegistrationScreen()),
              ));
            },
            child: Container(
              margin: EdgeInsets.all(20),
              child: Text(
                "Create new account",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

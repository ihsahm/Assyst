import 'package:assyst/Authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Map<String, dynamic> _profile;
  bool loading = false;
  final formKey = new GlobalKey<FormState>();
  String phoneNo, verificationId, smsCode;
  bool codeSent = false;

  //String phoneNumber;
  //String phoneIsoCode;

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNo = internationalizedPhoneNumber;
      print(internationalizedPhoneNumber);
    });
  }

  Future<void> verifyPhone(phoneNo) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    final PhoneVerificationCompleted verified =
        (AuthCredential authResult) async {
      AuthPhone().signIn(authResult);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('$authException.message'),
      ));
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  final globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/volkswagen.jpg"),
          fit: BoxFit.cover,
        )),
        //color: Colors.white,
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 6.0,
                          )
                        ]),
                    margin: EdgeInsets.fromLTRB(20, 100, 20, 20),
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 60),
                    child: Column(
                      children: <Widget>[
                        Text('Enter your phone number below',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w300,
                            )),
                        Divider(),
                        SizedBox(height: 50),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              InternationalPhoneInput(
                                  errorText: 'Insert a valid phone',
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    hintText: '912345678',
                                  ),
                                  onPhoneNumberChange: onPhoneNumberChange,
                                  initialPhoneNumber: phoneNo,
                                  initialSelection: 'ET',
                                  enabledCountries: ['+251'],
                                  showCountryFlags: false,
                                  showCountryCodes: true),
                              /*  TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter a phone number';
                                  }
                                  return null;
                                },
                                // keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    labelText: 'Enter your phone number',
                                    prefixIcon: Icon(Icons.phone)),
                                onChanged: (val) {
                                  setState(() {
                                    this.phoneNo = val;
                                  });
                                },
                              ),*/
                              SizedBox(height: 20),
                              codeSent
                                  ? TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: 'Enter sent code',
                                          prefixIcon: Icon(Icons.code)),
                                      onChanged: (val) {
                                        setState(() {
                                          this.smsCode = val;
                                        });
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ButtonTheme(
                          minWidth: 250.0,
                          height: 50.0,
                          buttonColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textTheme: ButtonTextTheme.accent,
                          child: FlatButton(
                            child: codeSent
                                ? Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                            onPressed: () {
                              if (formKey.currentState.validate()) {
                                final snackBar = SnackBar(
                                    backgroundColor: Colors.white,
                                    content: Text(
                                      'Please wait while code is being sent\n\nLogin will be automatic',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ));
                                globalKey.currentState.showSnackBar(snackBar);
                              }
                              codeSent
                                  ? AuthPhone()
                                      .signInWithOTP(smsCode, verificationId)
                                  : verifyPhone(phoneNo);
                            },
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ButtonTheme(
                            minWidth: 250.0,
                            height: 50.0,
                            buttonColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60)),
                            child: FlatButton(
                                child: Text('Skip'), onPressed: () {}))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copyright,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Assyst',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

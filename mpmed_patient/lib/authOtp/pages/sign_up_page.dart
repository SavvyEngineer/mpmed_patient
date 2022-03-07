import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mpmed_patient/authOtp/form_validator.dart';
import 'package:mpmed_patient/authOtp/sign_up_data.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import '../stores/login_store.dart';
import '../theme.dart';
import '../widgets/loader_hud.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  String nationalCode;
  SignUpPage(this.nationalCode);
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File? _image;
  GlobalKey<FormState> _formKey = new GlobalKey();
  bool _validate = false;
  SignUpData _signUpData = SignUpData();
  bool _obscureText = true;
  String text = '';
  String label = 'لطفاً تاریخ تولد خود را تعیین کنید';
  bool isUsedMdApp = false;
  Map<String, dynamic> map = {};
  String country = '';

  final _nameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _fatherFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _specialtyFocusNode = FocusNode();
  final _mdcodeFocusNode = FocusNode();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _fatherFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    _specialtyFocusNode.dispose();
    _mdcodeFocusNode.dispose();
    super.dispose();
  }

  Future getImagefromcamera() async {
    //  var image = await ImagePicker.(source: ImageSource.camera);
    setState(() {
      //    _image = image;
    });
  }

  Future getImagefromGallery() async {
    //  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      //  _image = image;
    });
  }

  Widget _TextReciver(
      String hinttext,
      String key,
      TextInputAction textInputAction,
      TextInputType textInputType,
      FocusNode focusNode,
      FocusNode _nextFocus) {
    return new TextFormField(
      keyboardType: textInputType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: (_) {
        if (textInputAction != TextInputAction.done) {
          FocusScope.of(context).requestFocus(_nextFocus);
        }
      },
      decoration: InputDecoration(
        hintText: hinttext,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      // validator: FormValidator().validateEmail,
      onSaved: (value) {
        map[key] = value.toString();
      },
    );
  }

  _sendToServer() {
    //if (_key.currentState.validate()) {
    /// No any error in validation
    _formKey.currentState!.save();
    print("Email ${_signUpData.email}");
    print("Password ${_signUpData.name}");

    // map["name"] = _signUpData.name;
    // map["email"] = _signUpData.email;
    // map["mobile"] = _signUpData.phoneNumber;
    // map["lastName"] = _signUpData.lastName;
    // map["fatherName"] = _signUpData.fatherName;
    // map["birthDate"] = _signUpData.birthDate;
    // map["wcity"] = _signUpData.wcity;
    // map["wstate"] = _signUpData.wstate;
    map["national_code"] = widget.nationalCode;
    map["notif_token"] = 'notif_token';
    // map["md_code"] = _signUpData.md_code;
    // map["specialty"] = _signUpData.specialty;
    // if (isUsedMdApp) {
    //   map["used_md_app"] = '1';
    // } else {
    //   map["used_md_app"] = '0';
    // }

    Provider.of<LoginStore>(context, listen: false)
        .signUp(context, map);

    // } else {
    ///validation error
    //   setState(() {
    //_validate = true;
    //   });
    //  }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Observer(
          builder: (_) => LoaderHUD(
            inAsyncCall: loginStore.isSignUpLoading,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: loginStore.signUpScaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: MyColors.primaryColorLight.withAlpha(20),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: MyColors.primaryColor,
                      size: 16,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                elevation: 0,
                backgroundColor: Colors.white,
                brightness: Brightness.light,
              ),
              body: SafeArea(
                child: new Center(
                  child: new SingleChildScrollView(
                    child: new Container(
                      margin: new EdgeInsets.all(20.0),
                      child: Center(
                        child: new Form(
                          key: _formKey,
                          child: _getFormUI(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getFormUI() {
    return new Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Icon(
            Icons.person,
            color: Colors.lightBlue,
            size: 100.0,
          )),
        ),
        new SizedBox(height: 50.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: _TextReciver("نام", "name", TextInputAction.next,
                    TextInputType.name, _nameFocusNode, _lastNameFocusNode)),
            SizedBox(
                width: MediaQuery.of(context).size.width * .5 - 10,
                child: _TextReciver(
                    "نام خانوادگی",
                    "lastName",
                    TextInputAction.next,
                    TextInputType.name,
                    _lastNameFocusNode,
                    _fatherFocusNode)),
          ],
        ),

        new SizedBox(height: 20.0),
        _TextReciver("نام پدر", "fatherName", TextInputAction.next,
            TextInputType.text, _fatherFocusNode, _emailFocusNode),
        new SizedBox(height: 15.0),
        _TextReciver("پست الکترونیک", "email", TextInputAction.next,
            TextInputType.emailAddress, _emailFocusNode, _mobileFocusNode),
        new SizedBox(height: 15.0),
        _TextReciver("شماره موبایل", "mobile", TextInputAction.next,
            TextInputType.phone, _mobileFocusNode, null as FocusNode),
        FlatButton(
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.blue, width: 1, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(50)),
          onPressed: () async {
            Jalali? picked = await showPersianDatePicker(
              context: context,
              initialDate: Jalali.now(),
              firstDate: Jalali(1200, 1),
              lastDate: Jalali.now(),
            );
            if (picked != null && picked != _signUpData.birthDate) {
              setState(() {
                label = picked.toJalaliDateTime();
                map["birthDate"] = label.toString();
              });
            }
          },
          child: Text(label),
        ),

        CSCPicker(
          ///Enable disable state dropdown [OPTIONAL PARAMETER]
          showStates: true,

          /// Enable disable city drop down [OPTIONAL PARAMETER]
          showCities: true,

          ///Enable (get flag with country name) / Disable (Disable flag) / ShowInDropdownOnly (display flag in dropdown only) [OPTIONAL PARAMETER]
          flagState: CountryFlag.ENABLE,

          ///Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER] (USE with disabledDropdownDecoration)
          dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1)),

          ///Disabled Dropdown box decoration to style your dropdown selector [OPTIONAL PARAMETER]  (USE with disabled dropdownDecoration)
          disabledDropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.grey.shade300, width: 1)),

          ///Default Country
          defaultCountry: DefaultCountry.Iran,

          ///selected item style [OPTIONAL PARAMETER]
          selectedItemStyle: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),

          ///DropdownDialog Heading style [OPTIONAL PARAMETER]
          dropdownHeadingStyle: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),

          ///DropdownDialog Item style [OPTIONAL PARAMETER]
          dropdownItemStyle: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),

          ///Dialog box radius [OPTIONAL PARAMETER]
          dropdownDialogRadius: 10.0,

          ///Search bar radius [OPTIONAL PARAMETER]
          searchBarRadius: 10.0,

          ///triggers once country selected in dropdown
          onCountryChanged: (value) {
            setState(() {
              ///store value in country variable
              country = value;
            });
          },

          ///triggers once state selected in dropdown
          onStateChanged: (value) {
            setState(() {
              ///store value in state variable
              map["bstate"] = value as String;
            });
          },

          ///triggers once city selected in dropdown
          onCityChanged: (value) {
            setState(() {
              ///store value in city variable
              map["bcity"] = value as String;
            });
          },
        ),

        new Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              _sendToServer();
            },
            padding: EdgeInsets.all(12),
            color: Colors.lightBlueAccent,
            child: Text('ثبت نام', style: TextStyle(color: Colors.white)),
          ),
        ),
        // new FlatButton(
        //   child: Text(
        //     'Forgot password?',
        //     style: TextStyle(color: Colors.black54),
        //   ),
        //   onPressed: _showForgotPasswordDialog,
        // ),
        // new FlatButton(
        //   onPressed: _sendToRegisterPage,
        //   child: Text('Not a member? Sign up now',
        //       style: TextStyle(color: Colors.black54)),
        // ),
      ],
    );
  }
}

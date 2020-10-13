import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import './model/contact.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
Contact newContact = new Contact();

void main() => runApp(MyApp());

DateTime convertToDate(String input) {
  try {
    var d = new DateFormat.yMd().parseStrict(input);
    return d;
  } catch (e) {
    return null;
  }
}

bool isValidDob(String dob) {
  if (dob.isEmpty) return true;
  var d = convertToDate(dob);

  return d != null && d.isBefore(new DateTime.now());
}

bool isValidPhoneNumber(String input) {
  final RegExp regex = new RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
  return regex.hasMatch(input);
}

bool isValidEmail(String input) {
  final RegExp regex = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return regex.hasMatch(input);
}

void _submitForm() {
  final FormState form = _formKey.currentState;

  if (!form.validate()) {
    showMessage('Form is not valid. Please review and correct');
  } else {
    form.save();
    print('Form save is called');
    print('Email: ${newContact.email}');
    print('Name: ${newContact.name}');
    print('Name: ${newContact.dob}');
    print('Name: ${newContact.phone}');
    print('Name: ${newContact.favoriteColor}');
  }
}

void showMessage(String messsage, [MaterialColor color = Colors.red]) {
  _scaffoldKey.currentState.showSnackBar(
      new SnackBar(backgroundColor: color, content: Text(messsage)));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Form Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Flutter Form Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _colors = <String>['', 'Red', 'Blue', 'Green', 'Orange'];
  String _color = '';

  final TextEditingController _controller = new TextEditingController();
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;

    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      _controller.text = DateFormat.yMd().format(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter your first and last name',
                  labelText: 'Name',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(32)],
                validator: (val) => val.isEmpty ? 'Name is required' : null,
                onSaved: (val) => newContact.name,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.calendar_today),
                        hintText: 'Enter your date of birth',
                        labelText: 'DOB',
                      ),
                      controller: _controller,
                      keyboardType: TextInputType.datetime,
                      validator: (val) =>
                          isValidDob(val) ? null : 'Not a valid date',
                      onSaved: (val) => newContact.dob = convertToDate(val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    tooltip: 'Choose date',
                    onPressed: (() {
                      _chooseDate(context, _controller.text);
                    }),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: 'Enter a phone number',
                  labelText: 'Phone',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    isValidPhoneNumber(value) ? null : 'Invalid phone number',
                onSaved: (val) => newContact.phone = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'Enter Email address',
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    isValidEmail(value) ? null : 'Enter valid email',
                onSaved: (val) => newContact.email = val,
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.color_lens),
                      labelText: 'Color',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: _color == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: _color,
                        isDense: true,
                        onChanged: (String value) {
                          newContact.favoriteColor = value;
                          _color = value;
                          state.didChange(value);
                        },
                        items: _colors.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                validator: (val) {
                  return val != '' ? null : 'Please select an item';
                },
              ),
              Container(
                padding: EdgeInsets.only(left: 40, top: 20),
                child: RaisedButton(
                  child: Text('Submit'),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

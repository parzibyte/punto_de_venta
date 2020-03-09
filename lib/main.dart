import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const RUTA_API = "http://192.168.1.73/sistema_ventas_laravel/public/api/auth";
var rutaLogin = "$RUTA_API/login";

void main() => runApp(MyApp());

Future<String> hacerLogin(String email, String password) async {
  final http.Response response = await http.post(
    rutaLogin,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  if (response.statusCode == 200) {
    Map<String, dynamic> j = json.decode(response.body);
    var token = j["access_token"];
    return token;
  } else {
    throw Exception('Datos incorrectos');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de venta',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Inicio de sesión'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  Future<String> _futureLogin;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            (_futureLogin != null)
                ? FutureBuilder<String>(
                    future: _futureLogin,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data);
                      } else if (snapshot.hasError) {
                        return Text("Error iniciando sesión");
                      }
                      return CircularProgressIndicator();
                    },
                  )
                : Text(""),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _email,
                decoration: InputDecoration(
                    hintText: 'corre@dominio', labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _password,
                decoration: InputDecoration(
                    hintText: 'Contraseña', labelText: 'Contraseña'),
                obscureText: true, /* <-- Aquí */
              ),
            ),
            RaisedButton(
              child: Text('Iniciar sesión'),
              onPressed: () {
                setState(() {
                  _futureLogin = hacerLogin(_email.text, _password.text);
                });
//                  final scaffold = Scaffold.of(context);
//                  scaffold.showSnackBar(
//                    SnackBar(
//                      content: const Text('Ejemplo'),
//                    ),
//                  );
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

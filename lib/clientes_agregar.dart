import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'clase_cliente.dart';
import 'constantes.dart';

class AgregarCliente extends StatefulWidget {
  AgregarCliente({Key key}) : super(key: key);

  @override
  AgregarClienteState createState() => AgregarClienteState();
}

class AgregarClienteState extends State<AgregarCliente> {
  final _claveFormulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _telefono = TextEditingController();

  Future<bool> agregarCliente(Cliente cliente) async {
    setState(() {
      cargando = true;
    });
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String posibleToken = prefs.getString("token_api");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
      return false;
    }
    log("Haciendo petición...");
    final http.Response response = await http.post(
      "$RUTA_API/cliente",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
      body: jsonEncode(<String, String>{
        'nombre': cliente.nombre,
        'telefono': cliente.telefono,
      }),
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    setState(() {
      cargando = false;
    });
    return response.statusCode == 200;
  }

  bool cargando = false;

  AgregarClienteState({Key key}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar cliente"),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(shrinkWrap: true, children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe el nombre';
                }
                return null;
              },
              controller: _nombre,
              decoration: InputDecoration(
                hintText: 'Escribe el nombre',
                labelText: "Nombre del cliente",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe el teléfono';
                }
                return null;
              },
              controller: _telefono,
              decoration: InputDecoration(
                hintText: 'Escribe el teléfono',
                labelText: "Teléfono",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) => RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: cargando
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text("Guardar"),
                onPressed: () async {
                  if (!_claveFormulario.currentState.validate()) {
                    return;
                  }
                  if (cargando) {
                    return;
                  }
                  Cliente cliente = new Cliente(_nombre.text, _telefono.text);

                  await agregarCliente(cliente);
                  Scaffold.of(context)
                      .showSnackBar(
                        SnackBar(
                          content: Text('Cliente guardado'),
                          duration: Duration(seconds: 1),
                        ),
                      )
                      .closed
                      .then((razon) {
                    Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

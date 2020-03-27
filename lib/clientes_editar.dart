import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'clase_cliente.dart';
import 'constantes.dart';

class EditarCliente extends StatefulWidget {
  final int idCliente;

  EditarCliente({Key key, @required this.idCliente}) : super(key: key);

  @override
  EditarClienteState createState() =>
      EditarClienteState(idCliente: this.idCliente);
}

class EditarClienteState extends State<EditarCliente> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final _claveFormulario = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    obtenerCliente(this.idCliente);
  }

  Future<bool> actualizarCliente(Cliente cliente) async {
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
    final http.Response response = await http.put(
      "$RUTA_API/cliente",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
      body: jsonEncode(<String, String>{
        "id": this.idCliente.toString(),
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

  Future<bool> obtenerCliente(int idCliente) async {
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
    final http.Response response = await http.get(
      "$RUTA_API/cliente/$idCliente",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    Map<String, dynamic> clienteRaw = json.decode(response.body);

    setState(() {
      cargando = false;
      _nombre.text = clienteRaw["nombre"];
      _telefono.text = clienteRaw["telefono"];
    });
    return response.statusCode == 200;
  }

  final int idCliente;
  bool cargando = false;

  EditarClienteState({Key key, @required this.idCliente}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar cliente #$idCliente"),
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
                  Cliente p = new Cliente(_nombre.text, _telefono.text);
                  await actualizarCliente(p);

                  Scaffold.of(context)
                      .showSnackBar(
                        SnackBar(
                          content: Text('Cliente actualizado'),
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

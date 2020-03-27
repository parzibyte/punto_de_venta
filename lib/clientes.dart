import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puntodeventa/clientes_agregar.dart';
import 'package:puntodeventa/clientes_editar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';
import 'dialogo.dart';
import 'navigator.dart';

class Clientes extends StatefulWidget {
  @override
  ClientesState createState() => ClientesState();
}

class ClientesState extends State<Clientes> {
  List clientes;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    this.obtenerClientes();
  }

  Future<bool> eliminarCliente(String id) async {
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String posibleToken = prefs.getString("token_api");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
      return false;
    }
    log("Haciendo petición...");
    final http.Response response = await http.delete(
      "$RUTA_API/cliente/$id",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    return response.statusCode == 200;
  }

  Future<String> obtenerClientes() async {
    setState(() {
      this.cargando = true;
    });
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String posibleToken = prefs.getString("token_api");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
      return "No hay token";
    }
    log("Haciendo petición...");
    var response = await http.get(
      "$RUTA_API/clientes",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    this.setState(() {
      cargando = false;
      clientes = json.decode(response.body);
    });

    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /*
          * Esperamos a que vuelva de la ruta y refrescamos
          * los clientes. No encontré otra manera de hacer que
          * se escuche cuando se regresa de la ruta
          * */
          await navigatorKey.currentState
              .push(MaterialPageRoute(builder: (context) => AgregarCliente()));
          this.obtenerClientes();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Clientes"),
      ),
      body: (cargando)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: clientes == null ? 0 : clientes.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(clientes[index]["nombre"]),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 0,
                                  top: 0,
                                  right: 5,
                                  bottom: 0,
                                ),
                                child: Text(
                                  "Teléfono",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(clientes[index]["telefono"]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Icon(
                            Icons.edit,
                            color: Colors.amber,
                          ),
                          onPressed: () async {
                            await navigatorKey.currentState.push(
                              MaterialPageRoute(
                                builder: (context) => EditarCliente(
                                  idCliente: this.clientes[index]["id"],
                                ),
                              ),
                            );
                            this.obtenerClientes();
                          },
                        ),
                        Builder(
                          builder: (context) => FlatButton(
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showAlertDialog(
                                  context,
                                  FlatButton(
                                    child: Text("Cancelar"),
                                    onPressed: () {
                                      navigatorKey.currentState.pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Sí, eliminar"),
                                    onPressed: () async {
                                      await eliminarCliente(this
                                          .clientes[index]["id"]
                                          .toString());
                                      navigatorKey.currentState.pop();
                                      this.obtenerClientes();
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cliente eliminado'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                  "Eliminar cliente",
                                  "¿Realmente deseas eliminar el cliente ${this.clientes[index]["nombre"]}? esto no se puede deshacer");
                            },
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
    );
  }
}

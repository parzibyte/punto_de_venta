import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';
import 'dialogo.dart';
import 'navigator.dart';
import 'ventas_detalle.dart';

class Ventas extends StatefulWidget {
  @override
  VentasState createState() => VentasState();
}

class VentasState extends State<Ventas> {
  List ventas;
  bool cargando = false;
  final formateador = new NumberFormat("#,###.00#");

  @override
  void initState() {
    super.initState();
    this.obtenerVentas();
  }

  Future<bool> eliminarVenta(String id) async {
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
      "$RUTA_API/venta/$id",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    return response.statusCode == 200;
  }

  Future<String> obtenerVentas() async {
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
      "$RUTA_API/ventas",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    this.setState(() {
      cargando = false;
      ventas = json.decode(response.body);
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
//          await navigatorKey.currentState
//              .push(MaterialPageRoute(builder: (context) => AgregarVenta()));
//          this.obtenerVentas();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Ventas"),
      ),
      body: (cargando)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: ventas == null ? 0 : ventas.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Builder(
                        builder: (context) {
                          double total = 0;
                          for (var i = 0;
                              i < ventas[index]["productos"].length;
                              i++) {
                            double cantidad = double.parse(
                                ventas[index]["productos"][i]["cantidad"]);
                            double precio = double.parse(
                                ventas[index]["productos"][i]["precio"]);
                            total += (cantidad * precio);
                          }
                          return Text("\$" + formateador.format(total));
                        },
                      ),
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
                                  "Fecha",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(ventas[index]["created_at"]
                                  .toString()
                                  .substring(
                                      0,
                                      ventas[index]["created_at"]
                                          .toString()
                                          .indexOf(".0000"))
                                  .replaceFirst("T", " ")),
                            ],
                          ),
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
                                  "Cliente",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(ventas[index]["cliente"]["nombre"]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            navigatorKey.currentState.push(
                              MaterialPageRoute(
                                builder: (context) => DetalleDeVenta(
                                  idVenta: this.ventas[index]["id"],
                                ),
                              ),
                            );
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
                                      await eliminarVenta(
                                          this.ventas[index]["id"].toString());
                                      navigatorKey.currentState.pop();
                                      this.obtenerVentas();
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Venta eliminada'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                  "Eliminar venta",
                                  "¿Realmente deseas eliminar la venta? esto no se puede deshacer");
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

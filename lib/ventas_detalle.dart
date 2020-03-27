import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';

class DetalleDeVenta extends StatefulWidget {
  final int idVenta;

  DetalleDeVenta({Key key, @required this.idVenta}) : super(key: key);

  @override
  DetalleDeVentaState createState() =>
      DetalleDeVentaState(idVenta: this.idVenta);
}

class DetalleDeVentaState extends State<DetalleDeVenta> {
  var detalle;
  double total = 0;
  final formateador = new NumberFormat("#,###.00#");

  @override
  void initState() {
    super.initState();
    obtenerVenta(this.idVenta);
  }

  Future<bool> obtenerVenta(int idVenta) async {
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
      "$RUTA_API/venta/$idVenta",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    detalle = json.decode(response.body);
    double t = 0;
    if (detalle != null) {
      for (var x = 0; x < detalle["productos"].length; x++) {
        t += (double.parse(detalle["productos"][x]["cantidad"]) *
            double.parse(detalle["productos"][x]["precio"]));
      }
    }

    setState(() {
      cargando = false;
      total = t;
    });
    return response.statusCode == 200;
  }

  final int idVenta;
  bool cargando = false;

  DetalleDeVentaState({Key key, @required this.idVenta}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de venta #$idVenta"),
      ),
      /*
      * es
      * detalle["productos"][index]["descripcion"]
      * */
      body: detalle == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    bottom: 5,
                  ),
                  child: Text(
                    "Venta #$idVenta",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.green,
                      ),
                      Text(
                        detalle["cliente"]["nombre"],
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    bottom: 5,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.format_list_bulleted,
                        color: Colors.amber,
                      ),
                      Text(
                        "Productos",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        detalle == null ? 0 : detalle["productos"].length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(detalle["productos"][index]["descripcion"]),
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
                                    "Código",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(detalle["productos"][index]
                                    ["codigo_barras"]),
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
                                  child: Text("Precio",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Text(
                                  "\$" +
                                      formateador.format(double.parse(
                                          detalle["productos"][index]
                                              ["precio"])),
                                ),
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
                                    "Cantidad",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  "\$" +
                                      formateador.format(double.parse(
                                          detalle["productos"][index]
                                              ["cantidad"])),
                                ),
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
                                  child: Text("Subtotal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Text(
                                  "\$" +
                                      formateador.format((double.parse(
                                              detalle["productos"][index]
                                                  ["precio"]) *
                                          double.parse(detalle["productos"]
                                              [index]["cantidad"]))),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                    bottom: 5,
                  ),
                  child: Text(
                    "Total: \$" + formateador.format(total),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
    );
  }
}

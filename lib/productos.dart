import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puntodeventa/productos_editar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes.dart';
import 'dialogo.dart';
import 'navigator.dart';
import 'productos_agregar.dart';

class Productos extends StatefulWidget {
  @override
  ProductosState createState() => ProductosState();
}

class ProductosState extends State<Productos> {
  List productos;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    this.obtenerProductos();
  }

  Future<bool> eliminarProducto(String id) async {
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
      "$RUTA_API/producto/$id",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    return response.statusCode == 200;
  }

  Future<String> obtenerProductos() async {
    setState(() {
      cargando = true;
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
      "$RUTA_API/productos",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    this.setState(() {
      productos = json.decode(response.body);
      this.cargando = false;
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
          * los productos. No encontré otra manera de hacer que
          * se escuche cuando se regresa de la ruta
          * */
          await navigatorKey.currentState
              .push(MaterialPageRoute(builder: (context) => AgregarProducto()));
          this.obtenerProductos();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Productos"),
      ),
      body: (cargando)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: productos == null ? 0 : productos.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(productos[index]["descripcion"]),
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(productos[index]["codigo_barras"]),
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
                                  "Compra",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text("\$" + productos[index]["precio_compra"]),
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
                                  "Venta",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text("\$" + productos[index]["precio_venta"]),
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
                                  "Existencia",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(productos[index]["existencia"]),
                            ],
                          ),
                        ],
                      ),
//              subtitle: Text(productos[index]["codigo_barras"] + "\nxd"),
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
                                builder: (context) => EditarProducto(
                                  idProducto: this.productos[index]["id"],
                                ),
                              ),
                            );
                            this.obtenerProductos();
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
                                      await eliminarProducto(this
                                          .productos[index]["id"]
                                          .toString());
                                      navigatorKey.currentState.pop();
                                      this.obtenerProductos();
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Producto eliminado'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                  "Eliminar producto",
                                  "¿Realmente deseas eliminar el producto ${this.productos[index]["descripcion"]}? esto no se puede deshacer");
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

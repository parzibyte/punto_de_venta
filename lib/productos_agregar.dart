import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'clase_producto.dart';
import 'constantes.dart';

class AgregarProducto extends StatefulWidget {
  final int idProducto;

  AgregarProducto({Key key, @required this.idProducto}) : super(key: key);

  @override
  AgregarProductoState createState() =>
      AgregarProductoState(idProducto: this.idProducto);
}

class AgregarProductoState extends State<AgregarProducto> {
  final TextEditingController _codigoBarras = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _precioCompra = TextEditingController();
  final TextEditingController _precioVenta = TextEditingController();
  final TextEditingController _existencia = TextEditingController();

  Future<bool> agregarProducto(Producto producto) async {
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
      "$RUTA_API/producto",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
      body: jsonEncode(<String, String>{
        'codigo_barras': producto.codigoBarras,
        'descripcion': producto.descripcion,
        'precio_compra': producto.precioCompra,
        'precio_venta': producto.precioVenta,
        'existencia': producto.existencia,
      }),
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    setState(() {
      cargando = false;
    });
    return response.statusCode == 200;
  }

  final int idProducto;
  bool cargando = false;

  AgregarProductoState({Key key, @required this.idProducto}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar producto"),
      ),
      body: Center(
        child: ListView(
//          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _codigoBarras,
                decoration: InputDecoration(
                  hintText: 'Escribe el código',
                  labelText: "Código de barras",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _descripcion,
                decoration: InputDecoration(
                  hintText: 'Escribe la descripción',
                  labelText: "Descripción",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _precioCompra,
                decoration: InputDecoration(
                  hintText: 'Escribe el precio de compra',
                  labelText: "Precio de compra",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _precioVenta,
                decoration: InputDecoration(
                  hintText: 'Escribe el precio de venta',
                  labelText: "Precio de venta",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _existencia,
                decoration: InputDecoration(
                  hintText: 'Escribe la existencia',
                  labelText: "Existencia",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: cargando
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text("Guardar"),
                onPressed: () {
                  if (cargando) {
                    return;
                  }
                  Producto p = new Producto(
                      _codigoBarras.text,
                      _descripcion.text,
                      _precioCompra.text,
                      _precioVenta.text,
                      _existencia.text);
                  agregarProducto(p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
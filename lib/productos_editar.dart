import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'clase_producto.dart';
import 'constantes.dart';

class EditarProducto extends StatefulWidget {
  final int idProducto;

  EditarProducto({Key key, @required this.idProducto}) : super(key: key);

  @override
  EditarProductoState createState() =>
      EditarProductoState(idProducto: this.idProducto);
}

class EditarProductoState extends State<EditarProducto> {
  final TextEditingController _codigoBarras = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _precioCompra = TextEditingController();
  final TextEditingController _precioVenta = TextEditingController();
  final TextEditingController _existencia = TextEditingController();
  final _claveFormulario = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    obtenerProducto(this.idProducto);
  }

  Future<bool> actualizarProducto(Producto producto) async {
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
      "$RUTA_API/producto",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
      body: jsonEncode(<String, String>{
        "id": this.idProducto.toString(),
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

  Future<bool> obtenerProducto(int idProducto) async {
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
      "$RUTA_API/producto/$idProducto",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );
    log("Response es 200?");
    log((response.statusCode == 200).toString());
    Map<String, dynamic> productoRaw = json.decode(response.body);

    setState(() {
      cargando = false;
      _codigoBarras.text = productoRaw["codigo_barras"];
      _descripcion.text = productoRaw["descripcion"];
      _precioCompra.text = productoRaw["precio_compra"];
      _precioVenta.text = productoRaw["precio_venta"];
      _existencia.text = productoRaw["existencia"];
    });
    return response.statusCode == 200;
  }

  final int idProducto;
  bool cargando = false;

  EditarProductoState({Key key, @required this.idProducto}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar producto #$idProducto"),
      ),
      body: Form(
        key: _claveFormulario,
        child: ListView(shrinkWrap: true, children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe el código de barras';
                }
                return null;
              },
              controller: _codigoBarras,
              decoration: InputDecoration(
                hintText: 'Escribe el código',
                labelText: "Código de barras",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe la descripción';
                }
                return null;
              },
              controller: _descripcion,
              decoration: InputDecoration(
                hintText: 'Escribe la descripción',
                labelText: "Descripción",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe el precio de compra';
                }
                return null;
              },
              controller: _precioCompra,
              decoration: InputDecoration(
                hintText: 'Escribe el precio de compra',
                labelText: "Precio de compra",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe el precio de venta';
                }
                return null;
              },
              controller: _precioVenta,
              decoration: InputDecoration(
                hintText: 'Escribe el precio de venta',
                labelText: "Precio de venta",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Escribe la existencia';
                }
                return null;
              },
              controller: _existencia,
              decoration: InputDecoration(
                hintText: 'Escribe la existencia',
                labelText: "Existencia",
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
                  Producto p = new Producto(
                      _codigoBarras.text,
                      _descripcion.text,
                      _precioCompra.text,
                      _precioVenta.text,
                      _existencia.text);
                  await actualizarProducto(p);

                  Scaffold.of(context)
                      .showSnackBar(
                        SnackBar(
                          content: Text('Producto actualizado'),
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

import 'package:flutter/material.dart';

import 'acerca_de.dart';
import 'clientes.dart';
import 'escritorio.dart';
import 'productos.dart';
import 'ventas.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void navegarAEscritorio() {
  navigatorKey.currentState
      .push(MaterialPageRoute(builder: (context) => Escritorio()));
}

void navegarAProductos() {
  navigatorKey.currentState
      .push(MaterialPageRoute(builder: (context) => Productos()));
}

void navegarAVentas() {
  navigatorKey.currentState
      .push(MaterialPageRoute(builder: (context) => Ventas()));
}

void navegarAAcercaDe() {
  navigatorKey.currentState
      .push(MaterialPageRoute(builder: (context) => AcercaDe()));
}

void navegarAClientes() {
  navigatorKey.currentState
      .push(MaterialPageRoute(builder: (context) => Clientes()));
}

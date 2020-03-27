import 'package:flutter/material.dart';

import 'navigator.dart';

class Escritorio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escritorio"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          Card(
            elevation: 10,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                navegarAProductos();
              },
              child: ListTile(
                title: Text(
                  'Productos',
                  textAlign: TextAlign.center,
                ),
                subtitle: Image(
                  image: AssetImage("assets/order.png"),
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                navegarAVentas();
              },
              child: ListTile(
                title: Text(
                  'Ventas',
                  textAlign: TextAlign.center,
                ),
                subtitle: Image(
                  image: AssetImage("assets/coupon.png"),
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                navegarAClientes();
              },
              child: ListTile(
                title: Text(
                  'Clientes',
                  textAlign: TextAlign.center,
                ),
                subtitle: Image(
                  image: AssetImage("assets/clientes.png"),
                ),
              ),
            ),
          ),
          Card(
            elevation: 10,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                navegarAAcercaDe();
              },
              child: ListTile(
                title: Text(
                  'Acerca de',
                  textAlign: TextAlign.center,
                ),
                subtitle: Image(
                  image: AssetImage("assets/about.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

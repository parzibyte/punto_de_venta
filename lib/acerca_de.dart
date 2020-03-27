import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acerca de"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 5,
          ),
          child: Column(
            children: <Widget>[
              Text(
                "Punto de venta móvil. Escrito en Flutter y basado en la web; consumiendo API de Laravel\n"
                "\nCreado y mantenido por:",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Luis Cabrera Benito",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.green,
                    onPressed: () async {
                      const url =
                          'https://github.com/parzibyte/sistema_ventas_laravel/';
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                    child: Text("Código fuente de app web"),
                  ),
                  RaisedButton(
                    color: Colors.amber,
                    onPressed: () async {
                      const url =
                          'https://parzibyte.me/blog';
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                    child: Text("Blog"),
                  ),
                ],
              ),
              Text("Créditos",style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  "Productos: Icons made by Icongeek26 (https://www.flaticon.com/authors/icongeek26) from www.flaticon.com"),
              Text(
                  "Ventas: Icons made by Eucalyp (https://www.flaticon.com/authors/eucalyp) from www.flaticon.com"),
              Text(
                  "Acerca de: Icons made by inipagistudio (https://www.flaticon.com/authors/inipagistudio) from www.flaticon.com"),
              Text(
                  "Clientes: Icons made by Freepik (https://www.flaticon.com/authors/freepik) from www.flaticon.com"),
              Text("Icono de la app: Icons made by Freepik (https://www.flaticon.com/authors/freepik) from www.flaticon.com"),
            ],
          ),
        ),
      ),
    );
  }
}

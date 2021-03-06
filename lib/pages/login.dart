import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:whatscookin/pages/olvidopass.dart';
import 'package:whatscookin/pages/registro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:whatscookin/api/services/usuario.dart' as apiUsuario;

import 'home.dart';

class Login extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

final usuarioController = TextEditingController();
final passController = TextEditingController();

class LoginPageState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    startTime() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool firstTime = prefs.getBool('first_time');
      int idUsuario = prefs.getInt('idUsuario');

      // Si ya está logeado, pasa a /home
      if (idUsuario != null && idUsuario > 0) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      }

      void navigationPageWel() {
        Navigator.of(context).pushReplacementNamed('/intro');
      }

      var _duration = new Duration(milliseconds: 1);

      // No la primera vez que se abre la app
      if (firstTime == null || firstTime) {
        prefs.setBool('first_time', false);
        return new Timer(_duration, navigationPageWel);
      }
    }

    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    return FutureBuilder(
        future: startTime(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipPath(
                      clipper: WaveClipper2(),
                      child: Container(
                        child: Column(),
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Color(0x22873600),
                          Color(0x226E2C00)
                        ])),
                      ),
                    ),
                    ClipPath(
                      clipper: WaveClipper3(),
                      child: Container(
                        child: Column(),
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Color(0x44BA4A00),
                          Color(0x44CA6F1E)
                        ])),
                      ),
                    ),
                    ClipPath(
                      clipper: WaveClipper1(),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 70,
                            ),
                            Text(
                              "Whatscookin",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 70,
                                  fontFamily: 'Alegra'),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Colors.orange[600],
                          Colors.orange[900]
                        ])),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: TextField(
                      controller: usuarioController,
                      onChanged: (String value) {},
                      cursorColor: Colors.deepOrange,
                      decoration: InputDecoration(
                          hintText: "Usuario/Email",
                          prefixIcon: Material(
                            elevation: 0,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: Icon(
                              Icons.person,
                              color: Colors.deepOrange,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 13)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Material(
                    elevation: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: TextField(
                      controller: passController,
                      obscureText: true,
                      onChanged: (String value) {},
                      cursorColor: Colors.deepOrange,
                      decoration: InputDecoration(
                          hintText: "Contraseña",
                          prefixIcon: Material(
                            elevation: 0,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: Icon(
                              Icons.lock,
                              color: Colors.deepOrange,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 13)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          color: Colors.orange[800]),
                      child: FlatButton(
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
                        onPressed: () async {
                          // Obtiene el ID de usuario en caso de ser correcto el login, y lleva a /home
                          int value = await apiUsuario.login(
                              usuarioController.text, passController.text);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setInt('idUsuario', value);
                          if (value != -1) {
                            usuarioController.clear();
                            passController.clear();
                            Fluttertoast.showToast(
                                msg: "¡Login correcto!",
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Colors.deepOrangeAccent,
                                textColor: Colors.white);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          } else {
                            Fluttertoast.showToast(
                                msg: "Login incorrecto",
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Colors.deepOrangeAccent,
                                textColor: Colors.white);
                          }
                        },
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OlvidoPass()),
                      );
                    },
                    child: Text(
                      "¿OLVIDASTE LA CONTRASEÑA?",
                      style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "¿No tienes cuenta? ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Registro()),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text("Regístrate ",
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

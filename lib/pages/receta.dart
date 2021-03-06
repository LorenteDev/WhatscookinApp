import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:whatscookin/api/api.dart' as api;
import 'package:whatscookin/api/classes/Comentario.dart';
import 'package:whatscookin/api/services/usuario.dart' as apiUsuario;
import 'package:whatscookin/api/services/receta.dart' as apiReceta;
import 'package:whatscookin/api/services/favorito.dart' as apiFavorito;
import 'package:whatscookin/api/services/ingrediente.dart' as apiIngrediente;
import 'package:whatscookin/api/widgets/StarRating.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

int idUsuarioLogin;

int idReceta = 1;
int idUsuario; // Id del usuario autor de la receta
int idDificultad; // Id de la dificultad de la receta
int idTipoReceta; // Id del tipo de receta

String titulo = ""; // Titulo de la receta
String nombreUsuario = ""; // Nombre del autor de la receta
String dificultad = ""; // Dificultad de la receta
String tipoReceta = ""; // Tipo de receta
int duracion = 0; // Duracion de la receta
var puntuacion = 0.0; // Puntuacion media de la receta
String instrucciones = ""; // Instrucciones de la receta
bool esFavorita = false; // Favorita o no por el usuario visitando

int counter = idReceta * 0;

// Iconos de los estados para favoritos
var favIcon = Icons.favorite_border;
var favColor = Colors.white;

// Mapa de los ingredientes
List<Map> ingredientes = [];

// Puntuacion media
double puntuacionDialog = 0.0;

class Receta extends StatefulWidget {
  @override
  _RecetaState createState() => _RecetaState();
}

class _RecetaState extends State<Receta> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  var usuario;
  var receta;
  var favoritos;

  List<dynamic> listIngredientes = [];
  List<dynamic> listComentarios = [];
  List<Map> ingredientes = [];
  List<Map> comentarios = [];

  String image = "https://images2.imgbox.com/f6/7e/pXXtJViL_o.jpg";
  String avatar =
      "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png";

  @override
  void initState() {
    super.initState();
    getData();
    getData();
    getData();
  }

  getData() async {
    infoVisitante();
    infoReceta();
    infoUsuario();
    infoIngredientes();
    infoFavorito();
    infoComentarios();
  }

  infoVisitante() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idUsuarioLogin = await prefs.getInt('idUsuario');

    if (idUsuarioLogin == null && idUsuarioLogin < 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  infoReceta() async {
    idReceta = ModalRoute.of(context).settings.arguments;
    receta = await Future.value(apiReceta.getReceta(idReceta));
    idUsuario = receta.idUsuario;
    idDificultad = receta.idDificultad;
    idTipoReceta = receta.idTipoReceta;
    puntuacion = receta.puntuacion;

    titulo = receta.titulo;
    instrucciones = receta.instrucciones;
    duracion = receta.duracion;

    var tempImage =
        api.baseUrl + "/imagen/get?id=" + idReceta.toString() + "&tipo=receta";
    if (tempImage != null) {
      image = tempImage;
    }

    var itemDificultad =
        await Future.value(apiReceta.getDificultad(idDificultad));
    dificultad = itemDificultad.dificultad;

    var itemTipoReceta =
        await Future.value(apiReceta.getTipoReceta(idTipoReceta));
    tipoReceta = itemTipoReceta.nombre;
  }

  infoUsuario() async {
    usuario = await Future.value(apiUsuario.getUsuario(idUsuario));

    var tempAvatar = api.baseUrl +
        "/imagen/get?id=" +
        idUsuario.toString() +
        "&tipo=usuario";
    if (tempAvatar != null) {
      avatar = tempAvatar;
    }
    nombreUsuario = usuario.nombre;
  }

  infoFavorito() async {
    favoritos = await Future.value(
        apiFavorito.getRecetasFavoritasDeUsuario(idUsuarioLogin));
    List<dynamic> lista = favoritos;
    for (int i = 0; i < lista.length; i++) {
      if (lista[i].idReceta == idReceta) {
        esFavorita = true;
        favIcon = Icons.favorite;
        favColor = Colors.deepOrangeAccent;
        break;
      } else {
        esFavorita = false;
        favIcon = Icons.favorite_border;
        favColor = Colors.white;
      }
    }
  }

  infoIngredientes() async {
    listIngredientes =
        await Future.value(apiIngrediente.getIngredientesReceta(idReceta));

    if (listIngredientes.length > 0) {
      ingredientes.clear();

      for (int i = 0; i < listIngredientes.length; i++) {
        var map = {};
        map['ingrediente'] = listIngredientes[i].ingrediente;

        ingredientes.add(map);
      }
    }
  }

  infoComentarios() async {
    listComentarios =
        await Future.value(apiReceta.getComentariosDeReceta(idReceta));

    if (listComentarios.length > 0) {
      comentarios.clear();

      for (int i = 0; i < listComentarios.length; i++) {
        var map = {};
        map['comentario'] = listComentarios[i].comentario;

        var usuario = await apiUsuario.getUsuario(listComentarios[i].idUsuario);

        map['usuario'] = usuario.nombre;

        comentarios.add(map);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    Future.delayed(const Duration(milliseconds: 900), () => setState(() {}));

    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image(
                        image: NetworkImage(image),
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                        height: 300.0,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProcess) {
                          if (loadingProcess == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.deepOrange),
                                value: loadingProcess.expectedTotalBytes != null
                                    ? loadingProcess.cumulativeBytesLoaded /
                                        loadingProcess.expectedTotalBytes
                                    : null),
                          );
                        },
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.width * 0.05,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              size: 40, color: Colors.white),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.width * 0.10,
                        child: IconButton(
                          icon: Icon(favIcon, size: 40, color: favColor),
                          onPressed: () {
                            if (favIcon == Icons.favorite_border) {
                              favIcon = Icons.favorite;
                              favColor = Colors.deepOrangeAccent;
                              apiFavorito.setFavorito(idUsuarioLogin, idReceta);
                            } else {
                              favIcon = Icons.favorite_border;
                              favColor = Colors.white;
                              apiFavorito.deleteFavorito(
                                  idUsuarioLogin, idReceta);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.30,
                        left: MediaQuery.of(context).size.width * 0.03,
                        child: FlatButton(
                          child: StarRating(
                            rating: puntuacion,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return MyDialog();
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20.0),
                      children: <Widget>[
                        Text(
                          titulo.toUpperCase(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.deepOrange)),
                              child: CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(avatar),
                              ),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: BorderSide(color: Colors.deepOrange)),
                              child: Text(
                                nombreUsuario,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          color: Colors.white,
                          height: 40.0,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: ingredientes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10.0),
                                  height: 20.0,
                                  padding: EdgeInsets.all(2.0),
                                  child: Container(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor)),
                                      ),
                                      child: Text(
                                        ingredientes[index]['ingrediente'],
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          height: 30,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.memory),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(dificultad)
                                  ],
                                ),
                              ),
                              VerticalDivider(),
                              Expanded(
                                child: Text(
                                  tipoReceta,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              VerticalDivider(),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.timer),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text("$duracion min")
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        _buildStep(
                            buildImage: // placeholder
                                "https://images2.imgbox.com/a6/75/zkZ5dCsY_o.png",
                            title: "CÓMO PREPARAR",
                            content: instrucciones),
                        SizedBox(
                          height: 15.0,
                        ),

                        // TODO: Falla la implementación visual. Recoge perfectamente los comentarios del servidor
                        /*
                        Container(
                            child: ListView.builder(
                              itemCount: comentarios.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: new Text(comentarios[index]['usuario']),
                                      subtitle: new Text(comentarios[index]['comentario']),
                                    ),
                                    Divider(
                                      height: 2.0,
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                         */
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildStep({String buildImage, String title, String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: Colors.deepOrange,
          child: Container(
            padding: EdgeInsets.all(5.0),
            child: Image.network(
              buildImage,
              height: 20,
            ),
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              SizedBox(
                height: 15.0,
              ),
              Text(content),
            ],
          ),
        )
      ],
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
              height: 100.0,
              width: 250,
              child: Slider(
                  value: puntuacionDialog,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  activeColor: Colors.deepOrange,
                  label: "$puntuacionDialog",
                  onChanged: (double newValue) {
                    setState(() => puntuacionDialog = newValue);
                  })),
          FlatButton(
            child: Text(
              "Votar",
              style: TextStyle(fontSize: 20.0, color: Colors.deepOrange),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            onPressed: () async {
              apiReceta.puntuar(idReceta, idUsuarioLogin, puntuacionDialog);
              Navigator.pop(context);
            },
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

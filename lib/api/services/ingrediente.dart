import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:whatscookin/api/api.dart' as api;
import 'package:whatscookin/api/classes/Ingrediente.dart';

String path = api.baseUrl + "/ingrediente";

Future<List> getAllIngredientes() async {
  var response = await http.get(path + "/getAll");
  List data = await json.decode(response.body);

  List<Ingrediente> lista = [];
  for(int i = 0; i < data.length; i++) {
    lista.add(Ingrediente.fromJson(data[i]));
  }

  return lista;
}

Future<List> getIngredientesReceta(int idReceta) async {
  final response =
      await http.get(path + "/getIngredientesReceta?id=" + idReceta.toString());
  if (response.statusCode == 200) {
    List ingredientesBruto = json.decode(response.body);

    List ingredientes = [];
    for (int i = 0; i < ingredientesBruto.length; i++) {
      final ingrediente = Ingrediente.fromJson(ingredientesBruto[i]);
      ingredientes.add(ingrediente);
    }
    return ingredientes;
  }
}

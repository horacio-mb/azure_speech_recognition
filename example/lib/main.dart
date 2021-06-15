import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:azure_speech_recognition/azure_speech_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
//Importamo librerías necesarias
 
void main() => runApp(MyApp());
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
// Añadimos Clave, region y lenguaje
class _MyAppState extends State<MyApp> {
  String _centerText = 'Unknown';
  AzureSpeechRecognition _speechAzure;
  String subKey = "e71a4859c86544dc97b32f3c7bb93339";
  String region = "westus";
  String lang = "es-BO";
  bool isRecording = false;
 
void activateSpeechRecognizer(){
    // Se inicializa el reconocedor
  AzureSpeechRecognition.initialize(subKey, region,lang: lang);
  
  _speechAzure.setFinalTranscription((text) {
    setState(() {
      _centerText = text;
      isRecording = false;
    });
 
  });
 
  _speechAzure.setRecognitionStartedHandler(() {
    isRecording = true;
  });
 
}
  @override
  void initState() {
    
    _speechAzure = new AzureSpeechRecognition();
 
    activateSpeechRecognizer();
 
    super.initState();
  }
// Esta funccion es la que inicia el reconocimiento simple de voz
Future _recognizeVoice() async {
    try {
      AzureSpeechRecognition.simpleVoiceRecognition();
     
    } on PlatformException catch (e) {
      print("Failed to get text '${e.message}'.");
    }
  }
// esta funcion envia el texto en un json a la api
Future<String> sendData()async{
    var response= await http.post(
      Uri.https('apiproductoflutter.azurewebsites.net', '/api/data'),
      headers: <String, String>{
        'Content-Type':'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "nameDevice": "Samsung A30",
        "eventDate": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()).toString(),
        "text" : '$_centerText'
      })
    );
    return response.body;
  }
//Vista de la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Enviar voz to texto'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Texto reconocido : $_centerText\n'),
              FloatingActionButton(
                onPressed: (){
                  if(!isRecording)_recognizeVoice();
                },
                child: Icon(Icons.mic),),
                Container(
                  child:  new ElevatedButton(
                    onPressed: sendData,
                    child: new Text("Enviar datos")
                    ),
                ),
            ],
          ),
          
        ),
      ),
    );
  }
}

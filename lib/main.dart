import 'dart:async';

import 'package:flutter/material.dart';
import './musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.black,
        backgroundColor: Colors.grey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

enum ActionMusique{
  play,
  pause,
  rewind,
  forword
}

enum PlayerState{
  plaing,
  stoped,
  posed
}

class _HomeState extends State<Home> {
  // les variables

  // pour le titre
  String title = "Ma Musique ";

  // Création de la liste des musiques
  List<Musique> maListe = [
    Musique("Theme Swift", "AppRoom", "assets/images/un.jpg", "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3"),
    Musique("Theme Flutter", "AppRoom", "assets/images/deux.jpg", "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3"),
  ];

  // autres variables
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Musique maMusiqueActuelle;
  Duration position = Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState status = PlayerState.stoped;
  int index = 0;


  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListe[index];
    configurationAudioPlayer();
  }

  // function qui permet de mettre en style les buttons : lecture, pause etc...
  Text textAvecStyle(String data, double scale){
    return Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // Création de la configuration du player
  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(()=> position = pos));

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING){
        setState(() {
          duree = audioPlayer.duration;
        });
      }else if(state == AudioPlayerState.STOPPED){
        setState(() {
          status = PlayerState.stoped;
        });
      }
    },
        onError: (message){
          print("error : $message");
          setState(() {
            status = PlayerState.stoped;
            duree = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        }
    );
  }

  // function qui permet de lancer la lecture du song
  Future play() async{
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      status = PlayerState.plaing;
    });
  }

  // function permettant de mettre en pause la lecture
  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.posed;
    });
  }

  // function qui permet passer à la musique suivante
  void forword(){
    if(index == maListe.length-1){  // vérifier s'il s'agit du dérnier élément
      index = 0;
    }else{
      index++;
    }

    maMusiqueActuelle = maListe[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  // function permettant de passer à la musique précédente

  void rewind(){
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }else{
      if(index == 0){
        index = maListe.length -1;
      }else{
        index--;
      }
    }
    maMusiqueActuelle = maListe[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  // function pour afficher les valeurs du début et fin de temps de la musique
  String fromDuration(Duration duree){
    return duree.toString().split('.').first;
  }

  // function qui permet de calculer le temps max de la musique
  double dureeMusique(Duration duree){
    int dureeInSecend = duree.inSeconds;
    return dureeInSecend.toDouble();
  }

  IconButton button(IconData icon, double taille, ActionMusique action){
    return IconButton(
        iconSize: taille,
        color: Colors.white,
        icon: Icon(icon),
        onPressed: (){
          switch(action){
            case ActionMusique.play:
              play();
              break;
            case ActionMusique.pause:
              pause();
              break;
            case ActionMusique.rewind:
              rewind();
              break;
            case ActionMusique.forword:
              forword();
              break;
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(title,
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 10,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      elevation: 10.0,
                      child: Container(
                        width: MediaQuery.of(context).size.height /2.5,
                        child: Image.asset(maMusiqueActuelle.imagePath),
                      ),
                    ),
                    textAvecStyle(maMusiqueActuelle.title, 1.5),
                    textAvecStyle(maMusiqueActuelle.artiste, 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        button(Icons.fast_rewind, 30.0, ActionMusique.rewind),
                        button((status == PlayerState.plaing) ? Icons.pause :  Icons.play_arrow, 45, (status == PlayerState.plaing) ? ActionMusique.pause : ActionMusique.play),
                        button(Icons.fast_forward, 30, ActionMusique.forword),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        textAvecStyle(fromDuration(position), 0.8),
                        textAvecStyle(fromDuration(duree), 0.8),
                      ],
                    ),
                    Slider(
                      onChanged: (double value) {
                        setState(() {
                          audioPlayer.seek(value);
                        });
                      },
                      value: position.inSeconds.toDouble(),
                      min: 0.0,
                      max: dureeMusique(duree),
                      inactiveColor: Colors.white,
                      activeColor: Colors.red,
                    ),
                  ],
                ),
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),backgroundColor: Colors.grey[800],
    );
  }


}



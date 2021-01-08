import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading =true;
  File _image;
  List _output;
  final picker = ImagePicker();
 void initState(){
    super.initState();
    loadModel().then((value){
      setState(() {
      });
    });
  }
  classifyImage(File image) async{
    var output = await Tflite.runModelOnImage(path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output;
      _loading = false;
    });

  }
  loadModel()async{
    await Tflite.loadModel(model: 'assets/model_unquant.tflite',labels: 'assets/labels.txt');
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }
  pickerCameraImage()async{
   var image = await picker.getImage(source: ImageSource.camera);
   if(image == null) return null;
   setState(() {
     _image = File(image.path);
   });
   classifyImage(_image);
  }
  pickerGalleryImage()async{
    var image = await picker.getImage(source: ImageSource.gallery);
    if(image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70.0,),
            Text("Tensorflow ",style: TextStyle(color: Color(0xFFEEDA28),fontSize: 35),),
            SizedBox(height: 6.0,),
            Text('Detect Animals',style: TextStyle(color: Color(0xFFE99600),fontWeight: FontWeight.w500,fontSize:30),),
            SizedBox(height: 30,),
            Center(child:_loading ? Container(
              width: 280,
              child: Column(
                children: [
                  Image.asset("assets/animals_p.png"),
                  SizedBox(height: 50,)
                ],
              ),
            ):Container(
              child: Column(
                children: [
                  Container(
                    height: 250,
                    child: Image.file(_image),
                  ),
                  SizedBox(height: 50,),
                  _output != null ? Text('${_output[0]['label']}',
                    style:TextStyle(
                        color: Colors.white,
                        fontSize: 20) ,)
                      : Container(),
                  SizedBox(height: 10,)
                ],
              ),
            ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child:Column(
                  children: [
                    GestureDetector(
                      onTap: pickerGalleryImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 150,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                            // Color(0xFFE99600)
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text("Take a Photo",style: TextStyle(color: Color(0xFFE99600)),),
                      ),
                    ),
                    SizedBox(height: 10,),
                    GestureDetector(
                      onTap:pickerCameraImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 150,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 17),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text("Camera Roll",style: TextStyle(color: Color(0xFFE99600)),),
                      ),
                    )
                  ],
                ) ,
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home : VoteChecker(),
      debugShowCheckedModeBanner : false,
    );
  }
}

class VoteChecker extends StatefulWidget{
  @override
  _VoteCheckerState createState() => _VoteCheckerState();
}

class _VoteCheckerState extends State<VoteChecker> {
  TextEditingController ageController = TextEditingController();
  String result = "";

  void checkEligibility(){
    int? age = int.tryParse(ageController.text);

    setState(() {
      if(age == null){
        result = "Please enter valid number";
      }else if(age >= 18){
        result = "Eligibile to Vote";
      }else{
        result = "Not Eligible to Vote";
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar : AppBar(title : Text("Vote Eligibility Checker")),
      body : Center(
        child : Padding(
          padding : const EdgeInsets.all(20.0),
          child : Column(
              mainAxisAlignment : MainAxisAlignment.center,
              crossAxisAlignment : CrossAxisAlignment.center,
              children : [
                  TextField(
                    controller : ageController,
                    keyboardType : TextInputType.number,
                    decoration : InputDecoration(
                      labelText : "Enter your age",
                      border : OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height : 15),
                  ElevatedButton(
                    onPressed : checkEligibility,
                    child : Text("Check"),
                  ),
                  SizedBox(height : 70),
                  Text(
                    result,
                    style : TextStyle(fontSize : 18, fontWeight : FontWeight.bold)
                  ),
              ],
          ),
        ),
      ),
    );
  }
}
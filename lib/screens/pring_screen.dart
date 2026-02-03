import 'package:flutter/material.dart';
import 'package:project/services/api_service.dart';

class Pingscreen extends StatefulWidget {
  const Pingscreen({super.key});

  @override
  State<Pingscreen> createState() => _PingscreenState();

}



class _PingscreenState extends State<Pingscreen> {
    String statusText = "Connecting ...";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _autoConnect();
  }

  Future<void> _autoConnect() async{
    try {
      final data = await ApiService.ping();
      setState(() {
        statusText = "Connected Successfully  Response: $data";
        loading = false;
      });
      return;
    }catch (e) {
      setState(() {
        statusText = "Connection Failed \n Please try again later";
        loading = false;
      });
      return;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: loading ? 
        CircularProgressIndicator():
        Text(
          statusText, 
          textAlign: TextAlign.center ,
        style: TextStyle(fontSize: 22 , color: Colors.black54),
        ),
      ),
    );
  }
}
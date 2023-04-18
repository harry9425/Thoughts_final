import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterDetails extends StatefulWidget {
  const RegisterDetails({Key? key}) : super(key: key);

  @override
  State<RegisterDetails> createState() => _RegisterDetailsState();
}

class _RegisterDetailsState extends State<RegisterDetails> {
  var _value=0.0;
  var _isPressed=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            // controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              prefixIcon: Icon(Icons.account_circle,color: Colors.black54,),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(100, 88, 88, 88)),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orangeAccent,width: 4),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            // controller: _phoneController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.alternate_email_outlined,color: Colors.black54,),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(100, 88, 88, 88)),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orangeAccent,width: 4),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            // controller: _phoneController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Enter your College Name',
                              prefixIcon: Icon(Icons.account_balance,color: Colors.black54,),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(100, 88, 88, 88)),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orangeAccent,width: 4),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Year of Study", style: TextStyle(fontSize: 12.0,color: Colors.white,fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Slider(
                            inactiveColor: Colors.grey,
                            activeColor: Colors.white,
                            value: _value,
                            min: 0.0,
                            max: 4.0,
                            divisions: 4,
                            onChanged: (double value) {
                              setState(() {
                                _value = value;
                              });
                            },
                          ),
                        ),
                        Text('${_value.round()} years', style: TextStyle(fontSize: 12.0,color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            // controller: _phoneController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon:Icon(Icons.school),
                              hintText: 'Enter your Branch name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(100, 88, 88, 88)),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orangeAccent,width: 4),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            // controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon:Icon(Icons.reduce_capacity_outlined),
                              hintText: 'Enter your PRN',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(100, 88, 88, 88)),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.orangeAccent,width: 4),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPressed = true;
                    });
                     // _onNextPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    primary: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isPressed ? 'SAVING...' : 'SAVE DETAILS',
                    style: TextStyle(
                      color: _isPressed ? Colors.white54 : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),)
              ],
            )
          ],
        ),
      )
    );
  }
}
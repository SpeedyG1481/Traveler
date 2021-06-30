import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:traveler/data/images.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Images.marketBackground,
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      width: width / 1.5,
                      height: height / 4,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: Images.marketVIP1),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 25,
                        left: 25,
                        right: 10,
                        bottom: 0,
                      ),
                      width: width / 1.5,
                      height: height / 4,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: Images.marketVIP2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "RELOAD",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: <Color>[
                                    Color(0xffE26600),
                                    Color(0xffFFE91C),
                                    Color(0xffFFE91C),
                                    Color(0xffFFE91C),
                                    Color(0xffFF9700),
                                    Color(0xffFF9700),
                                    Color(0xffE26600),
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                    0.0,
                                    0.0,
                                    200.0,
                                    70.0,
                                  ),
                                ),
                            ),
                          ),
                          Text(
                            "QUICKNESS",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: <Color>[
                                    Color(0xffE26600),
                                    Color(0xffFFE91C),
                                    Color(0xffFFE91C),
                                    Color(0xffFFE91C),
                                    Color(0xffFF9700),
                                    Color(0xffFF9700),
                                    Color(0xffE26600),
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                    0.0,
                                    0.0,
                                    200.0,
                                    70.0,
                                  ),
                                ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "2.99\$",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

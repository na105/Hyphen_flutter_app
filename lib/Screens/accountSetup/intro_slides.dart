import 'package:flutter/material.dart';
import 'package:hyphen/constants.dart';
import 'package:nice_intro/intro_screen.dart';
import 'package:nice_intro/intro_screens.dart';

import '../../responsive/mobile_screen_layou.dart';
import '../../responsive/responsive_layout_screen.dart';
import '../../responsive/web_screen_layout.dart';

class IntroSlides extends StatefulWidget {
  const IntroSlides({Key? key}) : super(key: key);

  @override
  State<IntroSlides> createState() => _IntroSlidesState();
}

class _IntroSlidesState extends State<IntroSlides>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var screens = IntroScreens(
      onDone: () {
        setState(() {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout())));
        });
      },
      onSkip: () => print('Skipping the intro slides'),
      footerBgColor: kPrimaryColor.withOpacity(.9),
      activeDotColor: Colors.white,
      indicatorType: IndicatorType.LINE,
      footerRadius: 18,
      slides: [
        IntroScreen(
          title: 'Create',
          imageAsset: 'assets/images/intro2.png',
          description: 'Create your own art or with others.',
          headerBgColor: Colors.white,
        ),
        IntroScreen(
          title: 'Post',
          headerBgColor: Colors.white,
          imageAsset: 'assets/images/intro3.png',
          description: "Post your art for others to see.",
        ),
        IntroScreen(
          title: 'Social',
          headerBgColor: Colors.white,
          imageAsset: 'assets/images/intro1.png',
          description: "Keep talking with your mates",
        ),
      ],
    );
    return Scaffold(
      body: screens,
    );
  }
}

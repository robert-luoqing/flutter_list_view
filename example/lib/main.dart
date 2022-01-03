import 'package:flutter/material.dart';
import 'package:marquee_vertical/marquee_vertical.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Vertical Marquee Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final texts = [
    "Three BTS members test positive for Covid-19",
    "Third major cruise ship hit by Covid outbreak",
    "The bipartisan friendship that could overcome 'toxic' year in Washington",
    "World's most indebted property developer reports progress completing homes",
    "France may have their very own Donald Trump",
    "Opinion: Putin resurrected Soviet ghosts",
    "Nobel laureate and anti-apartheid hero has died",
    "Dad, sons and dogs die in fire likely caused by Christmas tree or electrical issues",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vertical Marquee Demo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MarqueeVertical(
                  itemCount: texts.length,
                  lineHeight: 20,
                  marqueeLine: 2,
                  itemBuilder: (index) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        texts[index],
                        overflow: TextOverflow.ellipsis,
                      )),
                  scrollDuration: const Duration(milliseconds: 300),
                  stopDuration: const Duration(seconds: 3),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MarqueeVertical(
                  itemCount: texts.length,
                  lineHeight: 20,
                  marqueeLine: 3,
                  direction: MarqueeVerticalDirection.moveDown,
                  itemBuilder: (index) {
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          texts[index],
                          overflow: TextOverflow.ellipsis,
                        ));
                  },
                  scrollDuration: const Duration(milliseconds: 300),
                  stopDuration: const Duration(seconds: 3),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MarqueeVertical(
                  itemCount: texts.length,
                  lineHeight: 23,
                  marqueeLine: 3,
                  direction: MarqueeVerticalDirection.moveDown,
                  itemBuilder: (index) {
                    return Row(children: [
                      const Icon(Icons.access_alarm),
                      Expanded(
                        child: Text(
                          texts[index],
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ]);
                  },
                  scrollDuration: const Duration(milliseconds: 300),
                  stopDuration: const Duration(seconds: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

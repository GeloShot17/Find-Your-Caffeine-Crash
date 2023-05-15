import 'package:flutter/material.dart';
import 'dart:math';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Find Your Crash: Caffeine Calculator',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black87,
        textTheme: Typography.whiteRedmond
      ),
      home: const MyHomePage(title: 'Find Your Crash: Caffeine Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key, required this.title});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  late final _weightController = TextEditingController();
  late final _caffController = TextEditingController();
  late final _outPut = TextEditingController();
  double? userWeightLBS, userWeightKG, caffeineAmt, minEffDose,
      drinkRatio, elapsedHLTime, dTime, exDrinkAmt;
  TimeOfDay? time = const TimeOfDay(hour: 00, minute: 00);

  late List<DropdownMenuItem<Drink>> _drinkItems;
  late Drink _selectedDrink;

  @override
  void initState(){
    super.initState();
    List<Drink> drinks = Drink.allDrinks;

    _drinkItems = drinks.map<DropdownMenuItem<Drink>>(
        (Drink drinkEntry){
          return DropdownMenuItem(
          value: drinkEntry,
          child: Text(drinkEntry.name,),
          );
        },
    ).toList();

    _selectedDrink = drinks[0];
  }

  @override
  void dispose(){
    _weightController.dispose();
    _caffController.dispose();
    _outPut.dispose();
    super.dispose();
  }

  String getTimeStringFromDouble(double value){
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);
    return '$hourValue:$minuteString';
  }

  String getMinuteString(double decimalValue){
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue){
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  void _calculateAll(){
    _outPut.text = 'No input was detected for one of the necessary fields, please try again.';
    userWeightLBS = double.tryParse(_weightController.text);
    userWeightKG = userWeightLBS! * 0.453592;
    caffeineAmt = double.tryParse(_caffController.text);
    dTime = (time!.hour + (time!.minute / 60));
    elapsedHLTime = (((log((caffeineAmt! / 2) / caffeineAmt!)) / -0.5) * 4.5) - 3;
    minEffDose = userWeightKG! * 6 / 3.5;

    if(exDrinkAmt != null && exDrinkAmt != 0){
      drinkRatio = (userWeightKG! * 6) / exDrinkAmt!;
      drinkRatio = double.parse((drinkRatio)!.toStringAsFixed(2));
      if((caffeineAmt! - minEffDose!) < 0){
        _outPut.text = 'Caffeine Content is less than your minimum effective dose, you might not feel a caffeine crash.\n'
            'But you can have $drinkRatio of selected drink daily.';
      } else if((caffeineAmt! - minEffDose!) < 20){
        elapsedHLTime = ((elapsedHLTime! - ((caffeineAmt! - minEffDose!) / 50))) + dTime!;
        String finalTime = getTimeStringFromDouble(elapsedHLTime!);
        _outPut.text = 'You would most likely feel a caffeine crash at $finalTime.\n'
            'You can also have $drinkRatio of the selected drink daily.';
      } else if((caffeineAmt! - minEffDose!) > 20){
        elapsedHLTime = (elapsedHLTime! + ((caffeineAmt! - minEffDose!) / 100))+ dTime!;
        String finalTime = getTimeStringFromDouble(elapsedHLTime!);
        _outPut.text = 'You would most likely feel a caffeine crash at $finalTime.\n'
            'You can also have $drinkRatio of the selected drink daily.';
      }
    } else {
      if((caffeineAmt! - minEffDose!) < 0){
        _outPut.text = 'Caffeine Content is less than your minimum effective dose, you might not feel a caffeine crash.';
      } else if((caffeineAmt! - minEffDose!) < 20){
        elapsedHLTime = ((elapsedHLTime! - ((caffeineAmt! - minEffDose!) / 50))) + dTime!;
        String finalTime = getTimeStringFromDouble(elapsedHLTime!);
        _outPut.text = 'You would most likely feel a caffeine crash at $finalTime.';
      } else if((caffeineAmt! - minEffDose!) > 20){
        elapsedHLTime = (elapsedHLTime! + ((caffeineAmt! - minEffDose!) / 100))+ dTime!;
        String finalTime = getTimeStringFromDouble(elapsedHLTime!);
        _outPut.text = 'You would most likely feel a caffeine crash at $finalTime.';
      }
    }
  }

  @override
  Widget build(BuildContext context){
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    final hours = time?.hour.toString().padLeft(2,'0');
    final minutes = time?.minute.toString().padLeft(2,'0');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.coffee_rounded,
              color: Colors.orange,
              size: 100,
            ),
            const Text(
              'Your Weight:',
            ),
            SizedBox(
              width: 350,
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)
                    ),
                    labelText: 'In Pounds(lbs)',
                    labelStyle: TextStyle(color: Colors.white)
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'How Much Caffeine Did You Consume?'
            ),
            SizedBox(
              width: 350,
              child: TextField(
                controller: _caffController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                  labelText: 'In Milligrams(mg)',
                  labelStyle: TextStyle(color: Colors.white)
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'What Time Did You Consume Caffeine?',
            ),
            OutlinedButton(
                onPressed: ()async{
                  TimeOfDay? timeTaken = await showTimePicker(
                      context: context,
                      initialTime: time!
                  );
                  if(timeTaken != null){
                    setState(() {
                      time =timeTaken;
                    });
                  }
                },
                style: ButtonStyle(side: MaterialStateProperty.all(
                      const BorderSide(color: Colors.orange)
                )),
                child: Text('$hours:$minutes',
                  style: const TextStyle(fontSize: 30),
                ),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DoneScreen(text: _outPut.text)));
                _calculateAll();
              },
              child: const Text("Calculate", style: TextStyle(fontSize: 20),),
            ),
            const SizedBox(
              width: 300,
              child: Text('You can also see how much of theses popular drinks is you daily maximum.',
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.orange,
              ),
              child:
              DropdownButton(
                value: _selectedDrink,
                onChanged: (name){
                  setState(() {
                    _selectedDrink = name!;
                  });
                  if(name != null)
                    {exDrinkAmt = name.cafAmt.toDouble();}
                },
                items: _drinkItems,
                dropdownColor: Colors.orange,
                iconSize: 42,
                isDense: true,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ].map((widget) => Padding(
            padding: const EdgeInsets.all(5),
            child: widget,
          )).toList(),
        ),
      ),
    );
  }
}

class DoneScreen extends StatelessWidget{
  final String text;
  const DoneScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Crash: Caffeine Calculator')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: Text(text,
                style: const TextStyle(fontSize: 30),
              ),    //final output,
            ),
            ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Go Back",
              style: TextStyle(fontSize: 20),),
            )   //go back button
          ].map((widget) => Padding(
            padding: const EdgeInsets.all(10),
            child: widget,
          )).toList(),
        ),
      ),
    );
  }
}

class Drink{
  final String name;
  final int cafAmt;

  Drink(this.name, this.cafAmt);

  static List<Drink> get allDrinks => [
    Drink('Choose a Drink', 0),
    Drink('5 Hour Energy, 200mg', 200),
    Drink('Shot of Espresso, 77mg',77),
    Drink('Starbucks Grande Caffe Latte, 150mg', 150),
    Drink('Starbucks Nitro Cold Brew, 280mg', 280),
    Drink('8 fl oz Red Bull, 80mg', 80),
    Drink('16 fl oz Rockstar Energy/Monster Energy, 160 mg', 160),
    Drink('15 fl oz Guayaki Canned Yerba Mate, 150mg', 150),
    Drink('12 fl oz can of Soda, 40mg', 40)];
}
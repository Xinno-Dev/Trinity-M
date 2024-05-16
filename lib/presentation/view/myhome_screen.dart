import 'package:flutter/material.dart';
import '../../../common/style/textStyle.dart';
import '../../../data/repository/ecc_repository_impl.dart';
import '../../../domain/repository/ecc_repository.dart';
import '../../../domain/usecase/ecc_usecase.dart';
import '../../../domain/usecase/ecc_usecase_impl.dart';

class MyHomePage extends StatefulWidget {
  static String get routeName => 'init';
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  int _counter = 0;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EccRepository _repository = EccRepositoryImpl();
    final EccUseCase _usecase = EccUseCaseImpl(_repository);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
                style: typo28bold,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              ElevatedButton(
                onPressed: () {
                  _usecase.generateKeyPair('').then(
                    (value) {
                      print('$value');
                    },
                  );
                },
                child: Text('Generate KeyPair'),
              ),
              ElevatedButton(
                onPressed: () {
                  _usecase.updateSign('', '').then((value) {
                    print('$value');
                  });
                },
                child: Text('updateSign'),
              ),
              ElevatedButton(
                onPressed: () {
                  _usecase.deleteSign('').then((value) {
                    print('$value');
                  });
                },
                child: Text('deleteSign'),
              ),
              ElevatedButton(
                onPressed: () {
                  _usecase
                      .verify(
                          'dbcc28981001bdf72ebc48ea80ea7e6e48c2eba7a8a2822f94039c4dd51b6f7257a8fa3ce1488266d07f3a1b652fddf8dc134b46fb9e2fbd824585e4917d3f01',
                          '1672216134542this is uiddbcc28981001bdf72ebc48ea80ea7e6e48c2eba7a8a2822f94039c4dd51b6f7257a8fa3ce1488266d07f3a1b652fddf8dc134b46fb9e2fbd824585e4917d3f01E771AB7DB9C4A5B1980099CF0FFE96374A1C160270F0376EC5F04DE16F4A4866',
                          '6d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e2ab841988b20194428efe0b43f0bf3fb92d84f58338cc5ad0fd29b54a9fac0e0e')
                      .then((value) {
                    print('$value');
                  });
                },
                child: Text('Verify'),
              ),
              ElevatedButton(
                onPressed: () {
                  _usecase.deleteKeyPair().then((value) {
                    print('$value');
                  });
                },
                child: Text('Delete'),
              ),
              Text(
                'dataasdasdasdasdasdasdsad',
                style: typo28bold,
              ),
              Text(
                'datzxczczxczxczxczxa',
                style: typo24bold,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  //
}

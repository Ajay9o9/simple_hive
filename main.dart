import 'package:flutter/material.dart';
import 'package:hive_example/people.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PeopleAdapter());
  await Hive.openBox('peopleBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box contactBox;

  @override
  void initState() {
    super.initState();
    contactBox = Hive.box('peopleBox');
  }

  _addInfo() async {
    People newPerson = People(
      name:
          'Username at ${DateTime.now().hour}H: ${DateTime.now().minute}M : ${DateTime.now().second}S : ${DateTime.now().millisecond}MS',
      country: 'Country',
    );
    contactBox.add(newPerson);
  }

  _updateInfo(int index) async {
    People newPerson = People(
      name:
          'Updated at ${DateTime.now().hour}H: ${DateTime.now().minute}M : ${DateTime.now().second}S : ${DateTime.now().millisecond}MS',
      country: 'Country updated ',
    );

    contactBox.putAt(index, newPerson);
    // contactBox.add(newPerson);
  }

  _deleteInfo(int index) {
    contactBox.deleteAt(index);
    print('Item deleted from box at index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive CRUD example"),
      ),
      body: ValueListenableBuilder(
        valueListenable: contactBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Empty, Add some items to begin with'),
            );
          } else {
            return ListView.separated(
              itemCount: box.length,
              itemBuilder: (context, index) {
                var currentBox = box;
                var personData = currentBox.getAt(index)!;
                return InkWell(
                  onTap: () {
                    _updateInfo(index);
                  },
                  child: ListTile(
                    leading: Text("${(index + 1)}"),
                    title: Text(personData.name),
                    subtitle: Text(personData.country,
                        style: TextStyle(color: Colors.purple.shade400)),
                    trailing: IconButton(
                      onPressed: () => _deleteInfo(index),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 10,
                  endIndent: 20,
                  thickness: 1,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addInfo();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // Closes all Hive boxes
    Hive.close();
    super.dispose();
  }
}

import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hash/hash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  var databaseFactory = databaseFactoryFfi;
  final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();

  //Create path for database
  String dbPath = p.join(appDocumentsDir.path, "databases", "myDb.db");

  var db = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Product (
            id INTEGER PRIMARY KEY,
            title TEXT
        )''');
        await db.execute('''CREATE TABLE User (
            id INTEGER PRIMARY KEY,
            username TEXT UNIQUE,
            password TEXT
        )''');
        await db.insert('User',
            <String, Object?>{'username': 'admin', 'password': 'admin'});
      },
    ),
  );

  // await db.execute('''
  // CREATE TABLE Product (
  //     id INTEGER PRIMARY KEY,
  //     title TEXT
  // )
  // ''');

  // await db.execute('''
  // CREATE TABLE User (
  //     id INTEGER PRIMARY KEY,
  //     username TEXT UNIQUE,
  //     password TEXT
  // )
  // ''');
  // await db.insert(
  //     'User', <String, Object?>{'username': 'admin', 'password': 'admin'});

  print(await db.query('User'));
  var result = await db.query('Product');
  print(result);
  // prints [{id: 1, title: Product 1}, {id: 2, title: Product 1}]

  void addNewProduct(String productName) async {
    await db.insert('Product', <String, Object?>{'title': productName});
  }

  await db.close();

  print(db.path);
  var hash = [
    96,
    191,
    108,
    70,
    168,
    246,
    217,
    160,
    43,
    181,
    160,
    241,
    248,
    105,
    30,
    176,
    215,
    208,
    207,
    100,
    148,
    36,
    244,
    211,
    133,
    189,
    243,
    31,
    194,
    97,
    180,
    190
  ];
  print("MD5 digest as bytes: ${MD5().update(hash).digest()}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Accounting'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var result = [];
  bool isActive = false;
  List<PlutoColumn> columns = [
    /// Text Column definition
    PlutoColumn(
      title: 'ID',
      field: 'text_field',
      type: PlutoColumnType.number(),
    ),

    /// Number Column definition
    PlutoColumn(
      title: 'Product Name',
      field: 'number_field',
      type: PlutoColumnType.text(),
    ),
  ];

  List<PlutoRow> rows = [];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future getData() async {
    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();

    //Create path for database
    String dbPath = p.join(appDocumentsDir.path, "databases", "myDb.db");

    var db = await databaseFactory.openDatabase(
      dbPath,
    );

    result = await db.query('Product');
    print(result);
    setState(() {});
    db.close();
  }

  void fillData() async {
    await getData();
    print(result.length);
    rows.clear();
    for (int i = 0; i < result.length; ++i) {
      rows.add(PlutoRow(cells: {
        'text_field': PlutoCell(value: result[i]['id']),
        'number_field': PlutoCell(value: result[i]['title']),
      }));
    }
    setState(() {});
  }

  @override
  void initState() {
    fillData();
    super.initState();
  }

  TextEditingController productName = TextEditingController();
  TextEditingController productEditName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (value) {
                  if (value.length < 3) {
                    setState(() {
                      isActive = false;
                    });
                  } else {
                    setState(() {
                      isActive = true;
                    });
                  }
                },
                controller: productName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Product Name',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isActive) {
                  var databaseFactory = databaseFactoryFfi;
                  final io.Directory appDocumentsDir =
                      await getApplicationDocumentsDirectory();

                  //Create path for database
                  String dbPath =
                      p.join(appDocumentsDir.path, "databases", "myDb.db");

                  var db = await databaseFactory.openDatabase(
                    dbPath,
                  );
                  void addNewProduct(String productName) async {
                    await db.insert(
                        'Product', <String, Object?>{'title': productName});
                  }

                  addNewProduct(productName.text);
                  result = await db.query('Product');
                  print(result);
                  setState(() {});
                  db.close();
                  productName.clear();
                }
              },
              child: const Text('Add Product'),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                    itemCount: result.length,
                    itemBuilder: (context, index) {
                      return DataTable(
                          columnSpacing: 0,
                          headingRowHeight: 0,
                          columns: const [
                            DataColumn(
                                label: SizedBox(
                              height: 0,
                            )),
                            DataColumn(
                                label: SizedBox(
                              height: 0,
                            ))
                          ],
                          rows: [
                            DataRow(
                                onLongPress: () async {
                                  productEditName.text =
                                      result[(result.length - 1) - index]
                                              ['title']
                                          .toString();
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.all(20),
                                          height: 200,
                                          color: Color.fromARGB(
                                              132, 179, 204, 247),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextField(
                                                  controller: productEditName,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: 'Product Name',
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                        child: const Text(
                                                            'Update Product'),
                                                        onPressed: () async {
                                                          var databaseFactory =
                                                              databaseFactoryFfi;
                                                          final io.Directory
                                                              appDocumentsDir =
                                                              await getApplicationDocumentsDirectory();

                                                          //Create path for database
                                                          String dbPath = p.join(
                                                              appDocumentsDir
                                                                  .path,
                                                              "databases",
                                                              "myDb.db");

                                                          var db =
                                                              await databaseFactory
                                                                  .openDatabase(
                                                            dbPath,
                                                          );
                                                          await db.update(
                                                              'Product',
                                                              {
                                                                'title':
                                                                    productEditName
                                                                        .text
                                                              },
                                                              where: 'id = ?',
                                                              whereArgs: [
                                                                result[(result
                                                                            .length -
                                                                        1) -
                                                                    index]['id']
                                                              ]);
                                                          fillData();
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    ElevatedButton(
                                                        child: const Text(
                                                            'Delete Product'),
                                                        onPressed: () async {
                                                          var databaseFactory =
                                                              databaseFactoryFfi;
                                                          final io.Directory
                                                              appDocumentsDir =
                                                              await getApplicationDocumentsDirectory();

                                                          //Create path for database
                                                          String dbPath = p.join(
                                                              appDocumentsDir
                                                                  .path,
                                                              "databases",
                                                              "myDb.db");

                                                          var db =
                                                              await databaseFactory
                                                                  .openDatabase(
                                                            dbPath,
                                                          );
                                                          await db.delete(
                                                              'Product',
                                                              where: 'id = ?',
                                                              whereArgs: [
                                                                result[(result
                                                                            .length -
                                                                        1) -
                                                                    index]['id']
                                                              ]);
                                                          fillData();
                                                          Navigator.pop(
                                                              context);
                                                        })
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                cells: [
                                  DataCell(Text(
                                      result[(result.length - 1) - index]['id']
                                          .toString())),
                                  DataCell(Text(
                                      result[(result.length - 1) - index]
                                              ['title']
                                          .toString()))
                                ])
                          ]);
                      //  ListTile(
                      //     title: Text(result[(result.length - 1) - index]['title']),
                      //     leading: Text(
                      //         result[(result.length - 1) - index]['id'].toString()),
                      //   );
                    }),
              ),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              padding: const EdgeInsets.all(30),
              height: 200,
              child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onChanged: (PlutoGridOnChangedEvent event) {
                    print("Changeed");
                  },
                  onLoaded: (PlutoGridOnLoadedEvent event) {}),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

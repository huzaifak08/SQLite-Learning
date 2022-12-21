import 'package:asiftaj_sqflite/database_handler.dart';
import 'package:asiftaj_sqflite/notes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    super.initState();

    dbHelper = DBHelper();
    loadData();
  }

  loadData() async {
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Notes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: notesList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Update Data on Click:

                          dbHelper!.update(NotesModel(
                              id: snapshot.data![index].id,
                              title: 'Huzaifa',
                              age: 19,
                              description: 'Updated Data',
                              email: 'myemail'));
                          setState(() {
                            notesList = dbHelper!.getNotesList();
                          });
                        },
                        child: Dismissible(
                          key: ValueKey<int>(snapshot.data![index].id!),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: Icon(Icons.delete_forever),
                          ),

                          // Delete Code Here:
                          onDismissed: ((DismissDirection direction) {
                            setState(() {
                              // Delete from database:
                              dbHelper!.delete(snapshot.data![index].id!);

                              // Get Data again after deletion of certain data:
                              notesList = dbHelper!.getNotesList();

                              // Remove the index from the appeared screen also:
                              snapshot.data!.remove(snapshot.data![index]);
                            });
                          }),
                          child: Card(
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title:
                                  Text(snapshot.data![index].title.toString()),
                              subtitle: Text(
                                  snapshot.data![index].description.toString()),
                              trailing:
                                  Text(snapshot.data![index].age.toString()),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dbHelper!
              .insert(NotesModel(
            title: 'First note',
            age: 23,
            description: 'Hello',
            email: 'huzaifa@gmai.com',
          ))
              .then((value) {
            debugPrint('Data Added');
            setState(() {
              notesList = dbHelper!.getNotesList();
            });
          }).onError((error, stackTrace) {
            debugPrint(error.toString());
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

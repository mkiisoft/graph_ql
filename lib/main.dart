import 'package:flutter/material.dart';
import 'package:graph_ql/graph_ql.dart';
import 'package:graph_ql/model.dart';
import 'package:graph_ql/util.dart';
import 'package:graphql/client.dart';

void main() => runApp(GraphQLApp());

class GraphQLApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = TextEditingController();
  final _loading = ValueNotifier(false);

  final _characters = <Character>[];

  GraphQLClient _client;

  void handleResult(QueryResult result) {
    print(result.data);
    if (result.data != null) {
      _characters.add(Character.toObject(result.data, Utils.randomColor()));
    }
    _loading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _client = GraphQL('https://graphql.anilist.co').getClient();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.1,
              right: size.width * 0.1,
              top: 30,
            ),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextFormField(
                  onFieldSubmitted: (query) async {
                    _loading.value = true;
                    _controller.clear();
                    handleResult(await _client.queryCharacter(query));
                  },
                  controller: _controller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Anime Characters'),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _loading,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 30,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final character = _characters[index];
                        return Card(
                          elevation: 15,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(character.image, fit: BoxFit.cover),
                              Column(
                                children: [
                                  Expanded(child: SizedBox()),
                                  Container(
                                    width: size.width,
                                    color: character.color,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Center(
                                        child: Text(
                                          character.fullName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: _characters.length,
                    ),
                    if (value) Center(child: CircularProgressIndicator())
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

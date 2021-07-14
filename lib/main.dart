import 'package:flutter/material.dart';
import 'package:untitled11/search_results_list_view.dart';

import "package:graphql_flutter/graphql_flutter.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink link = HttpLink("https://api.spacex.land/graphql/");

    ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ));

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Expenses',
        theme: ThemeData(
          fontFamily: 'Quicksand',
          primarySwatch: Colors.cyan,
          accentColor: Colors.black,
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                ),
                button: TextStyle(color: Colors.white)),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";


  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      cursorColor: Colors.white,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search missions",
        hintStyle: TextStyle(color: Colors.white30),
        border: InputBorder.none,
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) => setState(() => searchQuery = newQuery);

  void _stopSearching() {
    _clearSearchQuery();
    setState(() => _isSearching = false);
  }

  void _clearSearchQuery() => setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : Container(),
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SearchResultsListView(
          searchTerm: searchQuery,
        ),
      ),
    );
  }
}

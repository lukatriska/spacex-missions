import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchResultsListView extends StatefulWidget {
  final String searchTerm;

//  final Function getSearchTerm;

  const SearchResultsListView({
    Key? key,
    required this.searchTerm,
//    required this.getSearchTerm,
  }) : super(key: key);

  @override
  _SearchResultsListViewState createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.searchTerm == "" || widget.searchTerm == "Search query") {
      return Center(
        child: Text(
          'Start writing a mission name...',
          style: Theme.of(context).textTheme.headline5,
        ),
      );
    }

    final String fetchLaunches = """
      query ReadRepositories {
        launches {
          id
          details
          mission_name
        }
      }
    """;

    return Container(
        child: Query(
      options: QueryOptions(
        document: gql(fetchLaunches),
      ),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Loading',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        List launches = result.data!['launches'];

        return ListView.builder(
          itemCount: launches.length,
          itemBuilder: (context, index) {
            final launch = launches[index];

            if (launch['mission_name']
                    .toLowerCase()
                    .contains(widget.searchTerm.toLowerCase()) &&
                widget.searchTerm.length > 3) {
              return ListTile(
                title: Text(
                  launch['mission_name'],
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Container(
                  child: launch['details'] == null
                      ? Text('No details provided.')
                      : Text(launch['details']),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      },
    ));
  }
}

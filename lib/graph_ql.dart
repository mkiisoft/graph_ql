import 'package:graphql/client.dart';

class GraphQL {
  final baseURL;

  GraphQL(this.baseURL);

  GraphQLClient getClient() => GraphQLClient(
        cache: InMemoryCache(storagePrefix: ''),
        link: HttpLink(uri: baseURL).concat(null),
      );
}

extension Graph on GraphQLClient {
  Future queryCharacter(String query) {
    final String readCharacter = """
          query ReadCharacter(\$character: String) {
              character: Character(search: \$character) {
                id,
                name {
                  full
                  native
                },
                image {
                  large
                }
              }
          }
    """;

    return this.query(
      QueryOptions(
        documentNode: gql(readCharacter),
        variables: {'character': query},
      ),
    );
  }
}

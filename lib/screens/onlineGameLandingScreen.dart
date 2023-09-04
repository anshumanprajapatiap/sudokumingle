import 'package:flutter/material.dart';

class OnlineGameLandingScreen extends StatefulWidget {
  const OnlineGameLandingScreen({super.key});

  @override
  State<OnlineGameLandingScreen> createState() => _OnlineGameLandingScreenState();
}

class _OnlineGameLandingScreenState extends State<OnlineGameLandingScreen> {
  bool _showSearchResults = false; // Flag to control content switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online With Buddzzies'),
      ),
      // body: _showSearchResults ? _buildSearchResults() : _buildContent(),
      body: Column(
        children: [
          _buildSearchBar(),

          _showSearchResults
              ? _buildSearchResults()
              : _buildContent()
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search users...',
        prefixIcon: Icon(Icons.search),
      ),
      onTap: (){
        setState(() {
          _showSearchResults = true;
        });
      },
      onChanged: (query) {
        // Implement your search logic here
        // You can set the search results and update the UI accordingly
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildRecentGames(),
        ElevatedButton(
          onPressed: (){

          },
          child: Text('Play Online'),
        ),
      ],
    );
  }

  Widget _buildRecentGames() {
    Widget circularProgressIndicator = CircularProgressIndicator(strokeWidth: 10);

    return Column(
      children: [
        Text(
          'Recent Games With',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(
              2, // Number of rows
                  (rowIndex) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5, // Number of columns
                      (colIndex) => Padding(
                    padding: EdgeInsets.all(8.0),
                    child: circularProgressIndicator,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    // Implement your search results (list of users) widget here
    // Use ListView.builder to display the list of users
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height*0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Search Friend'),
          SingleChildScrollView(
            child: Column(
              children: [
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),
                Text('sagasgaga'),


              ],
            ),
          )
        ],
      ),
    );

  }
}


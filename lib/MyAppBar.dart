import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyState.dart';
import 'API.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const MyAppBar(
      {Key? key,
      required this.scaffoldKey})
      : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(150);
}

class _MyAppBarState extends State<MyAppBar> {
  bool _isExpanded = false;
  bool _isLoading = false;
  final _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  void onSearchSubmission(String currentTextInForm) async {
    setState(() {
      _isLoading = true;
      _isExpanded = false;
    });
    List<Map<String, dynamic>> searchResults =
        await getSearchResults(currentTextInForm);
    setState(() {
      _isLoading = false;
    });
    context.read<MyState>().setSearchResult(searchResults);
  }

  @override
  Widget build(BuildContext context) {
    print("this is app bar");
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 100,
          width: double.infinity,
          child: Row(
            children: [
              // ---------------------- 1st item ----------------------
              if (!_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: GestureDetector(
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onTap: () {
                       widget.scaffoldKey.currentState!.openDrawer();
                    },
                  ),
                ),

              // ---------------------- 2nd item ----------------------
              if (_isExpanded)
                //white cross icon
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

              Expanded(
                child: Center(
                    child: _isExpanded
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: TextFormField(
                              focusNode: _searchFocusNode,
                              onFieldSubmitted: (currentTextInForm) async {
                                onSearchSubmission(currentTextInForm);
                              },
                              controller: _searchController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                              ),
                            ))
                        : _isLoading
                            ? LoadingAnimationWidget.hexagonDots(
                                size: 30,
                                color: Colors.white,
                              )
                            : const Text(
                                "TuneTube",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
              ),

              // ---------------------- 3rd item ----------------------

              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () async {
                    //set focus to search field
                    _searchFocusNode.requestFocus();

                    // ----------- getting the search results -------------
                    if (_isExpanded && _searchController.text.isNotEmpty) {
                      onSearchSubmission(_searchController.text);
                    }

                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petapp/models/user.dart';
import 'package:petapp/services/api_service.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> with AutomaticKeepAliveClientMixin {
  final ApiService _apiService = ApiService();
  final List<User> _users = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isEndOfList = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchMoreUsers();
      }
    });
  }

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _users.clear();
      _currentPage = 1;
      _isEndOfList = false;
    });
    try {
      List<User> users = await _apiService.getUsers(page: _currentPage);
      setState(() {
        _users.addAll(users);
      });
      _checkIfMoreDataNeeded();
    } catch (e) {
      //Fluttertoast.showToast(msg: 'nope');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchMoreUsers() async {
    if (!_isLoading && !_isEndOfList) {
      // Check if not currently loading and not at end of list
      setState(() {
        _isLoading = true;
      });
      _currentPage++; // Increment the page number to fetch the next set of data
      try {
        List<User> moreUsers = await _apiService.getUsers(page: _currentPage);
        if (moreUsers.isEmpty) {
          setState(() {
            _isEndOfList = true;
            _currentPage--; // No more data is available
          });
        } else {
          setState(() {
            _users.addAll(moreUsers);
          });
          _checkIfMoreDataNeeded(); // Check if the viewport is still not filled
        }
      } catch (e) {
        // Fluttertoast.showToast(
        //   msg: 'Error fetching more users: $e',
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _currentPage = 1; // Reset to the first page
      _isEndOfList = false; // Reset end of list flag
    });
    _fetchUsers(); // Fetch initial users again
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API'),
        surfaceTintColor: Colors.white,
      ),
      body: Center(
        child: _isLoading && _users.isEmpty
            ? const CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: _refreshUsers,
                child: ListView.builder(
                  itemCount: _users.length + (_isLoading ? 1 : 0),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index < _users.length) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        elevation: 4, // Shadow effect
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          leading: _users[index].avatarUrl != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(_users[index].avatarUrl!),
                                  radius: 25, // Size of the avatar
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person,
                                      size: 30, color: Colors.grey[600]),
                                ),
                          title: Text(
                            _users[index].name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold), // Text styling
                          ),
                          subtitle: _users[index].createdAt != null
                              ? Text(
                                  DateFormat('dd-MM-yyyy kk:mm')
                                      .format(_users[index].createdAt),
                                  style: TextStyle(color: Colors.grey[600]),
                                )
                              : const Text('Date not available',
                                  style: TextStyle(color: Colors.grey)),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey), // Optional trailing icon
                        ),
                      );
                    } else if (_isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (_isEndOfList) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                            child: Text("You've reached the end of the list")),
                      );
                    } else {
                      return Container(); // Empty container for non-loading, non-end-of-list scenarios
                    }
                  },
                )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0.0, // Scroll to the top of the list
            duration: const Duration(seconds: 1), // Duration of the scroll animation
            curve: Curves.easeInOut, // Type of animation curve
          );
        },
        child: const Icon(Icons.arrow_upward), // Icon for the button
      ),
    );
  }

  void _checkIfMoreDataNeeded() {
    // Delayed check to allow the list view to build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.maxScrollExtent <=
          _scrollController.position.pixels) {
        _fetchMoreUsers();
      }
    });
  }
  
  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grid_view/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Search Grid',
      theme: ThemeData.dark(),
      home: SplashScreen(),
    );
  }
}

class GridSetupScreen extends StatefulWidget {
  @override
  _GridSetupScreenState createState() => _GridSetupScreenState();
}

class _GridSetupScreenState extends State<GridSetupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController rowController = TextEditingController();
  final TextEditingController colController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  int rows = 0;
  int cols = 0;
  List<String> letters = [];
  List<bool> highlightedCells = [];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void generateGrid() {
    String rowText = rowController.text;
    String colText = colController.text;
    String letterText = textController.text;

    if (rowText.isEmpty || colText.isEmpty || letterText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      rows = int.tryParse(rowText) ?? 0;
      cols = int.tryParse(colText) ?? 0;
      letters = letterText.toUpperCase().split("").take(rows * cols).toList();
      highlightedCells = List.filled(rows * cols, false);
      _controller.forward(from: 0);
    });
  }

  void resetGrid() {
    setState(() {
      rowController.clear();
      colController.clear();
      textController.clear();
      searchController.clear();
      rows = 0;
      cols = 0;
      letters = [];
      highlightedCells = [];
      _controller.reset();
    });
  }

  void searchWord() {
    String searchText = searchController.text.toUpperCase();
    if (searchText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a word to search",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      highlightedCells = List.filled(rows * cols, false);
    });

    bool wordFound = false;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Horizontal Check
        if (c + searchText.length <= cols) {
          checkAndHighlight(searchText, r, c, 0, 1);
        }

        // Vertical Check
        if (r + searchText.length <= rows) {
          checkAndHighlight(searchText, r, c, 1, 0);
        }

        // Diagonal Check (Bottom-Right)
        if (r + searchText.length <= rows && c + searchText.length <= cols) {
          checkAndHighlight(searchText, r, c, 1, 1);
        }

        // Diagonal Check (Bottom-Left)
        if (r + searchText.length <= rows && c - searchText.length >= -1) {
          checkAndHighlight(searchText, r, c, 1, -1);
        }
      }
    }

    if (!highlightedCells.contains(true)) {
      Fluttertoast.showToast(
        msg: "Word not found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void checkAndHighlight(String searchText, int startRow, int startCol, int rowStep, int colStep) {
    String word = "";
    List<int> indices = [];

    for (int i = 0; i < searchText.length; i++) {
      int index = (startRow + i * rowStep) * cols + (startCol + i * colStep);
      word += letters[index];
      indices.add(index);
    }

    if (word == searchText) {
      setState(() {
        for (var index in indices) {
          highlightedCells[index] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Search Grid", style: GoogleFonts.poppins(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Create Your Grid',
                  textStyle: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  speed: Duration(milliseconds: 100),
                ),
              ],
              repeatForever: true,
            ),
            SizedBox(height: 20),

            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: rowController,
                    decoration: InputDecoration(
                      labelText: "Enter number of rows",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: colController,
                    decoration: InputDecoration(
                      labelText: "Enter number of columns",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: "Enter letters (m*n characters)",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: generateGrid, style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Generate Grid")),
                ElevatedButton(onPressed: resetGrid, style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ), child: Text("Reset")),
              ],
            ),

            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Enter word to serach ",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(onPressed: searchWord, style:ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ), child: Text("Search")),

            SizedBox(height: 20),
            if (letters.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: letters.length,
                  itemBuilder: (context, index) {
                    return ScaleTransition(
                      scale: _controller,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: highlightedCells[index] ? Colors.blueAccent : Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          letters[index],
                          style: GoogleFonts.robotoMono(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController searchController = TextEditingController();

  int rows = 0;
  int cols = 0;
  List<TextEditingController> gridControllers = [];
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

    if (rowText.isEmpty || colText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter both row and column values",
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
      gridControllers = List.generate(rows * cols, (index) => TextEditingController());
      highlightedCells = List.filled(rows * cols, false);
    });
  }

  void resetGrid() {
    setState(() {
      rowController.clear();
      colController.clear();
      searchController.clear();
      rows = 0;
      cols = 0;
      gridControllers = [];
      highlightedCells = [];
    });
  }


  void searchWord(String searchText) {
    searchText = searchText.toUpperCase();
    setState(() {
      highlightedCells = List.filled(rows * cols, false);
    });

    if (searchText.isEmpty) return;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (c + searchText.length <= cols) {
          checkAndHighlight(searchText, r, c, 0, 1);
        }
        if (r + searchText.length <= rows) {
          checkAndHighlight(searchText, r, c, 1, 0);
        }
        if (r + searchText.length <= rows && c + searchText.length <= cols) {
          checkAndHighlight(searchText, r, c, 1, 1);
        }
        if (r + searchText.length <= rows && c - searchText.length >= -1) {
          checkAndHighlight(searchText, r, c, 1, -1);
        }
      }
    }
  }

  void checkAndHighlight(String searchText, int startRow, int startCol, int rowStep, int colStep) {
    String word = "";
    List<int> indices = [];

    for (int i = 0; i < searchText.length; i++) {
      int index = (startRow + i * rowStep) * cols + (startCol + i * colStep);
      if (index < 0 || index >= gridControllers.length) return;
      word += gridControllers[index].text.toUpperCase();
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

            buildInputField(rowController, "Enter number of rows"),
            buildInputField(colController, "Enter number of columns"),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: generateGrid,
              style: buttonStyle(Colors.deepPurple),
              child: Text("Generate Grid"),
            ),

            SizedBox(height: 20),

            if (rows > 0 && cols > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: highlightedCells[index] ? Colors.blueAccent : Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                      ),
                      child: Center(
                        child: TextField(
                          controller: gridControllers[index],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: GoogleFonts.robotoMono(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            gridControllers[index].text = value.toUpperCase();
                            gridControllers[index].selection = TextSelection.fromPosition(
                                TextPosition(offset: gridControllers[index].text.length));
                            searchWord(searchController.text);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 20),

            buildInputField(searchController, "Enter word to search", onChanged: searchWord),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: resetGrid,
              style: buttonStyle(Colors.red),
              child: Text("Reset Grid"),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(TextEditingController controller, String label, {Function(String)? onChanged}) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2, offset: Offset(2, 2))],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
        ),
        textCapitalization: TextCapitalization.characters,
        onChanged: onChanged,
      ),
    );
  }

  ButtonStyle buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

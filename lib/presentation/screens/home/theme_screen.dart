import 'package:appointment_app/presentation/providers/provider_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatelessWidget {
  ThemeScreen({super.key});
  final List<Color> colores = [
    const Color.fromARGB(255, 238, 196, 197),
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
    Colors.lightBlue,
    // ? Juan's Colors
    const Color.fromARGB(255, 245, 245, 245),
    const Color.fromARGB(255, 64, 112, 112),
    const Color.fromARGB(255, 218, 187, 133),
    const Color.fromARGB(255, 191, 211, 244),
  ];

  @override
  Widget build(BuildContext context) {
    final changeTheme = context.watch<ProviderTheme>();
    final changeFont = context.watch<ProviderFont>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Colors'),
      ),
      body: ListView.builder(
        itemCount: colores.length,
        itemBuilder: (context, index) {
          Color color = colores[index];
          return ListTile(
            title: Text('Color ${index + 1}'),
            leading: Container(
              width: 30,
              height: 30,
              color: color,
            ),
            onTap: () {              
              changeTheme.colorValue = index;
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => changeFont.fontValue = 'Rubik', 
            child: const Text('Rubik', style: TextStyle(fontFamily: 'Rubik'),)
          ),
          ElevatedButton(
            onPressed: () => changeFont.fontValue = 'Agbalumo', 
            child: const Text('Agbalumo', style: TextStyle(fontFamily: 'Agbalumo'),)
          ),
          ElevatedButton(
            onPressed: () => changeFont.fontValue = 'Lato', 
            child: const Text('Lato', style: TextStyle(fontFamily: 'Lato'),)
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:search/Widgets/Voicett.dart';
import '../models/patient.dart';
import 'OCR0ptionsPage.dart';
import '../models/treatement.dart';
import 'package:xml/xml.dart';
import '../Widgets/Drawerwidget.dart'; // Import the AppDrawer widget
import 'package:cloud_firestore/cloud_firestore.dart';


String dent='';

class TreatmentChart extends StatefulWidget {
  final Function(Treatement) addtreat; // Define the callback function
  final Patient patient;
  const TreatmentChart({super.key, required this.addtreat, required this.patient});

  @override
  State<TreatmentChart> createState() => _TreatmentChartState();
}


class _TreatmentChartState extends State<TreatmentChart> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController natureIntervController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController doitController = TextEditingController();
  final TextEditingController recuController = TextEditingController();

  void _showdatepicker() async{
    final DateTime? selectedDate= await
    showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2080),
    );
    if (selectedDate!=null){
      setState(() {
        final formattedDate= '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
        dateController.text=formattedDate;
      });
    }
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String notes = notesController.text;
      String natureIntv = natureIntervController.text;
      String doit = doitController.text;
      String recu = recuController.text;
      String treatDate = dateController.text;

      Treatement newTreat = Treatement(
          null, // Firestore will generate the ID
          DateTime.parse(treatDate),
          dent,
          natureIntv,
          notes,
          int.parse(doit),
          int.parse(recu),
          widget.patient.id // Pass the patient ID from the widget
      );

      FirebaseFirestore.instance
          .collection('Patients')
          .doc(widget.patient.id) // Use the patient's ID
          .collection('treatements') // Use the treatments subcollection
          .add(newTreat.toFirestore()) // Convert the object to Firestore data
          .then((docRef) {
        newTreat.id = docRef.id; // Update the ID of the treatment
        widget.addtreat(newTreat); // Call the callback function
        Navigator.pop(context, true);
      }).catchError((error) {
        if (kDebugMode) {
          print("Error adding document: $error");
        }
        Navigator.pop(context, false); // Indicate an error occurred
      });

      // Clear text fields
      dateController.clear();
      natureIntervController.clear();
      notesController.clear();
      doitController.clear();
      recuController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please check your inputs'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Treatment Chart'),
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 30.0), // Adjust the padding as needed for spacing
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OCROptionsPage()),
                );
              },
              icon: const Icon(Icons.camera_alt ),iconSize: 30,

            ),
          ],
        ),
        drawer: const Drawerw(), // Use the AppDrawer widget here

        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Image(
                    width: 5,
                    height: 1,
                    image: Svg('assets/teeth.svg'),
                  ),
                  const SizedBox(height: 20),
                  const Foo(
                    asset: 'assets/teeth.svg',
                    idToString: adultIdToString,
                  ),
                  Material(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onTap: _showdatepicker,
                      controller: dateController,
                      decoration:  InputDecoration(
                        labelText: 'Treatment Date (YYYY-MM-DD)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Date';
                        }
                        // You can add more validation if needed
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: natureIntervController,
                            decoration:  InputDecoration(
                              labelText: 'Nature of Intervention',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter nature of intervention';
                              }
                              if (value.startsWith(' ')) { // Check if the value starts with a space
                                return 'Nature of intervention cannot start with a space';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
                                return 'Please enter valid nature of intervention';
                              }
                              // You can add more validation if needed
                              return null;
                            },
                          ),
                        ),
                        Voicett(controller: natureIntervController),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: notesController,
                            decoration:  InputDecoration(
                                labelText: 'Note',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a Note';
                              }
                              if (value.startsWith(' ')) { // Check if the value starts with a space
                                return 'Note cannot start with a space';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
                                return 'Please enter valid Note';
                              }
                              // You can add more validation if needed
                              return null;
                            },
                          ),
                        ),
                        Voicett(controller: notesController),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: doitController,
                            keyboardType: TextInputType.number,
                            inputFormatters:<TextInputFormatter> [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration:  InputDecoration(
                              labelText: 'Charge',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Your Charge amount';
                              }
                              // You can add more validation if needed
                              return null;
                            },
                          ),
                        ),
                        Voicett(controller:doitController),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: recuController,
                            keyboardType: TextInputType.number,
                            inputFormatters:<TextInputFormatter> [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: 'Payment',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Your Payment amount';
                              }
                              // You can add more validation if needed
                              return null;
                            },
                          ),
                        ),
                        Voicett(controller: recuController),

                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Add spacing between widgets as needed
        ],
      ),
    ));
  }
}

typedef Data = ({Size size, Map<int, Tooth> teeth});

class Foo extends StatefulWidget {
  const Foo({
    super.key,
    required this.asset,
    required this.idToString,
  });
  final String asset;
  final String Function(int id) idToString;

  @override
  State<Foo> createState() => _FooState();
}

class _FooState extends State<Foo> {
  Data data = (size: Size.zero, teeth: {});

  @override
  void initState() {
    super.initState();
    loadTeeth(widget.asset).then((value) {
      setState(() => data = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data.size == Size.zero) return const UnconstrainedBox();

    return Card(
      child: FractionallySizedBox( // Wrap with FractionallySizedBox
        widthFactor: 0.7, // Adjust the width factor as needed
        child: FittedBox(
          child: SizedBox.fromSize(
            size: data.size,
            child: Stack(
              children: [
                // teeth
                for (final MapEntry<int, Tooth> entry in data.teeth.entries)
                  Positioned.fromRect(
                    rect: entry.value.rect,
                    child: Tooltip(
                      message: widget.idToString(entry.key), // Pass the tooth name directly here
                      textAlign: TextAlign.center,
                      preferBelow: false,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.white54),
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 750),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: entry.value.selected ? Colors.teal.shade400 : Colors.white,
                          shadows: entry.value.selected
                              ? [const BoxShadow(blurRadius: 4, offset: Offset(0, 6))]
                              : null,
                          shape: ToothBorder(entry.value.path),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            splashColor:
                            entry.value.selected ? Colors.white : Colors.teal.shade400,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                entry.value.selected = !entry.value.selected;
                                dent = entry.key.toString();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                // selected teeth list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 150),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final selected = data.teeth.entries
                            .where((e) => e.value.selected)
                            .map((e) => Text(widget.idToString(e.key)))
                            .toList();
                        return DefaultTextStyle(
                          style: Theme.of(context).textTheme.titleLarge!,
                          textAlign: TextAlign.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: selected.isNotEmpty ? 1 : 0,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                border: Border.symmetric(
                                  horizontal: BorderSide(width: 3, color: Colors.black26),
                                ),
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: selected,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<Data> loadTeeth(String asset) async {
    final xml = await rootBundle.loadString(asset);

    final doc = XmlDocument.parse(xml);
    final viewBox = doc.rootElement.getAttribute('viewBox')!.split(' ');
    final w = double.parse(viewBox[2]);
    final h = double.parse(viewBox[3]);

    final teeth = doc.rootElement.findAllElements('path');
    return (
    size: Size(w, h),
    teeth: <int, Tooth>{
      for (final tooth in teeth)
        int.parse(tooth.getAttribute('id')!): Tooth(parseSvgPathData(tooth.getAttribute('d')!)),
    },
    );
  }
}

class Tooth {
  Tooth(Path originalPath) {
    rect = originalPath.getBounds();
    path = originalPath.shift(-rect.topLeft);
  }

  late final Path path;
  late final Rect rect;
  bool selected = false;
}

class ToothBorder extends ShapeBorder {
  final Path path;

  const ToothBorder(this.path);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return path.shift(rect.topLeft);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return path.shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black54;
    canvas.drawPath(path.shift(rect.topLeft), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}



String adultIdToString(int id) {
  if (id < 0 || id > 36) {
    return ''; // Return empty string for teeth outside the range 1-36
  }
  final number = id ;
  return 'Tooth #$number';
}
/*String adultIdToString(int id) {
  final (up, left, number) = switch (id) {
    < 8 => (true, false, 8 - id),
    < 16 => (true, true, id - 8 + 1),
    < 24 => (false, true, 24 - id),
    _ => (false, false, id - 24 + 1),
  };
  return '${up ? 'up' : 'down'} ${left ? 'left' : 'right'} #$number';
}
*/
String childIdToString(int id) {
  final (up, left, number) = switch (id) {
    < 6 => (true, false, 6 - id),
    < 12 => (true, true, id - 6 + 1),
    < 18 => (false, true, 18 - id),
    _ => (false, false, id - 18 + 1),
  };
  return '${up ? 'up' : 'down'} ${left ? 'left' : 'right'} #$number';
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wt_cal_machine/features/home/controller/home_controller.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final serialPortModel = Provider.of<HomeController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Gold Weight Machine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Port'),
              value: null,
              items: serialPortModel.availablePorts
                  .map((port) => DropdownMenuItem(
                value: port,
                child: Text(port),
              ))
                  .toList(),
              onChanged: (port) async {
                if (port != null) {
                  try {
                    await serialPortModel.connect(port, 9600);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connected to $port')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 20),
            Text('Received Data:'),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(serialPortModel.receivedData),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: serialPortModel.disconnect,
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}

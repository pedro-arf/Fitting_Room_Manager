import 'package:flutter/material.dart';
import 'package:fr_control/services/cloud/firestore_storage.dart';
import 'package:fr_control/utilities/timer_view.dart';

class ControlListView extends StatelessWidget {
  final Iterable<FirestoreTag> tags;

  const ControlListView({
    Key? key,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSizing = MediaQuery.of(context).size;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: tags.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final tag = tags.elementAt(index);
        return Column(
          children: [
            const SizedBox(
              height: 45,
            ),
            Text(
              tag.description,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("ID: ${tag.tagId}"),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: screenSizing.width,
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  tag.imgUrl,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Size: ${tag.size}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 60,
                ),
                Text("Price: ${tag.price.toStringAsFixed(2)}€",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            TimerView(
              timeCreated: tag.timeCreated,
              itemDescription: tag.description,
            ),
          ],
        );
      },
    );
  }
}

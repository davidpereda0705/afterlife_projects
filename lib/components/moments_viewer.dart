import 'package:afterlife_projects/services/moments_service.dart';
import 'package:afterlife_projects/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MomentsViewer extends StatelessWidget {
  final String nightId;
  final String nightName;

  const MomentsViewer({super.key, required this.nightId, required this.nightName});

  @override
  Widget build(BuildContext context) {
    final service = MomentsService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.getActiveMoments(nightId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }
        final moments = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AfterlifeColors.neonOrange, size: 16),
                const SizedBox(width: 6),
                const Text('MOMENTS', style: TextStyle(color: AfterlifeColors.neonOrange, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${moments.length}', style: const TextStyle(fontSize: 10)),
                  backgroundColor: AfterlifeColors.neonOrange.withValues(alpha: 0.15),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: moments.length,
                itemBuilder: (_, i) {
                  final moment = moments[i];
                  final imageUrl = moment['imageUrl'] as String?;
                  final hasImage = imageUrl != null && imageUrl.isNotEmpty;
                  final expires = moment['expiresAt'] as Timestamp?;
                  final timeLeft = expires != null
                      ? expires.toDate().difference(DateTime.now())
                      : const Duration(hours: 24);
                  final hoursLeft = timeLeft.inHours.clamp(0, 24);

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AfterlifeColors.neonOrange.withValues(alpha: 0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImage)
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              color: AfterlifeColors.electricPurple.withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  moment['text'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${hoursLeft}h', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

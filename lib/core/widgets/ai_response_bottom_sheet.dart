import 'package:flutter/material.dart';

class AIResponseBottomSheet {
  static void show(BuildContext context, String userQuestion) {
    // Mock AI responses based on common health questions
    String aiResponse;
    if (userQuestion.toLowerCase().contains('hamburger')) {
      aiResponse =
          '''Based on the health information you've provided, I can offer some general guidance about eating a hamburger:

While an occasional hamburger can be part of a balanced diet, there are a few considerations:

1. **Portion size matters**: A single regular-sized burger is preferable to oversized options.

2. **Consider your toppings**: Vegetables add nutrients, while excessive cheese, bacon, and mayo add calories and saturated fat.

3. **Bun choices**: Whole grain buns provide more fiber than white buns.

4. **Side dish choices**: Consider a side salad instead of fries for a healthier meal overall.

5. **Cooking method**: Grilled is generally healthier than fried.

If you have specific health conditions like heart disease, high cholesterol, or are on a weight management plan, you might want to limit red meat consumption.

Remember, moderation is key - an occasional hamburger is unlikely to cause harm in the context of an otherwise balanced diet.''';
    } else {
      // Generic response for other health questions
      aiResponse =
          '''Thank you for your health question. Based on general health guidelines:

1. Everyone's health needs are different, and what works for one person may not work for another.

2. It's important to maintain a balanced diet rich in fruits, vegetables, whole grains, lean proteins, and healthy fats.

3. Regular physical activity is recommended for most people.

4. Adequate sleep and stress management are crucial components of overall health.

5. For personalized health advice, it's always best to consult with a healthcare professional who knows your specific health history.

Would you like more information on any specific aspect of your health question?''';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar for dragging
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title with health icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Health AI Response',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // User question
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userQuestion,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Divider(color: Colors.grey[300], height: 24),
            // AI Response
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(
                          Icons.smart_toy,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          aiResponse,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This information is general guidance and not medical advice. For specific health concerns, please consult a healthcare professional.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

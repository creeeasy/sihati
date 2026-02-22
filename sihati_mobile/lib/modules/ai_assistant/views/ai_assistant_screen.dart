import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantScreen extends GetView<AIAssistantController> {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.psychology, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistant Santé AI', style: TextStyle(fontSize: 16)),
                Text(
                  'Propulsé par Gemini',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearChat,
            tooltip: 'Effacer la conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _MessageBubble(
                      message: message,
                      onMedicationTap: controller.searchMedication,
                    );
                  },
                )),
          ),

          // Loading indicator
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox();
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('L\'AI réfléchit...', style: AppTextStyles.caption),
                ],
              ),
            );
          }),

          // Quick suggestions (show when no messages yet)
          Obx(() {
            if (controller.messages.length > 1) return const SizedBox();
            return _QuickSuggestions(controller: controller);
          }),

          // Input field
          _InputField(controller: controller),
        ],
      ),
    );
  }
}

// ==================== MESSAGE BUBBLE ====================

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onMedicationTap;

  const _MessageBubble({
    required this.message,
    required this.onMedicationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar (left)
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.psychology, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: message.isUser
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          message.isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),

                // Medication suggestions
                if (message.medicationSuggestions != null &&
                    message.medicationSuggestions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.medicationSuggestions!.map((med) {
                      return ActionChip(
                        label: Text(med),
                        avatar: const Icon(Icons.medication, size: 16),
                        onPressed: () => onMedicationTap(med),
                        backgroundColor: AppColors.info.withOpacity(0.1),
                        side: const BorderSide(color: AppColors.info),
                      );
                    }).toList(),
                  ),
                ],

                // Timestamp
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // User avatar (right)
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== QUICK SUGGESTIONS ====================

class _QuickSuggestions extends StatelessWidget {
  final AIAssistantController controller;

  const _QuickSuggestions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggestions rapides:', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.quickSymptoms.map((symptom) {
              return ActionChip(
                label: Text(symptom),
                onPressed: () {
                  controller.textController.text = symptom;
                  controller.sendMessage();
                },
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ==================== INPUT FIELD ====================

class _InputField extends StatelessWidget {
  final AIAssistantController controller;

  const _InputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendMessage(),
              decoration: InputDecoration(
                hintText: 'Décrivez vos symptômes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => FloatingActionButton(
                mini: true,
                onPressed:
                    controller.isLoading.value ? null : controller.sendMessage,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
              )),
        ],
      ),
    );
  }
}

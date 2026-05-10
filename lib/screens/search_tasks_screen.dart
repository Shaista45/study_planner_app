import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_study_planner/models/models.dart';
import 'package:smart_study_planner/state/app_state.dart';
import 'package:smart_study_planner/theme/app_colors.dart';
import 'package:smart_study_planner/screens/edit_task_screen.dart';

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({super.key});

  @override
  State<SearchTasksScreen> createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();

    // Uses the search method we built in AppState
    final List<StudyTask> searchResults = appState.searchTasks(_searchQuery);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.deepBrown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search Tasks',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepBrown,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by task title',
                    hintStyle: TextStyle(
                      color: AppColors.deepBrown.withValues(alpha: 0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.deepBrown,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Results List
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks found.',
                        style: TextStyle(
                          color: AppColors.deepBrown.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: searchResults.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 16,
                      ), // Reduced gap for cleaner list
                      itemBuilder: (context, index) {
                        final task = searchResults[index];
                        final subjectName = appState.subjectName(
                          task.subjectId,
                        );

                        // MAGIC: We split the Title and the Description back apart!
                        String displayTitle = task.title;
                        String displayDesc = '';
                        if (task.title.contains(' - ')) {
                          final parts = task.title.split(' - ');
                          displayTitle = parts.first;
                          displayDesc = parts.sublist(1).join(' - ');
                        }

                        return InkWell(
                          onTap: () {
                            appState.setSelectedTask(task.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditTaskScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Clean Title
                                      Text(
                                        displayTitle,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.deepBrown,
                                        ),
                                      ),

                                      // Beautiful Description Box (Only shows if description exists)
                                      if (displayDesc.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryYellow
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: const Border(
                                              left: BorderSide(
                                                color: AppColors.accentOrange,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            displayDesc,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.deepBrown
                                                  .withValues(alpha: 0.8),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 12),

                                      // Themed Subject Badge
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.menu_book_rounded,
                                            size: 14,
                                            color: AppColors.primaryOlive,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            subjectName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryOlive,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Neat themed arrow pointing to the Edit screen
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOlive.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppColors.primaryOlive,
                                    size: 14,
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
        ),
      ),
    );
  }
}

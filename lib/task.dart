import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_project/login.dart';

/*取得任務資料(今日任務)*/
class Task {
  final String title;
  final String Name;
  final String content;
  final String stime;
  final String otime;
  final String score;

  Task({required this.title,required this.Name, required this.content,required this.stime,required this.otime,required this.score});
}
Future<List<Task>> fetchTasks() async {
  List<Task> tasks = [];

  try {
    DateTime now = DateTime.now();
    var Days = now.add(const Duration(hours: 0));
    String formattedDate = "${Days.year.toString()}${(Days.month).toString().padLeft(2, '0')}${Days.day.toString().padLeft(2, '0')}";

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('學校')
        .doc(studentSchool)
        .collection('教師')
        .doc(teacherName)
        .collection('任務')
        .get();

    querySnapshot.docs.forEach((doc) {
      String name = doc.id; // 文件的名稱
      if (name.startsWith(studentClass) && name.substring(3, 11) == formattedDate) {
        String content = doc['內容'];
        String taskTitle = name.split('-')[1];
        String Stime=doc['開始時間'];
        String otime=doc['結束時間'];
        String score=doc['積分'];
        Task task = Task(title: '任務 $taskTitle', content: content,Name: name,stime: Stime,otime: otime,score: score);
        tasks.add(task);
      }
    });

    return tasks;
  } catch (e) {
    // 處理錯誤
    print('Error fetching tasks: $e');
    tasks.add(Task(title: 'Error', content: 'Failed to fetch tasks',Name: 'Unknown',stime:'Unknown',otime: 'Unknown',score: 'Unknown' ));
    return tasks;
  }
}
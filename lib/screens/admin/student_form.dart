import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';

class StudentForm extends StatefulWidget {
  final Student? student;
  const StudentForm({super.key, this.student});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController nisC;
  late TextEditingController kelasC;
  late TextEditingController jurusanC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.student?.nama);
    emailC = TextEditingController(text: widget.student?.email);
    nisC = TextEditingController(text: widget.student?.nis);
    kelasC = TextEditingController(text: widget.student?.kelas);
    jurusanC = TextEditingController(text: widget.student?.jurusan);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.student == null ? "Tambah Siswa" : "Edit Siswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: nameC, decoration: const InputDecoration(labelText: "Nama")),
            TextFormField(controller: emailC, decoration: const InputDecoration(labelText: "Email")),
            TextFormField(controller: nisC, decoration: const InputDecoration(labelText: "NIS")),
            TextFormField(controller: kelasC, decoration: const InputDecoration(labelText: "Kelas")),
            TextFormField(controller: jurusanC, decoration: const InputDecoration(labelText: "Jurusan")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                final student = Student(
                  id: widget.student?.id ?? '',
                  nama: nameC.text,
                  email: emailC.text,
                  nis: nisC.text,
                  kelas: kelasC.text,
                  jurusan: jurusanC.text,
                );

                if (widget.student == null) {
                  provider.addStudent(student);
                } else {
                  provider.updateStudent(student);
                }

                Navigator.pop(context);
              },
              child: Text(widget.student == null ? "Simpan" : "Update"),
            ),
          ]),
        ),
      ),
    );
  }
}
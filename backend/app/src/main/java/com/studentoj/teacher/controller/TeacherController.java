package com.studentoj.teacher.controller;

import com.studentoj.common.auth.RequireRole;
import com.studentoj.common.auth.Role;
import com.studentoj.teacher.dto.ClassGroupResponse;
import com.studentoj.teacher.dto.ExportRequest;
import com.studentoj.teacher.dto.GroupRequest;
import com.studentoj.teacher.dto.StudentCreateRequest;
import com.studentoj.teacher.dto.StudentResponse;
import com.studentoj.teacher.dto.StudentUpdateRequest;
import com.studentoj.teacher.dto.TeacherAccountResponse;
import com.studentoj.teacher.dto.TeacherCreateRequest;
import com.studentoj.teacher.service.TeacherService;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/teacher")
@RequireRole(Role.TEACHER)
public class TeacherController {
    private final TeacherService teacherService;

    public TeacherController(TeacherService teacherService) {
        this.teacherService = teacherService;
    }

    @GetMapping("/students")
    public List<StudentResponse> students() {
        return teacherService.students();
    }

    @PostMapping("/students")
    public Map<String, Object> createStudent(@RequestBody StudentCreateRequest request) {
        teacherService.createStudent(request);
        return Map.of("created", true);
    }

    @PutMapping("/students/{id}")
    public void updateStudent(@PathVariable("id") Long id, @RequestBody StudentUpdateRequest request) {
        teacherService.updateStudent(id, request);
    }

    @PutMapping("/students/{id}/status")
    public void updateStudentStatus(@PathVariable("id") Long id, @RequestBody Map<String, String> body) {
        teacherService.updateStudentStatus(id, body == null ? null : body.get("status"));
    }

    @PostMapping("/students/{id}/reset-password")
    public Map<String, Object> resetStudentPassword(@PathVariable("id") Long id, @RequestBody(required = false) Map<String, String> body) {
        String newPassword = body == null ? null : body.get("newPassword");
        teacherService.resetStudentPassword(id, newPassword);
        return Map.of("reset", true);
    }

    @GetMapping("/teachers")
    public List<TeacherAccountResponse> teachers() {
        return teacherService.teachers();
    }

    @PostMapping("/teachers")
    public Map<String, Object> createTeacher(@RequestBody TeacherCreateRequest request) {
        teacherService.createTeacher(request);
        return Map.of("created", true);
    }

    @PutMapping("/teachers/{id}/status")
    public void updateTeacherStatus(@PathVariable("id") Long id, @RequestBody Map<String, String> body) {
        teacherService.updateTeacherStatus(id, body == null ? null : body.get("status"));
    }

    @PostMapping("/teachers/{id}/reset-password")
    public Map<String, Object> resetTeacherPassword(@PathVariable("id") Long id, @RequestBody(required = false) Map<String, String> body) {
        String newPassword = body == null ? null : body.get("newPassword");
        teacherService.resetTeacherPassword(id, newPassword);
        return Map.of("reset", true);
    }

    @GetMapping("/groups")
    public List<ClassGroupResponse> groups() {
        return teacherService.groups();
    }

    @PostMapping("/grades/export")
    public ResponseEntity<byte[]> exportGrades(@RequestBody ExportRequest request) {
        byte[] bytes = teacherService.exportGrades(request);
        boolean csv = TeacherService.isCsv(request == null ? null : request.format());
        String filename = csv ? "student-grades.csv" : "student-grades.xlsx";
        MediaType contentType = csv
                ? new MediaType("text", "csv", java.nio.charset.StandardCharsets.UTF_8)
                : MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        return ResponseEntity.ok()
                .contentType(contentType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .body(bytes);
    }

    @GetMapping(value = "/grades/export/student/{studentId}")
    public ResponseEntity<byte[]> exportStudentGrades(@PathVariable("studentId") Long studentId, @RequestParam(defaultValue = "xlsx") String format) {
        byte[] bytes = teacherService.exportStudentGrades(studentId, format);
        boolean csv = TeacherService.isCsv(format);
        MediaType contentType = csv ? new MediaType("text", "csv", java.nio.charset.StandardCharsets.UTF_8) : MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        return ResponseEntity.ok().contentType(contentType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=student-grades." + (csv ? "csv" : "xlsx"))
                .body(bytes);
    }

    @PostMapping("/groups")
    public void createGroup(@RequestBody GroupRequest request) {
        teacherService.createGroup(request);
    }

    @PutMapping("/groups/{id}")
    public void updateGroup(@PathVariable("id") Long id, @RequestBody GroupRequest request) {
        teacherService.updateGroup(id, request);
    }

    @DeleteMapping("/groups/{id}")
    public void deleteGroup(@PathVariable("id") Long id) {
        teacherService.deleteGroup(id);
    }

    @GetMapping("/groups/{id}/members")
    public List<StudentResponse> getGroupMembers(@PathVariable("id") Long id) {
        return teacherService.getGroupMembers(id);
    }

    @PostMapping("/groups/{id}/members")
    public void addGroupMembers(@PathVariable("id") Long id, @RequestBody List<Long> studentIds) {
        teacherService.addGroupMembers(id, studentIds);
    }

    @DeleteMapping("/groups/{id}/members")
    public void removeGroupMembers(@PathVariable("id") Long id, @RequestBody List<Long> studentIds) {
        teacherService.removeGroupMembers(id, studentIds);
    }

    @GetMapping(value = "/students/template", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportStudentTemplate() {
        byte[] bytes = teacherService.exportStudentTemplate();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=student-template.xlsx")
                .body(bytes);
    }

    @PostMapping("/students/import")
    public Map<String, Object> importStudents(@RequestParam("file") MultipartFile file) {
        return teacherService.importStudents(file);
    }

    @GetMapping(value = "/groups/{id}/members/export", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportGroupMembers(@PathVariable("id") Long id) {
        byte[] bytes = teacherService.exportGroupMembers(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=group-members.xlsx")
                .body(bytes);
    }

    @PostMapping("/groups/{id}/members/import")
    public Map<String, Object> importGroupMembers(@PathVariable("id") Long id, @RequestParam("file") MultipartFile file) {
        return teacherService.importGroupMembers(id, file);
    }
}

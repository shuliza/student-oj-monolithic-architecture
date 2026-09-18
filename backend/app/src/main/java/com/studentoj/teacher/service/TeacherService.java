package com.studentoj.teacher.service;

import com.studentoj.auth.service.TokenStore;
import com.studentoj.teacher.dto.ClassGroupResponse;
import com.studentoj.teacher.dto.ExportRequest;
import com.studentoj.teacher.dto.GroupRequest;
import com.studentoj.teacher.dto.StudentCreateRequest;
import com.studentoj.teacher.dto.StudentResponse;
import com.studentoj.teacher.dto.StudentUpdateRequest;
import com.studentoj.teacher.dto.TeacherAccountResponse;
import com.studentoj.teacher.dto.TeacherCreateRequest;
import com.studentoj.teacher.mapper.TeacherMapper;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@Service
public class TeacherService {

    private static final Logger log = LoggerFactory.getLogger(TeacherService.class);

    private final TeacherMapper teacherMapper;
    private final TokenStore tokenStore;

    public TeacherService(TeacherMapper teacherMapper, TokenStore tokenStore) {
        this.teacherMapper = teacherMapper;
        this.tokenStore = tokenStore;
    }

    public List<StudentResponse> students() {
        try {
            return teacherMapper.selectStudents().stream().map(this::toStudent).toList();
        } catch (Exception e) {
            log.warn("Failed to load students from DB: {}", e.getMessage());
            return List.of();
        }
    }

    public List<ClassGroupResponse> groups() {
        try {
            return teacherMapper.selectGroups().stream().map(this::toGroup).toList();
        } catch (Exception e) {
            log.warn("Failed to load groups from DB: {}", e.getMessage());
            return List.of();
        }
    }

    public void createStudent(StudentCreateRequest request) {
        if (request == null || request.username() == null || request.username().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "账号不能为空");
        }
        if (request.realName() == null || request.realName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "姓名不能为空");
        }
        String password = (request.password() == null || request.password().isBlank()) ? "123456" : request.password().trim();
        if (password.length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "密码长度至少 6 位");
        }
        Long groupId = null;
        if (request.groupName() != null && !request.groupName().isBlank()) {
            groupId = teacherMapper.selectGroupIdByName(request.groupName().trim());
            if (groupId == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "分组不存在：" + request.groupName());
            }
        }
        try {
            teacherMapper.insertStudent(
                    request.username().trim(),
                    new BCryptPasswordEncoder().encode(password),
                    request.realName().trim(),
                    request.studentNo() == null ? "" : request.studentNo().trim(),
                    groupId
            );
        } catch (Exception e) {
            log.warn("Failed to create student {}: {}", request.username(), e.getMessage());
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "学生账号或学号已存在");
        }
    }

    public void updateStudent(Long id, StudentUpdateRequest request) {
        if (id == null || teacherMapper.selectStudentId(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "学生不存在");
        }
        if (request == null || request.realName() == null || request.realName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "姓名不能为空");
        }
        Long groupId = null;
        if (request.groupName() != null && !request.groupName().isBlank()) {
            groupId = teacherMapper.selectGroupIdByName(request.groupName().trim());
            if (groupId == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "分组不存在：" + request.groupName());
            }
        }
        teacherMapper.updateStudent(id, request.realName().trim(),
                request.studentNo() == null ? "" : request.studentNo().trim(), groupId);
    }

    @Transactional
    public void updateStudentStatus(Long id, String status) {
        if (id == null || teacherMapper.selectStudentId(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "学生不存在");
        }
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!"ACTIVE".equals(normalized) && !"DISABLED".equals(normalized)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "状态值非法");
        }
        int updated = teacherMapper.updateStudentStatus(id, normalized);
        if (updated != 1) throw new ResponseStatusException(HttpStatus.CONFLICT, "学生状态已变化，请重试");
        if ("DISABLED".equals(normalized)) {
            tokenStore.revokeUser(id);
        }
    }

    @Transactional
    public void resetStudentPassword(Long id, String newPassword) {
        if (id == null || teacherMapper.selectStudentId(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "学生不存在");
        }
        String pwd = (newPassword == null || newPassword.isBlank()) ? "123456" : newPassword.trim();
        if (pwd.length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "密码长度至少 6 位");
        }
        int updated = teacherMapper.updateStudentPassword(id, new BCryptPasswordEncoder().encode(pwd));
        if (updated != 1) throw new ResponseStatusException(HttpStatus.CONFLICT, "学生密码已变化，请重试");
        tokenStore.revokeUser(id);
    }

    // ===== 教师账号管理 =====

    public List<TeacherAccountResponse> teachers() {
        try {
            return teacherMapper.selectTeachers().stream().map(this::toTeacher).toList();
        } catch (Exception e) {
            log.warn("Failed to load teachers from DB: {}", e.getMessage());
            return List.of();
        }
    }

    public void createTeacher(TeacherCreateRequest request) {
        if (request == null || request.username() == null || request.username().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "账号不能为空");
        }
        if (request.realName() == null || request.realName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "姓名不能为空");
        }
        String username = request.username().trim();
        if (teacherMapper.countByUsername(username) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "账号已存在：" + username);
        }
        String password = (request.password() == null || request.password().isBlank()) ? "123456" : request.password().trim();
        if (password.length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "密码长度至少 6 位");
        }
        String email = request.email() == null ? "" : request.email().trim();
        try {
            teacherMapper.insertTeacher(
                    username,
                    new BCryptPasswordEncoder().encode(password),
                    request.realName().trim(),
                    email
            );
        } catch (Exception e) {
            log.warn("Failed to create teacher {}: {}", username, e.getMessage());
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "教师账号创建失败，账号可能已存在");
        }
    }

    @Transactional
    public void updateTeacherStatus(Long id, String status) {
        if (id == null || teacherMapper.selectTeacherId(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "教师不存在");
        }
        String normalized = status == null ? "" : status.trim().toUpperCase();
        if (!"ACTIVE".equals(normalized) && !"DISABLED".equals(normalized)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "状态值非法");
        }
        int updated = teacherMapper.updateTeacherStatus(id, normalized);
        if (updated != 1) throw new ResponseStatusException(HttpStatus.CONFLICT, "教师状态已变化，请重试");
        if ("DISABLED".equals(normalized)) {
            tokenStore.revokeUser(id);
        }
    }

    @Transactional
    public void resetTeacherPassword(Long id, String newPassword) {
        if (id == null || teacherMapper.selectTeacherId(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "教师不存在");
        }
        String pwd = (newPassword == null || newPassword.isBlank()) ? "123456" : newPassword.trim();
        if (pwd.length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "密码长度至少 6 位");
        }
        int updated = teacherMapper.updateTeacherPassword(id, new BCryptPasswordEncoder().encode(pwd));
        if (updated != 1) throw new ResponseStatusException(HttpStatus.CONFLICT, "教师密码已变化，请重试");
        tokenStore.revokeUser(id);
    }

    private TeacherAccountResponse toTeacher(Map<String, Object> row) {
        return new TeacherAccountResponse(
                ((Number) row.get("id")).longValue(),
                (String) row.get("username"),
                (String) row.get("realName"),
                (String) row.get("email"),
                (String) row.get("status")
        );
    }


    public byte[] exportGrades(ExportRequest request) {
        Long groupId = (request != null && request.groupId() != null && request.groupId() > 0) ? request.groupId() : null;
        String startDate = normalizeDate(request == null ? null : request.startDate());
        String endDate = normalizeDate(request == null ? null : request.endDate());
        List<Map<String, Object>> data = teacherMapper.selectGradeData(groupId, null, startDate, endDate);
        return isCsv(request == null ? null : request.format()) ? generateGradeCsv(data) : generateGradeExcel(data);
    }

    private static String normalizeDate(String value) {
        return (value == null || value.isBlank()) ? null : value.trim();
    }

    public static boolean isCsv(String format) {
        return format != null && "csv".equalsIgnoreCase(format.trim());
    }

    private static final String[] GRADE_COLS = {"学号", "姓名", "分组", "题目", "提交次数", "最高分", "通过状态"};

    private byte[] generateGradeCsv(List<Map<String, Object>> data) {
        StringBuilder sb = new StringBuilder();
        sb.append('﻿'); // UTF-8 BOM，确保 Excel 正确识别中文
        sb.append(String.join(",", GRADE_COLS)).append("\r\n");
        for (Map<String, Object> row : data) {
            int passed = row.get("passed") == null ? 0 : ((Number) row.get("passed")).intValue();
            int submitCount = row.get("submitCount") == null ? 0 : ((Number) row.get("submitCount")).intValue();
            int bestScore = row.get("bestScore") == null ? 0 : ((Number) row.get("bestScore")).intValue();
            sb.append(csvCell((String) row.getOrDefault("studentNo", ""))).append(',')
              .append(csvCell((String) row.getOrDefault("realName", ""))).append(',')
              .append(csvCell((String) row.getOrDefault("groupName", ""))).append(',')
              .append(csvCell((String) row.getOrDefault("problemTitle", ""))).append(',')
              .append(submitCount).append(',')
              .append(bestScore).append(',')
              .append(csvCell(passed == 1 ? "通过" : "未通过")).append("\r\n");
        }
        return sb.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);
    }

    private String csvCell(String value) {
        if (value == null) {
            return "";
        }
        if (!value.isEmpty() && "=+-@".indexOf(value.charAt(0)) >= 0) value = "'" + value;
        if (value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    public byte[] exportStudentGrades(Long studentId) { return exportStudentGrades(studentId, "xlsx"); }

    public byte[] exportStudentGrades(Long studentId, String format) {
        if (studentId == null || studentId <= 0) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "学生ID不能为空");
        List<Map<String, Object>> data = teacherMapper.selectGradeData(null, studentId, null, null);
        return isCsv(format) ? generateGradeCsv(data) : generateGradeExcel(data);
    }

    private byte[] generateGradeExcel(List<Map<String, Object>> data) {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("成绩导出");
            Row header = sheet.createRow(0);
            String[] cols = {"学号", "姓名", "分组", "题目", "提交次数", "最高分", "通过状态"};
            for (int i = 0; i < cols.length; i++) {
                header.createCell(i).setCellValue(cols[i]);
            }
            int rowIdx = 1;
            for (Map<String, Object> row : data) {
                Row r = sheet.createRow(rowIdx++);
                r.createCell(0).setCellValue((String) row.getOrDefault("studentNo", ""));
                r.createCell(1).setCellValue((String) row.getOrDefault("realName", ""));
                r.createCell(2).setCellValue((String) row.getOrDefault("groupName", ""));
                r.createCell(3).setCellValue((String) row.getOrDefault("problemTitle", ""));
                r.createCell(4).setCellValue(row.get("submitCount") == null ? 0 : ((Number) row.get("submitCount")).intValue());
                r.createCell(5).setCellValue(row.get("bestScore") == null ? 0 : ((Number) row.get("bestScore")).intValue());
                int passed = row.get("passed") == null ? 0 : ((Number) row.get("passed")).intValue();
                r.createCell(6).setCellValue(passed == 1 ? "通过" : "未通过");
            }
            for (int i = 0; i < cols.length; i++) {
                sheet.autoSizeColumn(i);
            }
            wb.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "导出失败");
        }
    }

    public void createGroup(GroupRequest request) {
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "分组名称不能为空");
        }
        teacherMapper.insertGroup(request.name().trim(),
                request.teacherName() == null ? "" : request.teacherName().trim(),
                request.description() == null ? "" : request.description().trim());
    }

    public void updateGroup(Long id, GroupRequest request) {
        if (id == null || teacherMapper.selectGroupById(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "分组名称不能为空");
        }
        teacherMapper.updateGroup(id, request.name().trim(),
                request.teacherName() == null ? "" : request.teacherName().trim(),
                request.description() == null ? "" : request.description().trim());
    }

    public void deleteGroup(Long id) {
        if (id == null || teacherMapper.selectGroupById(id) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        // Clear group_id for all students in this group
        List<Map<String, Object>> members = teacherMapper.selectGroupMembers(id);
        for (Map<String, Object> m : members) {
            teacherMapper.removeUserFromGroup(((Number) m.get("id")).longValue(), id);
        }
        teacherMapper.deleteGroup(id);
    }

    public List<StudentResponse> getGroupMembers(Long groupId) {
        if (groupId == null || teacherMapper.selectGroupById(groupId) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        return teacherMapper.selectGroupMembers(groupId).stream().map(this::toStudent).toList();
    }

    public void addGroupMembers(Long groupId, List<Long> studentIds) {
        if (groupId == null || teacherMapper.selectGroupById(groupId) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        if (studentIds == null) return;
        for (Long studentId : studentIds) {
            teacherMapper.assignUserToGroup(studentId, groupId);
        }
    }

    public void removeGroupMembers(Long groupId, List<Long> studentIds) {
        if (groupId == null || teacherMapper.selectGroupById(groupId) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        if (studentIds == null) return;
        for (Long studentId : studentIds) {
            teacherMapper.removeUserFromGroup(studentId, groupId);
        }
    }

    public byte[] exportStudentTemplate() {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("学生导入模板");
            Row header = sheet.createRow(0);
            String[] cols = {"学号", "姓名", "账号", "密码", "分组"};
            for (int i = 0; i < cols.length; i++) {
                header.createCell(i).setCellValue(cols[i]);
            }
            // Example row
            Row example = sheet.createRow(1);
            example.createCell(0).setCellValue("20260001");
            example.createCell(1).setCellValue("张三");
            example.createCell(2).setCellValue("zhangsan");
            example.createCell(3).setCellValue("123456");
            example.createCell(4).setCellValue("数据库 1 班");
            for (int i = 0; i < cols.length; i++) {
                sheet.autoSizeColumn(i);
            }
            wb.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "生成模板失败");
        }
    }

    @Transactional
    public Map<String, Object> importStudents(MultipartFile file) {
        validateImportFile(file);
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        int imported = 0, skipped = 0, failed = 0;
        List<Map<String, Object>> errors = new java.util.ArrayList<>();
        java.util.Set<String> usernames = new java.util.HashSet<>();
        java.util.Set<String> studentNos = new java.util.HashSet<>();
        try (InputStream is = file.getInputStream(); Workbook wb = new XSSFWorkbook(is)) {
            Sheet sheet = wb.getSheetAt(0);
            if (sheet.getLastRowNum() > 5000) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "行数超过 5000 限制");
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null || row.getPhysicalNumberOfCells() == 0) { skipped++; continue; }
                int line = i + 1;
                String studentNo = getCellStr(row.getCell(0));
                String realName = getCellStr(row.getCell(1));
                String username = getCellStr(row.getCell(2));
                String password = getCellStr(row.getCell(3));
                String groupName = getCellStr(row.getCell(4));
                String error = null;
                if (username.isEmpty()) error = "账号不能为空";
                else if (realName.isEmpty()) error = "姓名不能为空";
                else if (password.isEmpty()) error = "密码不能为空";
                else if (password.length() < 6) error = "密码长度至少 6 位";
                else if (!usernames.add(username) || teacherMapper.countByUsername(username) > 0) error = "账号重复或已存在";
                else if (!studentNo.isEmpty() && (!studentNos.add(studentNo) || teacherMapper.countByStudentNo(studentNo) > 0)) error = "学号重复或已存在";
                Long groupId = null;
                if (error == null && !groupName.isEmpty()) { groupId = teacherMapper.selectGroupIdByName(groupName); if (groupId == null) error = "分组不存在：" + groupName; }
                if (error != null) { failed++; errors.add(Map.of("row", line, "message", error)); continue; }
                try { teacherMapper.insertStudent(username, encoder.encode(password), realName, studentNo, groupId); imported++; }
                catch (Exception e) { failed++; errors.add(Map.of("row", line, "message", "账号或学号已存在")); }
            }
        } catch (IOException e) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "文件解析失败"); }
        return Map.of("imported", imported, "skipped", skipped, "failed", failed, "errors", errors);
    }

    private void validateImportFile(MultipartFile file) {
        if (file == null || file.isEmpty()) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "请上传文件");
        String name = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase(java.util.Locale.ROOT);
        if (!name.endsWith(".xlsx")) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "仅支持 xlsx 文件");
        if (file.getSize() > 10 * 1024 * 1024) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "文件大小不能超过 10MB");
    }

    public byte[] exportGroupMembers(Long groupId) {
        if (groupId == null || teacherMapper.selectGroupById(groupId) == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        }
        List<Map<String, Object>> members = teacherMapper.selectGroupMembers(groupId);
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("分组成员");
            Row header = sheet.createRow(0);
            String[] cols = {"学号", "姓名", "账号", "状态"};
            for (int i = 0; i < cols.length; i++) {
                header.createCell(i).setCellValue(cols[i]);
            }
            int rowIdx = 1;
            for (Map<String, Object> m : members) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue((String) m.getOrDefault("studentNo", ""));
                row.createCell(1).setCellValue((String) m.getOrDefault("realName", ""));
                row.createCell(2).setCellValue((String) m.getOrDefault("username", ""));
                row.createCell(3).setCellValue((String) m.getOrDefault("status", ""));
            }
            for (int i = 0; i < cols.length; i++) {
                sheet.autoSizeColumn(i);
            }
            wb.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "导出失败");
        }
    }

    @Transactional
    public Map<String, Object> importGroupMembers(Long groupId, MultipartFile file) {
        if (groupId == null || teacherMapper.selectGroupById(groupId) == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "分组不存在");
        validateImportFile(file);
        int imported = 0, skipped = 0, failed = 0;
        List<Map<String, Object>> errors = new java.util.ArrayList<>();
        try (InputStream is = file.getInputStream(); Workbook wb = new XSSFWorkbook(is)) {
            Sheet sheet = wb.getSheetAt(0);
            if (sheet.getLastRowNum() > 5000) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "行数超过 5000 限制");
            List<Map<String, Object>> allStudents = teacherMapper.selectStudents();
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null || row.getPhysicalNumberOfCells() == 0) { skipped++; continue; }
                String studentNo = getCellStr(row.getCell(0));
                if (studentNo.isEmpty()) { failed++; errors.add(Map.of("row", i + 1, "message", "学号不能为空")); continue; }
                Long userId = null;
                for (Map<String, Object> s : allStudents) if (studentNo.equals(s.get("studentNo"))) { userId = ((Number) s.get("id")).longValue(); break; }
                if (userId == null) { failed++; errors.add(Map.of("row", i + 1, "message", "学号不存在")); continue; }
                if (teacherMapper.assignUserToGroup(userId, groupId) > 0) imported++;
                else { failed++; errors.add(Map.of("row", i + 1, "message", "成员更新失败")); }
            }
        } catch (IOException e) { throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "文件解析失败"); }
        return Map.of("imported", imported, "skipped", skipped, "failed", failed, "errors", errors);
    }

    private String getCellStr(Cell cell) {
        if (cell == null) return "";
        if (cell.getCellType() == CellType.STRING) return cell.getStringCellValue().trim();
        if (cell.getCellType() == CellType.NUMERIC) return String.valueOf((long) cell.getNumericCellValue());
        return "";
    }

    private StudentResponse toStudent(Map<String, Object> row) {
        return new StudentResponse(
                ((Number) row.get("id")).longValue(),
                (String) row.get("username"),
                (String) row.get("studentNo"),
                (String) row.get("realName"),
                (String) row.get("groupName"),
                (String) row.get("status")
        );
    }

    private ClassGroupResponse toGroup(Map<String, Object> row) {
        Object count = row.get("studentCount");
        return new ClassGroupResponse(
                ((Number) row.get("id")).longValue(),
                (String) row.get("name"),
                (String) row.get("teacherName"),
                count == null ? 0 : ((Number) count).intValue(),
                (String) row.get("description")
        );
    }
}

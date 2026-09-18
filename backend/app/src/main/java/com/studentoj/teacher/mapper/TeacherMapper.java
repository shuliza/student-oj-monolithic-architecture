package com.studentoj.teacher.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface TeacherMapper {

    @Select("SELECT u.id, u.username, u.student_no AS studentNo, u.real_name AS realName, u.status, g.name AS groupName " +
            "FROM user u LEFT JOIN class_group g ON g.id = u.group_id " +
            "WHERE u.role = 'STUDENT' ORDER BY u.id")
    List<Map<String, Object>> selectStudents();

    @Select("SELECT g.id, g.name, g.teacher_name AS teacherName, g.description, " +
            "(SELECT COUNT(*) FROM user u WHERE u.group_id = g.id AND u.role = 'STUDENT') AS studentCount " +
            "FROM class_group g ORDER BY g.id")
    List<Map<String, Object>> selectGroups();

    @Select("SELECT u.id, u.username, u.student_no AS studentNo, u.real_name AS realName, u.status " +
            "FROM user u WHERE u.group_id = #{groupId} AND u.role = 'STUDENT' ORDER BY u.student_no")
    List<Map<String, Object>> selectGroupMembers(@Param("groupId") Long groupId);

    @Update("UPDATE user SET group_id = #{groupId} WHERE id = #{userId} AND role = 'STUDENT'")
    int assignUserToGroup(@Param("userId") Long userId, @Param("groupId") Long groupId);

    @Update("UPDATE user SET group_id = NULL WHERE id = #{userId} AND group_id = #{groupId} AND role = 'STUDENT'")
    int removeUserFromGroup(@Param("userId") Long userId, @Param("groupId") Long groupId);

    @Insert("INSERT INTO class_group(name, teacher_name, description) VALUES(#{name}, #{teacherName}, #{description})")
    int insertGroup(@Param("name") String name, @Param("teacherName") String teacherName, @Param("description") String description);

    @Update("UPDATE class_group SET name = #{name}, teacher_name = #{teacherName}, description = #{description} WHERE id = #{id}")
    int updateGroup(@Param("id") Long id, @Param("name") String name, @Param("teacherName") String teacherName, @Param("description") String description);

    @Delete("DELETE FROM class_group WHERE id = #{id}")
    int deleteGroup(@Param("id") Long id);

    @Select("SELECT id FROM class_group WHERE id = #{id}")
    Long selectGroupById(@Param("id") Long id);

    @Select("SELECT id FROM class_group WHERE name = #{name}")
    Long selectGroupIdByName(@Param("name") String name);

    @Select("SELECT id FROM user WHERE id = #{id} AND role = 'STUDENT'")
    Long selectStudentId(@Param("id") Long id);

    @Update("UPDATE user SET real_name = #{realName}, student_no = #{studentNo}, group_id = #{groupId} " +
            "WHERE id = #{id} AND role = 'STUDENT'")
    int updateStudent(@Param("id") Long id, @Param("realName") String realName,
                      @Param("studentNo") String studentNo, @Param("groupId") Long groupId);

    @Update("UPDATE user SET status = #{status}, session_version = session_version + 1 WHERE id = #{id} AND role = 'STUDENT'")
    int updateStudentStatus(@Param("id") Long id, @Param("status") String status);

    @Update("UPDATE user SET password_hash = #{passwordHash}, session_version = session_version + 1 WHERE id = #{id} AND role = 'STUDENT'")
    int updateStudentPassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);

    @Insert("INSERT INTO user(username, password_hash, real_name, student_no, group_id, role, status) " +
            "VALUES(#{username}, #{passwordHash}, #{realName}, #{studentNo}, #{groupId}, 'STUDENT', 'ACTIVE')")
    int insertStudent(@Param("username") String username, @Param("passwordHash") String passwordHash,
                      @Param("realName") String realName, @Param("studentNo") String studentNo,
                      @Param("groupId") Long groupId);

    // ===== 教师账号管理 =====

    @Select("SELECT u.id, u.username, u.real_name AS realName, u.email, u.status " +
            "FROM user u WHERE u.role = 'TEACHER' ORDER BY u.id")
    List<Map<String, Object>> selectTeachers();

    @Select("SELECT COUNT(*) FROM user WHERE username = #{username}")
    int countByUsername(@Param("username") String username);

    @Select("SELECT COUNT(*) FROM user WHERE student_no = #{studentNo} AND student_no <> ''")
    int countByStudentNo(@Param("studentNo") String studentNo);

    @Select("SELECT id FROM user WHERE student_no = #{studentNo} AND role = 'STUDENT' LIMIT 1")
    Long selectStudentIdByStudentNo(@Param("studentNo") String studentNo);

    @Insert("INSERT INTO user(username, password_hash, real_name, email, student_no, role, status) " +
            "VALUES(#{username}, #{passwordHash}, #{realName}, #{email}, '', 'TEACHER', 'ACTIVE')")
    int insertTeacher(@Param("username") String username, @Param("passwordHash") String passwordHash,
                      @Param("realName") String realName, @Param("email") String email);

    @Select("SELECT id FROM user WHERE id = #{id} AND role = 'TEACHER'")
    Long selectTeacherId(@Param("id") Long id);

    @Update("UPDATE user SET status = #{status}, session_version = session_version + 1 WHERE id = #{id} AND role = 'TEACHER'")
    int updateTeacherStatus(@Param("id") Long id, @Param("status") String status);

    @Update("UPDATE user SET password_hash = #{passwordHash}, session_version = session_version + 1 WHERE id = #{id} AND role = 'TEACHER'")
    int updateTeacherPassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);


    @Select("""
            SELECT u.student_no AS studentNo, u.real_name AS realName, g.name AS groupName,
                   p.title AS problemTitle,
                   COUNT(s.id) AS submitCount,
                   MAX(s.score) AS bestScore,
                   MAX(CASE WHEN s.status = 'ACCEPTED' THEN 1 ELSE 0 END) AS passed
            FROM user u
            LEFT JOIN class_group g ON g.id = u.group_id
            CROSS JOIN problem p
            LEFT JOIN submission s ON s.user_id = u.id AND s.problem_id = p.id
              AND (#{startDate} IS NULL OR DATE(s.submitted_at) >= #{startDate})
              AND (#{endDate} IS NULL OR DATE(s.submitted_at) <= #{endDate})
            WHERE u.role = 'STUDENT' AND p.status = 1
              AND (#{groupId} IS NULL OR u.group_id = #{groupId})
              AND (#{studentId} IS NULL OR u.id = #{studentId})
            GROUP BY u.id, u.student_no, u.real_name, g.name, p.id, p.title
            ORDER BY u.student_no, p.id
            """)
    List<Map<String, Object>> selectGradeData(@Param("groupId") Long groupId, @Param("studentId") Long studentId,
                                              @Param("startDate") String startDate, @Param("endDate") String endDate);
}

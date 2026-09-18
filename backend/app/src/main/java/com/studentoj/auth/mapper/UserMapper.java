package com.studentoj.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studentoj.auth.entity.UserEntity;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface UserMapper extends BaseMapper<UserEntity> {

    @Select("SELECT name FROM class_group WHERE id = #{groupId}")
    String selectGroupName(@Param("groupId") Long groupId);

    @org.apache.ibatis.annotations.Update("UPDATE user SET real_name = #{realName}, email = #{email}, session_version = session_version + 1 WHERE id = #{id} AND session_version = #{version} AND status = 'ACTIVE'")
    int updateProfileFields(@Param("id") Long id, @Param("realName") String realName, @Param("email") String email, @Param("version") Integer version);

    @org.apache.ibatis.annotations.Update("UPDATE user SET password_hash = #{passwordHash}, session_version = session_version + 1 WHERE id = #{id} AND session_version = #{version} AND status = 'ACTIVE'")
    int updatePassword(@Param("id") Long id, @Param("passwordHash") String passwordHash, @Param("version") Integer version);

    @org.apache.ibatis.annotations.Select("SELECT session_version FROM user WHERE id = #{id}")
    Integer selectSessionVersion(@Param("id") Long id);

    @org.apache.ibatis.annotations.Select("SELECT * FROM user WHERE id = #{id} FOR UPDATE")
    UserEntity selectByIdForUpdate(@Param("id") Long id);
}

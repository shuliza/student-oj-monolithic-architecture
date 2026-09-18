package com.studentoj.teacher.service;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.studentoj.auth.service.TokenStore;
import com.studentoj.teacher.mapper.TeacherMapper;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

class TeacherServiceTests {
    @Test
    void disablingStudentRevokesSession() {
        TeacherMapper mapper = mock(TeacherMapper.class);
        TokenStore tokens = mock(TokenStore.class);
        when(mapper.selectStudentId(7L)).thenReturn(7L);
        when(mapper.updateStudentStatus(7L, "DISABLED")).thenReturn(1);
        TeacherService service = new TeacherService(mapper, tokens);

        service.updateStudentStatus(7L, "disabled");

        verify(mapper).updateStudentStatus(7L, "DISABLED");
        verify(tokens).revokeUser(7L);
    }

    @Test
    void resettingTeacherPasswordRevokesSession() {
        TeacherMapper mapper = mock(TeacherMapper.class);
        TokenStore tokens = mock(TokenStore.class);
        when(mapper.selectTeacherId(9L)).thenReturn(9L);
        when(mapper.updateTeacherPassword(org.mockito.ArgumentMatchers.eq(9L), org.mockito.ArgumentMatchers.anyString())).thenReturn(1);
        TeacherService service = new TeacherService(mapper, tokens);

        service.resetTeacherPassword(9L, "new-password");

        verify(tokens).revokeUser(9L);
    }

    @Test
    void disablingStudentDoesNotRevokeSessionWhenUpdateMisses() {
        TeacherMapper mapper = mock(TeacherMapper.class);
        TokenStore tokens = mock(TokenStore.class);
        when(mapper.selectStudentId(7L)).thenReturn(7L);
        when(mapper.updateStudentStatus(7L, "DISABLED")).thenReturn(0);
        TeacherService service = new TeacherService(mapper, tokens);

        assertThrows(ResponseStatusException.class, () -> service.updateStudentStatus(7L, "disabled"));

        verifyNoInteractions(tokens);
    }

    @Test
    void resettingTeacherPasswordDoesNotRevokeSessionWhenUpdateMisses() {
        TeacherMapper mapper = mock(TeacherMapper.class);
        TokenStore tokens = mock(TokenStore.class);
        when(mapper.selectTeacherId(9L)).thenReturn(9L);
        when(mapper.updateTeacherPassword(org.mockito.ArgumentMatchers.eq(9L), org.mockito.ArgumentMatchers.anyString())).thenReturn(0);
        TeacherService service = new TeacherService(mapper, tokens);

        assertThrows(ResponseStatusException.class, () -> service.resetTeacherPassword(9L, "new-password"));

        verifyNoInteractions(tokens);
    }
}

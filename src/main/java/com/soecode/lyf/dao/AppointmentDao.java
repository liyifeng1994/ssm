package com.soecode.lyf.dao;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;

import com.soecode.lyf.entity.Appointment;
import org.apache.ibatis.annotations.ResultType;
import org.apache.ibatis.annotations.Select;
import org.springframework.stereotype.Component;

public interface AppointmentDao {

    /**
     * 插入预约图书记录
     *
     * @param bookId
     * @param studentId
     * @return 插入的行数
     */
    @Insert("INSERT ignore INTO appointment (book_id, student_id) " +
            " VALUES (#{bookId}, #{studentId})")
    int insertAppointment(@Param("bookId") long bookId, @Param("studentId") long studentId);

    /**
     * 通过主键查询预约图书记录，并且携带图书实体
     *
     * @param bookId
     * @param studentId
     * @return
     */
    @Select("SELECT " +
            " a.book_id, a.student_id, a.appoint_time, " +
            " b.book_id \"book.book_id\", b.`name` \"book.name\", b.number \"book.number\"" +
            " FROM appointment a " +
            " INNER JOIN book b ON a.book_id = b.book_id " +
            " WHERE a.book_id = #{bookId} " +
            " AND a.student_id = #{studentId}")
    @ResultType(Appointment.class)
    Appointment queryByKeyWithBook(@Param("bookId") long bookId, @Param("studentId") long studentId);

}

drop table student;

CREATE TABLE Student (
    student_name VARCHAR(50),
    marks_maths INT,
    marks_english INT,
    marks_hindi INT
);


INSERT INTO Student (student_name, marks_maths, marks_english, marks_hindi) VALUES ('Gita', 90, 80, 55);
INSERT INTO Student (student_name, marks_maths, marks_english, marks_hindi) VALUES ('Hari', 70, 85, 65);
INSERT INTO Student (student_name, marks_maths, marks_english, marks_hindi) VALUES ('Rama', 50, 45, 60);
INSERT INTO Student (student_name, marks_maths, marks_english, marks_hindi) VALUES ('New Student', 50, 50, NULL);

select student_name, (COALESCE(marks_maths, 0) + COALESCE(marks_english, 0), COALESCE(marks_hindi, 0)) as total_marks from Student;

select student_name, (marks_maths + marks_english+marks_hindi) as total from Student;

SELECT 
    student_name, 
    COALESCE(marks_maths, 0) + COALESCE(marks_english, 0) + COALESCE(marks_hindi, 0) AS total 
FROM Student
ORDER BY total DESC;

SELECT 
    student_name, 
    -- Total Column
    (COALESCE(marks_maths, 0) + COALESCE(marks_english, 0) + COALESCE(marks_hindi, 0)) AS total_marks,
    -- Average Column
    (COALESCE(marks_maths, 0) + COALESCE(marks_english, 0) + COALESCE(marks_hindi, 0)) / 3.0 AS average_marks
FROM Student
ORDER BY total_marks DESC;


SELECT 
    student_name, 
    -- Total Column
    (COALESCE(marks_maths, 0) + COALESCE(marks_english, 0) + COALESCE(marks_hindi, 0)) AS total_marks,
    -- Average Column
    ROUND((COALESCE(marks_maths, 0) + COALESCE(marks_english, 0) + COALESCE(marks_hindi, 0)) / 3.0, 2) AS average_marks
FROM Student
ORDER BY total_marks DESC;


-- Create Tables
CREATE TABLE Students (student_id INT, name VARCHAR(50), age INT);
CREATE TABLE Courses (course_id INT, title VARCHAR(100));
CREATE TABLE Enrollments (enrollment_id INT, student_id INT, course_id INT);

-- Insert Data
INSERT INTO Students VALUES (1, 'Amy', 21), (2, 'Clive', 19), (3, 'Simon', 17), (4, 'Jason', 17), (5, 'Karen', 21), (6, 'Lina', 17);
INSERT INTO Courses VALUES (101, 'Computer Science'), (102, 'Psychology'), (103, 'Textile Diploma');
INSERT INTO Enrollments VALUES (1, 1, 101), (2, 2, 102), (3, 3, 101), (4, 4, 102), (5, 5, 101), (6, 6, 102);

SELECT 
    Final.course_id, 
    Final.title, 
    Round(AVG(Final.age)*1.0, 2) AS average_age
FROM (
    -- Outer Join: Connecting the Course/Enrollment mix to Students
    SELECT 
        A.course_id, 
        A.title, 
        S.age 
    FROM (
        -- Inner Join: Connecting Courses to Enrollments
        SELECT 
            C.course_id, 
            C.title, 
            E.student_id 
        FROM Courses C
        JOIN Enrollments E ON C.course_id = E.course_id
    ) A
    JOIN Students S ON A.student_id = S.student_id
) Final
GROUP BY Final.course_id, Final.title
ORDER BY Final.title DESC; 



# 经典sql练习：学生-老师-课程-成绩

### 建表：

```sql
-- 建表语句
# 学生表
CREATE TABLE Student(sid VARCHAR(10),sname VARCHAR(10),sage DATETIME,ssex NVARCHAR(10));
INSERT INTO Student VALUES('01' , '赵雷' , '1990-01-01' , '男');
INSERT INTO Student VALUES('02' , '钱电' , '1990-12-21' , '男');
INSERT INTO Student VALUES('03' , '孙风' , '1990-05-20' , '男');
INSERT INTO Student VALUES('04' , '李云' , '1990-08-06' , '男');
INSERT INTO Student VALUES('05' , '周梅' , '1991-12-01' , '女');
INSERT INTO Student VALUES('06' , '吴兰' , '1992-03-01' , '女');
INSERT INTO Student VALUES('07' , '郑竹' , '1989-07-01' , '女');
INSERT INTO Student VALUES('08' , '王菊' , '1990-01-20' , '女');

#课程表
CREATE TABLE Course(cid VARCHAR(10),cname VARCHAR(10),tid VARCHAR(10));
INSERT INTO Course VALUES('01' , '语文' , '02');
INSERT INTO Course VALUES('02' , '数学' , '01');
INSERT INTO Course VALUES('03' , '英语' , '03');

# 教师表
CREATE TABLE Teacher(tid VARCHAR(10),tname VARCHAR(10));
INSERT INTO Teacher VALUES('01' , '张三');
INSERT INTO Teacher VALUES('02' , '李四');
INSERT INTO Teacher VALUES('03' , '王五');

# 成绩表
CREATE TABLE SC(sid VARCHAR(10),cid VARCHAR(10),score DECIMAL(18,1));
INSERT INTO SC VALUES('01' , '01' , 80);
INSERT INTO SC VALUES('01' , '02' , 90);
INSERT INTO SC VALUES('01' , '03' , 99);
INSERT INTO SC VALUES('02' , '01' , 70);
INSERT INTO SC VALUES('02' , '02' , 60);
INSERT INTO SC VALUES('02' , '03' , 80);
INSERT INTO SC VALUES('03' , '01' , 80);
INSERT INTO SC VALUES('03' , '02' , 80);
INSERT INTO SC VALUES('03' , '03' , 80);
INSERT INTO SC VALUES('04' , '01' , 50);
INSERT INTO SC VALUES('04' , '02' , 30);
INSERT INTO SC VALUES('04' , '03' , 20);
INSERT INTO SC VALUES('05' , '01' , 76);
INSERT INTO SC VALUES('05' , '02' , 87);
INSERT INTO SC VALUES('06' , '01' , 31);
INSERT INTO SC VALUES('06' , '03' , 34);
INSERT INTO SC VALUES('07' , '02' , 89);
INSERT INTO SC VALUES('07' , '03' , 98);
```

### 心得：

- 多表查询
  1. 采用“问题拆分法”，把大问题细分为小问题，最后把小问题结合在一起就可以解决大问题。由于每个小问题可以是一次查询，所以结合小问题的过程实际上
     就是多表关联的过程

### 题目：

#### Q1：查询"01"课程比"02"课程成绩高的学生的信息及课程分数

```sql
-- Q1：查询"01"课程比"02"课程成绩高的学生的信息及课程分数
/*思路：
1. 要查询的表：SC，Student这两张表
2. 表连接条件（多个表时）：sid
3. 问题拆分：
   （1）怎么查找学生的两个课程(01和02)的成绩呢？
   SELECT sid, score AS class1 FROM sc WHERE sc.`cid` = '01';
   SELECT sid, score AS class2 FROM sc WHERE sc.`cid` = '02';
   
   （2）怎么在（1）的基础上查到到课程01和课程02成绩高的 所属学生id 及 其两门课程成绩呢？
   SELECT t1.sid, class1, class2 FROM 
	(SELECT sid, score AS class1 FROM sc WHERE sc.`cid` = '01') t1,
	(SELECT sid, score AS class2 FROM sc WHERE sc.`cid` = '02') t2 
   WHERE t1.sid = t2.sid AND class1 > class2
   
   （3）现在我们已经有了课程01比课程02成绩高的学生id了，怎么查到题目要求的“学生信息及课程分数”？--> 把（2）和学生表join起来！
   
*/
SELECT s1.*, class1, class2 FROM student s1 INNER JOIN 
(SELECT t1.sid, class1, class2 FROM 
	(SELECT sid, score AS class1 FROM sc WHERE sc.`cid` = '01') t1,
	(SELECT sid, score AS class2 FROM sc WHERE sc.`cid` = '02') t2 
WHERE t1.sid = t2.sid AND class1 > class2
) t4 -- 子查询别名
ON s1.sid = t4.sid

```


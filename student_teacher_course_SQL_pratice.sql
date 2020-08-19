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


-- =========================================================================================================
/* 多表查询心得体会：
1. 采用“问题拆分法”，把大问题细分为小问题，最后把小问题结合在一起就可以解决大问题。由于每个小问题可以是一次查询，所以结合小问题的过程实际上
   就是多表关联的过程
*/

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



-- Q2：查询学生选择"01"课程但可能不选择"02"的学生及课程的情况(不存在时显示为 null )
/* 思路：
1. 要查询的表：学生表和成绩表
2. 表连接条件（多个表时）：sid
3. 问题拆分：
   （1）先查询出学生两个课程01和02的课程情况
   SELECT sid, cid AS cid1, score AS class1 FROM sc WHERE cid = '01')
   SELECT sid, cid AS cid2, score AS class2 FROM sc WHERE cid = '02') t2
   
   （2）题目要求选择01可能不选择02（显示为null），故采用左连接
   SELECT t1.sid, cid1, class1, cid2, class2 FROM
   (SELECT sid, cid AS cid1, score AS class1 FROM sc WHERE cid = '01') t1 
   LEFT JOIN
   (SELECT sid, cid AS cid2, score AS class2 FROM sc WHERE cid = '02') t2 
   ON t1.sid = t2.sid 
   
   （3）因为要查询出“学生”及“课程”情况，故再连接student表，如下：
*/
SELECT t4.*, cid1, class1, cid2, class2 FROM student t4 INNER JOIN 
(SELECT t1.sid, cid1, class1, cid2, class2 FROM
(SELECT sid, cid AS cid1, score AS class1 FROM sc WHERE cid = '01') t1 LEFT JOIN
(SELECT sid, cid AS cid2, score AS class2 FROM sc WHERE cid = '02') t2 ON t1.sid = t2.sid ) t3 
ON t3.sid = t4.sid


-- Q3：查询学生选择"01"课程且同时选择"02"课程的学生及课程的情况
/* 思路：
1. 要查询的表：学生表和成绩表
2. 表关联条件：sid
3. 问题拆分：
   （1）查询出01和02的课程情况
   （2）题目要求同时选择01和02课程，故采用内连接
*/
SELECT t4.*, cid1, class1, cid2, class2 FROM student t4 INNER JOIN 
(SELECT t1.sid, cid1, class1, cid2, class2 FROM 
(SELECT sid, cid AS cid1, score AS class1 FROM sc WHERE cid = '01') t1 INNER JOIN 
(SELECT sid, cid AS cid2, score AS class2 FROM sc WHERE cid = '02') t2 ON t1.sid = t2.sid
) t3 
ON t4.sid = t3.sid;

-- Q4：查询学生选择"01"课程但不选择"02"的学生及课程的情况 【大坑！！！！！！！！！！！！！！！！！！！！！！！！！！！！】
/*
1. 要查询的表：学生表，成绩表
2. 表关联条件：sid
3. 问题拆分：
   （1）找出选择了01但是没有选择02的学生sid
   （2）
   # 本题警惕掉入 “!=” 的陷阱，如下是错误的，因为cid!='02'时cid可能等于01和03，这时候01重复了，子查询 查出来的结果就有多余的了
SELECT t4.*, cid1, class1, cid2, class2 FROM student t4 INNER JOIN 
(SELECT t1.sid, cid1, class1, cid2, class2 FROM 
(SELECT sid, cid AS cid1, score AS class1 FROM sc WHERE cid = '01') t1 INNER JOIN 
(SELECT sid, cid AS cid2, score AS class2 FROM sc WHERE cid != '02') t2 ON t1.sid = t2.sid
) t3 
ON t4.sid = t3.sid
*/
# 如下这种写法，可以排除只要存在02课程，那么其所属的sid就要被排除，这样就可以排除掉多余的选择了01并且选择了02/03的了
SELECT t1.*, t2.cid, t2.score FROM student t1 INNER JOIN
(SELECT * FROM sc s1 WHERE s1.`sid` NOT IN (SELECT s2.sid FROM sc s2 WHERE s2.cid = '02') AND s1.`cid` = '01') t2
ON t1.`sid` = t2.sid;

-- Q5：查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
/* 思路：
1. 要查询的表：学生表、成绩表
2. 表连接条件：sid
3. 问题拆分：
   （1）平均成绩，那么得在查询成绩表时使用分组+avg函数
   （2）把（1）的查询结果和（2）连接起来	
*/
-- 答案1，使用隐式内连接
SELECT t1.sid, t1.sname, t2.avgScore FROM student t1,
(SELECT sid, AVG(score) AS avgScore FROM sc GROUP BY sid HAVING AVG(score)>= 60) t2
WHERE t1.`sid`=t2.`sid`;
-- 答案2，使用显示内连接
SELECT s.sid,sname,AVG(sc.score)
FROM student AS s INNER JOIN sc
ON s.sid = sc.sid 
GROUP BY sc.sid
HAVING AVG(sc.score) >= 60;

-- Q6：查询在 SC 表存在成绩的学生信息
/*思路：
简单，本期主要在 distinct知识点
*/
-- 我的答案
SELECT DISTINCT s1.* FROM student s1 INNER JOIN sc s2 ON s1.`sid` = s2.`sid`  AND EXISTS(SELECT score FROM sc WHERE sid = s1.`sid`);
-- 标准答案：
SELECT DISTINCT student.*
FROM sc,student
WHERE student.sid = sc.sid ;

-- Q7：查询所有同学的学生编号、学生姓名、选课总数、所有课程的成绩总和
/*思路：
1. 涉及的表：学生表和成绩表
2. 表关联条件：sid
3. 问题拆分：
   （1）先查询出每个学生的选课总数（由于是每个学生，所以对sid对成绩表采用分组group by）
   （2）先查询出每个学生的课程成绩总和（由于是每个学生，所以对sid对成绩表采用分组group by）
   （3）把学生表数据和（1）和（2）连接起来，大功告成
   P.s：sql写出来之后，观察（1）和（2）发现大致相同，可以进行合并优化，减少一次表连接
*/
-- 我的答案，臃肿，为啥要用两个group by 呢？按照思路些sql是没错，但是在写完sql之后要看看有没有可以优化的地方！！！
SELECT t1.`sid`, t1.`sname`, t2.sum, t3.count FROM student t1,
(SELECT s2.`sid`, SUM(s2.score) AS `sum` FROM sc s2 GROUP BY s2.sid) t2,
(SELECT s3.`sid`, COUNT(s3.cid) AS `count` FROM sc s3 GROUP BY s3.sid) t3
WHERE t1.sid = t2.sid AND t2.`sid` = t3.sid; 


-- Q8：查询「李」姓老师的数量
/*思路：
1. 查询的表：教师表
2. 表关联条件：无
*/
SELECT COUNT(1) AS `count` FROM teacher WHERE tname LIKE '李%';

-- Q9：查询学过「张三」老师授课的同学的信息
/*思路：
1. 涉及的表：学生表、课程表、成绩表、 教师表
2. 表连接条件：sid，tid
3. 问题拆分：
   （1）张三老师授过的课
   SELECT cid FROM course c WHERE c.`tid` = (SELECT t.`tid` FROM teacher t WHERE t.`tname` = '张三');
   （2）学（1）的课的学生的sid
   SELECT DISTINCT s1.`sid` FROM sc s1 WHERE s1.`cid` IN (
       SELECT cid FROM course c WHERE c.`tid` = (SELECT t.`tid` FROM teacher t WHERE t.`tname` = '张三')
   );
   （3）对（1）和（2）和学生表进行连接
*/
SELECT * FROM student s2 WHERE s2.`sid` IN (
       SELECT DISTINCT s1.`sid` FROM sc s1 WHERE s1.`cid` IN (
	      SELECT cid FROM course c WHERE c.`tid` = (SELECT t.`tid` FROM teacher t WHERE t.`tname` = '张三')
       )
); 


-- Q10：查询没有学全所有课程的同学的信息
/* 思路：
1. 涉及的表：学生表，成绩表，课程表
2. 表连接条件：cid，tid
3. 问题步骤拆分：
   （1）先找出所有的课程的Id
   SELECT COUNT(DISTINCT s1.cid) FROM sc s1;
   （2）找出没有学全（这里的“学全”我理解的是至少学了一门，另一种理解是可以一个课程都不学，此时应该删去这个条件：COUNT(s2.cid)>=1）
   SELECT s2.`sid` FROM sc s2 GROUP BY sid HAVING COUNT(s2.cid)>=1 AND COUNT(s2.cid) < (SELECT COUNT(DISTINCT s1.cid) FROM sc s1);
*/

SELECT * FROM student s1, (
	SELECT s2.`sid` FROM sc s2 GROUP BY sid HAVING COUNT(s2.cid)>=1 AND COUNT(s2.cid) < (SELECT COUNT(DISTINCT s1.cid) FROM sc s1)
	) t1 WHERE s1.sid = t1.sid;
	
-- 如果是第二种理解，那么补充  NOT IN 写法：
SELECT * FROM student s1 WHERE s1.`sid` NOT IN (
	SELECT s2.`sid` FROM sc s2 GROUP BY sid HAVING COUNT(s2.cid)>=1 AND COUNT(s2.cid) < (SELECT COUNT(DISTINCT s1.cid) FROM sc s1)
	) ;


-- Q11：查询至少有一门课与学号为"01"的同学所学相同的同学的信息
/*思路
1. 涉及的表：成绩表，学生表，
2. 表连接关系：sid
3. 问题拆分：
（1）查询学号为“01”的同学所学过的课程
SELECT s1.`cid` FROM sc s1 WHERE s1.`sid`='01';
（2）对（1）使用 IN，找出sid
SELECT DISTINCT s2.`sid` FROM sc s2 WHERE s2.`cid` IN(SELECT s1.`cid` FROM sc s1 WHERE s1.`sid`='01') AND s2.`sid` != '01';
*/
SELECT * FROM student s3 WHERE s3.`sid` IN (
	SELECT DISTINCT s2.`sid` FROM sc s2 
		WHERE s2.`cid` IN(
			SELECT s1.`cid` FROM sc s1 WHERE s1.`sid`='01') 
		AND s2.`sid` != '01'
);








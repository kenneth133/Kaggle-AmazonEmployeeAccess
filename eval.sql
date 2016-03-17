/*
Kenneth Lee
July 29, 2013
*/
alter table #train drop column role_title
go
alter table #test drop column role_title
go
alter table #test add action bit
go
alter table #test add act0_score float
alter table #test add act1_score float
go
alter table #test add mgr_id_0 float
alter table #test add mgr_id_1 float
alter table #test add role_rollup_1_0 float
alter table #test add role_rollup_1_1 float
alter table #test add role_rollup_2_0 float
alter table #test add role_rollup_2_1 float
alter table #test add role_deptname_0 float
alter table #test add role_deptname_1 float
alter table #test add role_family_desc_0 float
alter table #test add role_family_desc_1 float
alter table #test add role_family_0 float
alter table #test add role_family_1 float
alter table #test add role_code_0 float
alter table #test add role_code_1 float
go
create clustered index IX_train on #train (resource)
create clustered index IX_test on #test (id)
go
create table #alt_mgr_r (
  mgr_id1	int	not null,
  mgr_id2	int	not null,
  num		int	not null
)
go
insert #alt_mgr_r
select t1.mgr_id, t2.mgr_id, count(*)
  from #train t1, #train t2
 where t1.role_rollup_1 = t2.role_rollup_1
   and t1.role_rollup_2 = t2.role_rollup_2
   and t1.role_deptname = t2.role_deptname
   and t1.role_family_desc = t2.role_family_desc
   and t1.role_family = t2.role_family
   and t1.role_code = t2.role_code
   and t1.mgr_id != t2.mgr_id
 group by t1.mgr_id, t2.mgr_id
go
create nonclustered index IX_alt_mgr_r1 on #alt_mgr_r (mgr_id1)
create nonclustered index IX_alt_mgr_r2 on #alt_mgr_r (mgr_id2)
go
create table #alt_mgr_s (
  mgr_id1	int	not null,
  mgr_id2	int	not null,
  num		int	not null
)
go
insert #alt_mgr_s
select t1.mgr_id, t2.mgr_id, count(*)
  from #test t1, #test t2
 where t1.role_rollup_1 = t2.role_rollup_1
   and t1.role_rollup_2 = t2.role_rollup_2
   and t1.role_deptname = t2.role_deptname
   and t1.role_family_desc = t2.role_family_desc
   and t1.role_family = t2.role_family
   and t1.role_code = t2.role_code
   and t1.mgr_id != t2.mgr_id
 group by t1.mgr_id, t2.mgr_id
go
create nonclustered index IX_alt_mgr_s1 on #alt_mgr_s (mgr_id1)
create nonclustered index IX_alt_mgr_s2 on #alt_mgr_s (mgr_id2)
go
create table #alt_mgr (
  mgr_id_r	int	not null,
  mgr_id_s	int	not null,
  num		int	not null
)
go
insert #alt_mgr
select r.mgr_id, s.mgr_id, count(*)
  from #train r, #test s
 where r.role_rollup_1 = s.role_rollup_1
   and r.role_rollup_2 = s.role_rollup_2
   and r.role_deptname = s.role_deptname
   and r.role_family_desc = s.role_family_desc
   and r.role_family = s.role_family
   and r.role_code = s.role_code
   and r.mgr_id != s.mgr_id
 group by r.mgr_id, s.mgr_id
go
create nonclustered index IX_alt_mgr1 on #alt_mgr (mgr_id_r)
create nonclustered index IX_alt_mgr2 on #alt_mgr (mgr_id_s)
go
create table #alt_desc_r (
  desc1	int	not null,
  desc2	int	not null,
  num	int	not null
)
go
insert #alt_desc_r
select t1.role_family_desc, t2.role_family_desc, count(*)
  from #train t1, #train t2
 where t1.mgr_id = t2.mgr_id
   and t1.role_rollup_1 = t2.role_rollup_1
   and t1.role_rollup_2 = t2.role_rollup_2
   and t1.role_deptname = t2.role_deptname
   and t1.role_family = t2.role_family
   and t1.role_code = t2.role_code
   and t1.role_family_desc != t2.role_family_desc
 group by t1.role_family_desc, t2.role_family_desc
go
create nonclustered index IX_alt_desc_r1 on #alt_desc_r (desc1)
create nonclustered index IX_alt_desc_r2 on #alt_desc_r (desc2)
go
create table #alt_desc_s (
  desc1	int	not null,
  desc2	int	not null,
  num	int	not null
)
go
insert #alt_desc_s
select t1.role_family_desc, t2.role_family_desc, count(*)
  from #test t1, #test t2
 where t1.mgr_id = t2.mgr_id
   and t1.role_rollup_1 = t2.role_rollup_1
   and t1.role_rollup_2 = t2.role_rollup_2
   and t1.role_deptname = t2.role_deptname
   and t1.role_family = t2.role_family
   and t1.role_code = t2.role_code
   and t1.role_family_desc != t2.role_family_desc
 group by t1.role_family_desc, t2.role_family_desc
go
create nonclustered index IX_alt_desc_s1 on #alt_desc_s (desc1)
create nonclustered index IX_alt_desc_s2 on #alt_desc_s (desc2)
go
create table #alt_desc (
  desc_r	int	not null,
  desc_s	int	not null,
  num	int	not null
)
go
insert #alt_desc
select r.role_family_desc, s.role_family_desc, count(*)
  from #train r, #test s
 where r.mgr_id = s.mgr_id
   and r.role_rollup_1 = s.role_rollup_1
   and r.role_rollup_2 = s.role_rollup_2
   and r.role_deptname = s.role_deptname
   and r.role_family = s.role_family
   and r.role_code = s.role_code
   and r.role_family_desc != s.role_family_desc
 group by r.role_family_desc, s.role_family_desc
go
create nonclustered index IX_alt_desc1 on #alt_desc (desc_r)
create nonclustered index IX_alt_desc2 on #alt_desc (desc_s)
go

select * from #alt_mgr order by mgr_id_s, mgr_id_r
select * from #alt_desc
select top 10 * from #train
select top 10 * from #test

--**** EXECUTE BLOCK 1 ****--
DECLARE @ACT0_EXISTS bit, @ACT1_EXISTS bit
DECLARE @COUNT0 int, @COUNT1 int
DECLARE @ID int, @RESOURCE int

SELECT @ID = -100

WHILE EXISTS (SELECT 1 FROM #test WHERE id > @ID)
BEGIN
  SELECT @ID = MIN(id) FROM #test WHERE id > @ID
  SELECT @RESOURCE = resource FROM #test WHERE id = @ID

  SELECT @ACT0_EXISTS = 0
  SELECT @ACT1_EXISTS = 0

  IF EXISTS (SELECT 1 FROM #train WHERE resource = @RESOURCE AND action = 0)
    BEGIN SELECT @ACT0_EXISTS = 1 END
  IF EXISTS (SELECT 1 FROM #train WHERE resource = @RESOURCE AND action = 1)
    BEGIN SELECT @ACT1_EXISTS = 1 END

  IF @ACT0_EXISTS = 0 AND @ACT1_EXISTS = 0
  BEGIN--NOTHING EXISTS IN #train TO HELP US DETERMINE ACTION
    UPDATE #test
       SET mgr_id_0 = -1, mgr_id_1 = -1,
		role_rollup_1_0 = -1, role_rollup_1_1 = -1,
		role_rollup_2_0 = -1, role_rollup_2_1 = -1,
		role_deptname_0 = -1, role_deptname_1 = -1,
		role_family_desc_0 = -1, role_family_desc_1 = -1,
		role_family_0 = -1, role_family_1 = -1,
		role_code_0 = -1, role_code_1 = -1
     WHERE id = @ID
  END
  ELSE
  BEGIN
    /**** role_rollup_1 ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_rollup_1_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_rollup_1 IN (SELECT role_rollup_1 FROM #test WHERE id = @ID)
         AND action = 0

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_rollup_1_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_rollup_1_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_rollup_1_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_rollup_1 IN (SELECT role_rollup_1 FROM #test WHERE id = @ID)
         AND action = 1

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_rollup_1_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_rollup_1_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_rollup_1_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_rollup_1_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** role_rollup_2 ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_rollup_2_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_rollup_2 IN (SELECT role_rollup_2 FROM #test WHERE id = @ID)
         AND action = 0

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_rollup_2_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_rollup_2_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_rollup_2_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_rollup_2 IN (SELECT role_rollup_2 FROM #test WHERE id = @ID)
         AND action = 1

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_rollup_2_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_rollup_2_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_rollup_2_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_rollup_2_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** role_deptname ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_deptname_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_deptname IN (SELECT role_deptname FROM #test WHERE id = @ID)
         AND action = 0

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_deptname_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_deptname_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_deptname_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_deptname IN (SELECT role_deptname FROM #test WHERE id = @ID)
         AND action = 1

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_deptname_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_deptname_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_deptname_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_deptname_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** role_family_desc ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_family_desc_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_family_desc IN (SELECT role_family_desc FROM #test WHERE id = @ID)
         AND action = 0

      SELECT @COUNT0 = @COUNT0 + COUNT(*)
        FROM #train r, #test s, #alt_desc_r altr, #alt_desc_s alts, #alt_desc a
       WHERE r.resource = @RESOURCE AND r.action = 0
         AND s.id = @ID
         AND r.role_family_desc = altr.desc1 AND altr.desc2 = a.desc_r
         AND s.role_family_desc = alts.desc1 AND alts.desc2 = a.desc_s

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_family_desc_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_family_desc_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_family_desc_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_family_desc IN (SELECT role_family_desc FROM #test WHERE id = @ID)
         AND action = 1

      SELECT @COUNT1 = @COUNT1 + COUNT(*)
        FROM #train r, #test s, #alt_desc_r altr, #alt_desc_s alts, #alt_desc a
       WHERE r.resource = @RESOURCE AND r.action = 1
         AND s.id = @ID
         AND r.role_family_desc = altr.desc1 AND altr.desc2 = a.desc_r
         AND s.role_family_desc = alts.desc1 AND alts.desc2 = a.desc_s

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_family_desc_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_family_desc_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_family_desc_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_family_desc_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** role_family ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_family_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_family IN (SELECT role_family FROM #test WHERE id = @ID)
         AND action = 0

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_family_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_family_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_family_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_family IN (SELECT role_family FROM #test WHERE id = @ID)
         AND action = 1

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_family_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_family_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_family_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_family_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** role_code ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET role_code_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_code IN (SELECT role_code FROM #test WHERE id = @ID)
         AND action = 0

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET role_code_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_code_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET role_code_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND role_code IN (SELECT role_code FROM #test WHERE id = @ID)
         AND action = 1

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET role_code_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET role_code_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET role_code_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               role_code_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
    /**** mgr_id ****/
    SELECT @COUNT0 = 0
    SELECT @COUNT1 = 0

    IF @ACT0_EXISTS = 0
      BEGIN UPDATE #test SET mgr_id_0 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT0 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND mgr_id IN (SELECT mgr_id FROM #test WHERE id = @ID)
         AND action = 0

      SELECT @COUNT0 = @COUNT0 + COUNT(*)
        FROM #train r, #test s, #alt_mgr_r altr, #alt_mgr_s alts, #alt_mgr a
       WHERE r.resource = @RESOURCE AND r.action = 0
         AND s.id = @ID
         AND r.mgr_id = altr.mgr_id1 AND altr.mgr_id2 = a.mgr_id_r
         AND s.mgr_id = alts.mgr_id1 AND alts.mgr_id2 = a.mgr_id_s

      IF @COUNT0 = 0
        BEGIN UPDATE #test SET mgr_id_0 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET mgr_id_0 = 1 WHERE id = @ID END
    END

    IF @ACT1_EXISTS = 0
      BEGIN UPDATE #test SET mgr_id_1 = -1 WHERE id = @ID END
    ELSE
    BEGIN
      SELECT @COUNT1 = COUNT(*)
        FROM #train
       WHERE resource = @RESOURCE
         AND mgr_id IN (SELECT mgr_id FROM #test WHERE id = @ID)
         AND action = 1

      SELECT @COUNT1 = @COUNT1 + COUNT(*)
        FROM #train r, #test s, #alt_mgr_r altr, #alt_mgr_s alts, #alt_mgr a
       WHERE r.resource = @RESOURCE AND r.action = 1
         AND s.id = @ID
         AND r.mgr_id = altr.mgr_id1 AND altr.mgr_id2 = a.mgr_id_r
         AND s.mgr_id = alts.mgr_id1 AND alts.mgr_id2 = a.mgr_id_s

      IF @COUNT1 = 0
        BEGIN UPDATE #test SET mgr_id_1 = 0 WHERE id = @ID END
      ELSE
        BEGIN UPDATE #test SET mgr_id_1 = 1 WHERE id = @ID END
    END

    IF @ACT0_EXISTS = 1 AND @ACT1_EXISTS = 1
    BEGIN
      IF @COUNT0 > 0 AND @COUNT1 > 0
      BEGIN
        UPDATE #test
           SET mgr_id_0 = CONVERT(float,@COUNT0)/CONVERT(float,@COUNT0+@COUNT1),
               mgr_id_1 = CONVERT(float,@COUNT1)/CONVERT(float,@COUNT0+@COUNT1)
         WHERE id = @ID
      END
    END
  END
END

UPDATE #test
   SET act0_score = mgr_id_0 + role_rollup_1_0 + role_rollup_2_0 + role_deptname_0 + role_family_desc_0 + role_family_0 + role_code_0,
       act1_score = mgr_id_1 + role_rollup_1_1 + role_rollup_2_1 + role_deptname_1 + role_family_desc_1 + role_family_1 + role_code_1

UPDATE #test SET action = 1 WHERE act1_score >= 3.5
UPDATE #test SET action = 0 WHERE act0_score >= 3.5

UPDATE #test
   SET action = NULL
 WHERE act0_score = 3.5
   AND act1_score = 3.5

UPDATE #test
   SET action = 0
 WHERE act0_score >= 0 AND act0_score < 3.5
   AND act1_score >= 0 AND act1_score < 3.5
   AND act0_score > act1_score

UPDATE #test
   SET action = 1
 WHERE act0_score >= 0 AND act0_score < 3.5
   AND act1_score >= 0 AND act1_score < 3.5
   AND act1_score > act0_score

UPDATE #test
   SET action = 0
 WHERE act0_score < 0
   AND act1_score >= 0 AND act1_score < 3.5

UPDATE #test
   SET action = 1
 WHERE act1_score < 0
   AND act0_score >= 0 AND act0_score < 3.5

UPDATE #test SET action = 0 WHERE act0_score < 0 AND act1_score < 0

--**** EXECUTE BLOCK 2 ****--
DECLARE @COUNT_VAL int, @COUNT_A int
DECLARE @ID int, @RESOURCE int

SELECT @ID = 0

WHILE EXISTS (SELECT 1 FROM #test WHERE id > @ID AND action IS NULL)
BEGIN
  SELECT @ID = MIN(id) FROM #test WHERE id > @ID AND action IS NULL
  SELECT @RESOURCE = resource FROM #test WHERE id = @ID
  /******** ACTION = 0 ********/
  SELECT @COUNT_A = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND action = 0
  /**** role_rollup_1 ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_rollup_1 IN (SELECT role_rollup_1 FROM #test WHERE id = @ID)
     AND action = 0

  UPDATE #test SET role_rollup_1_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_rollup_2 ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_rollup_2 IN (SELECT role_rollup_2 FROM #test WHERE id = @ID)
     AND action = 0

  UPDATE #test SET role_rollup_2_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_deptname ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_deptname IN (SELECT role_deptname FROM #test WHERE id = @ID)
     AND action = 0

  UPDATE #test SET role_deptname_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_family_desc ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train r, #test s, #alt_desc_r altr, #alt_desc_s alts, #alt_desc a
   WHERE r.resource = @RESOURCE AND r.action = 0
     AND s.id = @ID
     AND r.role_family_desc = altr.desc1 AND altr.desc2 = a.desc_r
     AND s.role_family_desc = alts.desc1 AND alts.desc2 = a.desc_s

  UPDATE #test SET role_family_desc_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_family ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_family IN (SELECT role_family FROM #test WHERE id = @ID)
     AND action = 0

  UPDATE #test SET role_family_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_code ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_code IN (SELECT role_code FROM #test WHERE id = @ID)
     AND action = 0

  UPDATE #test SET role_code_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** mgr_id ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train r, #test s, #alt_mgr_r altr, #alt_mgr_s alts, #alt_mgr a
   WHERE r.resource = @RESOURCE AND r.action = 0
     AND s.id = @ID
     AND r.mgr_id = altr.mgr_id1 AND altr.mgr_id2 = a.mgr_id_r
     AND s.mgr_id = alts.mgr_id1 AND alts.mgr_id2 = a.mgr_id_s

  UPDATE #test SET mgr_id_0 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /******** ACTION = 1 ********/
  SELECT @COUNT_A = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND ACTION = 1
  /**** role_rollup_1 ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_rollup_1 IN (SELECT role_rollup_1 FROM #test WHERE id = @ID)
     AND action = 1

  UPDATE #test SET role_rollup_1_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_rollup_2 ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_rollup_2 IN (SELECT role_rollup_2 FROM #test WHERE id = @ID)
     AND action = 1

  UPDATE #test SET role_rollup_2_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_deptname ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_deptname IN (SELECT role_deptname FROM #test WHERE id = @ID)
     AND action = 1

  UPDATE #test SET role_deptname_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_family_desc ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train r, #test s, #alt_desc_r altr, #alt_desc_s alts, #alt_desc a
   WHERE r.resource = @RESOURCE AND r.action = 1
     AND s.id = @ID
     AND r.role_family_desc = altr.desc1 AND altr.desc2 = a.desc_r
     AND s.role_family_desc = alts.desc1 AND alts.desc2 = a.desc_s

  UPDATE #test SET role_family_desc_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_family ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_family IN (SELECT role_family FROM #test WHERE id = @ID)
     AND action = 1

  UPDATE #test SET role_family_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** role_code ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train
   WHERE resource = @RESOURCE
     AND role_code IN (SELECT role_code FROM #test WHERE id = @ID)
     AND action = 1

  UPDATE #test SET role_code_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
  /**** mgr_id ****/
  SELECT @COUNT_VAL = COUNT(*)
    FROM #train r, #test s, #alt_mgr_r altr, #alt_mgr_s alts, #alt_mgr a
   WHERE r.resource = @RESOURCE AND r.action = 1
     AND s.id = @ID
     AND r.mgr_id = altr.mgr_id1 AND altr.mgr_id2 = a.mgr_id_r
     AND s.mgr_id = alts.mgr_id1 AND alts.mgr_id2 = a.mgr_id_s

  UPDATE #test SET mgr_id_1 = CONVERT(float,@COUNT_VAL)/CONVERT(float,@COUNT_A) WHERE id = @ID
END

UPDATE #test
   SET act0_score = mgr_id_0 + role_rollup_1_0 + role_rollup_2_0 + role_deptname_0 + role_family_desc_0 + role_family_0 + role_code_0,
       act1_score = mgr_id_1 + role_rollup_1_1 + role_rollup_2_1 + role_deptname_1 + role_family_desc_1 + role_family_1 + role_code_1
 WHERE action IS NULL

UPDATE #test
   SET action = 0
 WHERE act0_score > act1_score
   AND action IS NULL

UPDATE #test
   SET action = 1
 WHERE act1_score > act0_score
   AND action IS NULL

UPDATE #test SET action = 0 WHERE act0_score = 0 AND act1_score = 0 AND action IS NULL

--**** EXECUTE BLOCK 3 ****--
UPDATE #test SET action = 1 WHERE id in (44517,22005,18732)

UPDATE #test SET action = 0 WHERE id in (6345,36520)

UPDATE #test SET action = 0 WHERE id = 22256
UPDATE #test SET action = 0 WHERE id = 40883

UPDATE #test SET action = 0 WHERE id = 3549
UPDATE #test SET action = 0 WHERE id = 32920

UPDATE #test SET action = 0 WHERE id = 23895

UPDATE #test SET action = 0 WHERE id in (6807,49874,50600,22485,39719,11978,53943)

UPDATE #test SET action = 0 WHERE id in (5717,40055,38463)

UPDATE #test SET action = 0 WHERE id in (40951,16611)

UPDATE #test SET action = 0 WHERE id = 21413

UPDATE #test SET action = 0 WHERE id = 13096

UPDATE #test SET action = 0 WHERE id in (42451,8853)

UPDATE #test SET action = 0 WHERE id = 51877

UPDATE #test SET action = 1 WHERE id in (40391,49751,51753)

UPDATE #test SET action = 0 WHERE id in (22991,50414)

UPDATE #test SET action = 0 WHERE id = 52209

UPDATE #test SET action = 1 WHERE id = 6325

UPDATE #test SET action = 0 WHERE id = 20939

UPDATE #test SET action = 1 WHERE id in (52441,14094)

UPDATE #test SET action = 1 WHERE id in (21808,34413)

UPDATE #test SET action = 0 WHERE id = 2629

UPDATE #test SET action = 0 WHERE id = 13165

UPDATE #test SET action = 0 WHERE id in (48762,38012,39079)

UPDATE #test SET action = 0 WHERE id = 57892

UPDATE #test SET action = 0 WHERE id = 7347

UPDATE #test SET action = 0 WHERE id = 22955

UPDATE #test SET action = 1 WHERE id = 28571

UPDATE #test SET action = 0 WHERE id in (4306,33287,18542)

UPDATE #test SET action = 0 WHERE id = 35632

UPDATE #test SET action = 1 WHERE id = 24139

UPDATE #test SET action = 0 WHERE id = 32056

UPDATE #test SET action = 0 WHERE id in (1502,49667)

UPDATE #test SET action = 0 WHERE id = 9183

/*
1	role_family
2	role_rollup_1
3	role_rollup_2
4	role_title
5	role_deptname
6	role_family_desc
7	mgr_id
*/
--go with percentage of action1 with the value vs % of action0
--but what to do with the 0's...
/*
select * from #test order by id --58921 rows

select id, action from #test order by id

select * from #test where role_rollup_1 = role_rollup_2
select * from #train where role_rollup_1 = role_rollup_2

select COUNT(*) from #test where action is not null
select COUNT(*) from #test where action is null
select COUNT(*) from #test where action =1
select COUNT(*) from #test where action =0
select * from #test where action is null ORDER BY resource, id
select * from #test where id = 51830
  --and mgr_id_0 > 0
 order by resource

select * from #test where action is null and act0_score != 0 order by act0_score desc
select * from #test where action is null and mgr_id_0 != 0

select * from #test where id = 2410
select * from #train where resource = 80778 order by action
select * from #test where resource = 80778 order by action
--select * from #test where role_family_desc = 309291 and mgr_id = 5240
select * from #alt_mgr where mgr_id_s in (25396,13881) and mgr_id_r in (23391, 278563)
select * from #alt_mgr_r where mgr_id1 in (3838,7398)
select * from #alt_mgr_s where mgr_id1 in (3838,7398)

select * from #test where role_family_desc = 290919 order by resource, id

select id, act0_score + act1_score as [act_sum]
  from #test
 order by [act_sum] desc

select act0_score + act1_score, count(*)
  from #test
 group by act0_score + act1_score
 order by act0_score + act1_score

select action, count(*)
  from #train
 group by action
 order by action
*/
/**** DROP TABLES - BEGIN ****
drop table #alt_desc_r
drop table #alt_desc_s
drop table #alt_desc

drop table #alt_mgr_r
drop table #alt_mgr_s
drop table #alt_mgr

drop table #train
drop table #test
go
**** DROP TABLES - END ****/

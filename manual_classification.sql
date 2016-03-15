/*
Kenneth Lee
July 26, 2013
*/
alter table #train drop column role_title
go
alter table #test drop column role_title
go
alter table #train add flag1 bit
alter table #train add flag2 bit
alter table #train add flag3 bit
alter table #train add flag4 bit
alter table #train add flag5 bit
alter table #train add flag6 bit
alter table #train add flag7 bit
alter table #train add flag8 bit
go
alter table #test add action bit
go
alter table #train add action1 bit
alter table #train add action2 bit
alter table #train add action3 bit
alter table #train add action4 bit
alter table #train add action5 bit
alter table #train add action6 bit
alter table #train add action7 bit
alter table #train add action8 bit
go
alter table #test add action1 bit
alter table #test add action2 bit
alter table #test add action3 bit
alter table #test add action4 bit
alter table #test add action5 bit
alter table #test add action6 bit
alter table #test add action7 bit
alter table #test add action8 bit
go
--alter table #test add alt_mgr_id int
--go
/*
select count(*) from #train --32769
select count(*) from #test --58921

select top 100 * from #train
select top 100 * from #test
*/
--STEP 1: DETERMINE ACTION USING resource, mgr_id, role_family_desc
update #train --77 rows
   set flag1 = 1
  from (select r.resource, r.mgr_id, r.role_family_desc, count(distinct r.action) as [colName]--38 rows
          from #train r
         group by r.resource, r.mgr_id, r.role_family_desc
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource
   and #train.mgr_id = x.mgr_id
   and #train.role_family_desc = x.role_family_desc
--select * from #train where flag1 = 1 order by mgr_id, role_family_desc, resource
update #test --updates only 5219 rows without alt_mgr_id
   set action1 = r.action
  from #train r
 where #test.resource = r.resource
   --and (#test.mgr_id = r.mgr_id or #test.alt_mgr_id = r.mgr_id)
   and #test.mgr_id = r.mgr_id
   and #test.role_family_desc = r.role_family_desc
   and r.flag1 is null
update r1 --32692 rows; only 77 rows exist in #train that are not resolved with this method
   set r1.action1 = r2.action
  from #train r1, #train r2
 where r1.resource = r2.resource
   and r1.mgr_id = r2.mgr_id
   and r1.role_family_desc = r2.role_family_desc
   and r2.flag1 is null
--STEP 2: DETERMINE ACTION USING ALL COLUMNS EXCEPT mgr_id
update #train --265 rows
   set flag2 = 1
  from (select r.resource, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family_desc, r.role_family, r.role_code,
               count(distinct r.action) as [colName]--93 rows
          from #train r
         group by r.resource, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family_desc, r.role_family, r.role_code
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource
   and #train.role_rollup_1 = x.role_rollup_1 and #train.role_rollup_2 = x.role_rollup_2
   and #train.role_deptname = x.role_deptname and #train.role_code = x.role_code
   and #train.role_family_desc = x.role_family_desc and #train.role_family = x.role_family
--select * from #train where flag2 = 1 order by resource, role_rollup_1, role_rollup_2, role_deptname, role_family_desc, role_family, role_code
update #test --9018 rows
   set action2 = r.action
  from #train r
 where #test.resource = r.resource
   and #test.role_rollup_1 = r.role_rollup_1 and #test.role_rollup_2 = r.role_rollup_2
   and #test.role_deptname = r.role_deptname and #test.role_code = r.role_code
   and #test.role_family_desc = r.role_family_desc and #test.role_family = r.role_family
   and r.flag2 is null
update r1 --32504 rows
   set r1.action2 = r2.action
  from #train r1, #train r2
 where r1.resource = r2.resource
   and r1.role_rollup_1 = r2.role_rollup_1 and r1.role_rollup_2 = r2.role_rollup_2
   and r1.role_deptname = r2.role_deptname and r1.role_code = r2.role_code
   and r1.role_family_desc = r2.role_family_desc and r1.role_family = r2.role_family
   and r2.flag2 is null
--AFTER STEP 2, WE HAVE ACTIONS FOR 13152 ROWS
--CREATE alt_mgr TABLE: BEGIN
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
--select * from #alt_mgr order by mgr_id_s, mgr_id_r
--CREATE alt_mgr TABLE: END
--STEP 3: USE ALT_MGR_IDs TO DETERMINE ACTION
update #train--505 rows
   set flag3 = 1
  from #alt_mgr a,
       (select s.resource, s.mgr_id, s.role_family_desc, count(distinct r.action) as [colName]--505 rows
          from #train r, #test s, #alt_mgr a
         where r.resource = s.resource
           and r.mgr_id = a.mgr_id_r
           and s.mgr_id = a.mgr_id_s
           and r.role_family_desc = s.role_family_desc
         group by s.resource, s.mgr_id, s.role_family_desc
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource
   and #train.mgr_id = a.mgr_id_r
   and x.mgr_id = a.mgr_id_s
   and #train.role_family_desc = x.role_family_desc
/*
select r.*, s.mgr_id
  from #train r, #test s, #alt_mgr a
 where r.flag3 is not null
   and r.resource = s.resource
   and r.mgr_id = a.mgr_id_r
   and s.mgr_id = a.mgr_id_s
   and r.role_family_desc = s.role_family_desc
 order by r.resource, s.role_family_desc, s.mgr_id
 
select * from #alt_mgr where mgr_id_s in (744, 8674)
*/
update #test--12683 rows
   set action3 = r.action
  from #train r, #alt_mgr a
 where #test.resource = r.resource
   and r.mgr_id = a.mgr_id_r
   and #test.mgr_id = a.mgr_id_s
   and #test.role_family_desc = r.role_family_desc
   and r.flag3 is null
/*
select * from #test
 where action1 is not null
    or action2 is not null
    or action3 is not null
    or action4 is not null
    or action5 is not null
    or action6 is not null
    or action7 is not null
    or action8 is not null */
--AFTER STEP 3, WE HAVE ACTIONS FOR 16248 ROWS
--STEP 4: use all columns except ROLE_FAMILY_DESC
update #train --72 rows
   set flag4 = 1
  from (select r.resource, r.mgr_id, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family, r.role_code,
               count(distinct r.action) as [colName]--35 rows
          from #train r
         group by r.resource, r.mgr_id, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family, r.role_code
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource and #train.mgr_id = x.mgr_id
   and #train.role_rollup_1 = x.role_rollup_1 and #train.role_rollup_2 = x.role_rollup_2
   and #train.role_deptname = x.role_deptname and #train.role_family = x.role_family
   and #train.role_code = x.role_code
update #test
   set action4 = r.action
  from #train r
 where #test.resource = r.resource and #test.mgr_id = r.mgr_id
   and #test.role_rollup_1 = r.role_rollup_1 and #test.role_rollup_2 = r.role_rollup_2
   and #test.role_deptname = r.role_deptname and #test.role_family = r.role_family
   and #test.role_code = r.role_code and flag4 is null
--AFTER STEP 4, WE HAVE ACTIONS FOR 19047 ROWS
--STEP 5: use all columns except ROLE_FAMILY_DESC but use alt_mgr_id's
update #train--373 rows
   set flag5 = 1
  from #alt_mgr a,
       (select s.resource, s.mgr_id, s.role_rollup_1, s.role_rollup_2, s.role_deptname, s.role_family, s.role_code,
               count(distinct r.action) as [colName]--419 rows
          from #train r, #test s, #alt_mgr a
         where r.resource = s.resource and r.mgr_id = a.mgr_id_r and s.mgr_id = a.mgr_id_s
           and r.role_rollup_1 = s.role_rollup_1 and r.role_rollup_2 = s.role_rollup_2
           and r.role_deptname = s.role_deptname and r.role_family = s.role_family and r.role_code = s.role_code
         group by s.resource, s.mgr_id, s.role_rollup_1, s.role_rollup_2, s.role_deptname, s.role_family, s.role_code
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource and #train.mgr_id = a.mgr_id_r and x.mgr_id = a.mgr_id_s
   and #train.role_rollup_1 = x.role_rollup_1 and #train.role_rollup_2 = x.role_rollup_2
   and #train.role_deptname = x.role_deptname and #train.role_family = x.role_family and #train.role_code = x.role_code

update #test--12230 rows
   set action5 = r.action
  from #train r, #alt_mgr a
 where #test.resource = r.resource and r.mgr_id = a.mgr_id_r and #test.mgr_id = a.mgr_id_s
   and #test.role_rollup_1 = r.role_rollup_1 and #test.role_rollup_2 = r.role_rollup_2
   and #test.role_deptname = r.role_deptname and #test.role_family = r.role_family
   and #test.role_code = r.role_code and r.flag5 is null
--AFTER STEP 5, WE HAVE ACTIONS FOR ACTIONS FOR 21145 ROWS
--STEP 6: use all columns except mgr_id and role_family_desc
update #train--548
   set flag6 = 1
  from (select r.resource, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family, r.role_code,
               count(distinct r.action) as [colName]--172
          from #train r
         group by r.resource, r.role_rollup_1, r.role_rollup_2, r.role_deptname, r.role_family, r.role_code
        having count(distinct r.action) > 1) x
 where #train.resource = x.resource and #train.role_code = x.role_code
   and #train.role_rollup_1 = x.role_rollup_1 and #train.role_rollup_2 = x.role_rollup_2
   and #train.role_deptname = x.role_deptname and #train.role_family = x.role_family

update #test --17057 rows
   set action6 = r.action
  from #train r
 where #test.resource = r.resource
   and #test.role_rollup_1 = r.role_rollup_1 and #test.role_rollup_2 = r.role_rollup_2
   and #test.role_deptname = r.role_deptname and #test.role_family = r.role_family
   and #test.role_code = r.role_code
   and r.flag6 is null
--AFTER STEP 6, WE HAVE ACTIONS FOR 23214 ROWS
--STEP 7: determine positive/negative signals from #train data [EXECUTE STEP 7 SEPARATELY]
  /* select top 100 * from #train
  select top 100 * from #test */
create table #count (
  resource	int not null,
  action	int not null,
  role_rollup1_ct	int not null,
  role_rollup2_ct	int not null,
  role_deptname_ct	int not null,
  role_family_ct	int not null,
  role_code_ct	int not null
)

insert #count
select resource, action, count(distinct role_rollup_1), count(distinct role_rollup_2),
       count(distinct role_deptname), count(distinct role_family), count(distinct role_code)
  from #train
 group by resource, action
 order by resource, action

--select * from #train where resource = 0
--select * from #count

create table #action (
  resource	int not null,
  action	int not null,
  role_rollup_1	int null,
  role_rollup_2	int null,
  role_deptname	int null,
  role_family	int null,
  role_code	int null
)

declare @action int, @val int, @val0 int, @val1 int, @resource int
select @resource = -1

while exists (select 1 from #count where resource > @resource)
begin
  select @resource = min(resource)
    from #count
   where resource > @resource

  if (select count(*) from #count where resource = @resource) > 1 --yes, have data for positive and negative action
  begin
    --role_rollup_1
    if exists (select 1 from #count where resource=@resource and action=0 and role_rollup1_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_rollup1_ct=1)
    begin
      select @val0 = role_rollup_1 from #train
       where resource = @resource and action = 0
      select @val1 = role_rollup_1 from #train
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_rollup_1=@val0 where resource=@resource and action=0
        update #action set role_rollup_1=@val1 where resource=@resource and action=1
      end
    end
    --role_rollup_2
    if exists (select 1 from #count where resource=@resource and action=0 and role_rollup2_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_rollup2_ct=1)
    begin
      select @val0 = role_rollup_2 from #train
       where resource = @resource and action = 0
      select @val1 = role_rollup_2 from #train
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_rollup_2=@val0 where resource=@resource and action=0
        update #action set role_rollup_2=@val1 where resource=@resource and action=1
      end
    end
    --role_deptname
    if exists (select 1 from #count where resource=@resource and action=0 and role_deptname_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_deptname_ct=1)
    begin
      select @val0 = role_deptname from #train
       where resource = @resource and action = 0
      select @val1 = role_deptname from #train
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_deptname=@val0 where resource=@resource and action=0
        update #action set role_deptname=@val1 where resource=@resource and action=1
      end
    end
    --role_family
    if exists (select 1 from #count where resource=@resource and action=0 and role_family_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_family_ct=1)
    begin
      select @val0 = role_family from #train
       where resource = @resource and action = 0
      select @val1 = role_family from #train
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_family=@val0 where resource=@resource and action=0
        update #action set role_family=@val1 where resource=@resource and action=1
      end
    end
    --role_code
    if exists (select 1 from #count where resource=@resource and action=0 and role_code_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_code_ct=1)
    begin
      select @val0 = role_code from #train
       where resource = @resource and action = 0
      select @val1 = role_code from #train
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_code=@val0 where resource=@resource and action=0
        update #action set role_code=@val1 where resource=@resource and action=1
      end
    end
  end
  else
  begin
    select @action=action from #count where resource=@resource
    --role_rollup_1
    if exists (select 1 from #count where resource=@resource and role_rollup1_ct=1)
    begin
      select @val = role_rollup_1 from #train where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_rollup_1=@val where resource=@resource
    end
    --role_rollup_2
    if exists (select 1 from #count where resource=@resource and role_rollup2_ct=1)
    begin
      select @val = role_rollup_2 from #train where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_rollup_2=@val where resource=@resource
    end
    --role_deptname
    if exists (select 1 from #count where resource=@resource and role_deptname_ct=1)
    begin
      select @val = role_deptname from #train where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_deptname=@val where resource=@resource
    end
    --role_family
    if exists (select 1 from #count where resource=@resource and role_family_ct=1)
    begin
      select @val = role_family from #train where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_family=@val where resource=@resource
    end
    --role_code
    if exists (select 1 from #count where resource=@resource and role_code_ct=1)
    begin
      select @val = role_code from #train where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_code=@val where resource=@resource
    end
  end
end
--role_rollup_1
update #test set action7 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_rollup_1 is not null
   and a.role_rollup_1 = #test.role_rollup_1
update #test set action7 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_rollup_1 is not null
   and a.role_rollup_1 = #test.role_rollup_1
--role_rollup_2
update #test set action7 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_rollup_2 is not null
   and a.role_rollup_2 = #test.role_rollup_2
update #test set action7 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_rollup_2 is not null
   and a.role_rollup_2 = #test.role_rollup_2
--role_deptname
update #test set action7 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_deptname is not null
   and a.role_deptname = #test.role_deptname
update #test set action7 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_deptname is not null
   and a.role_deptname = #test.role_deptname
--role_family
update #test set action7 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_family is not null
   and a.role_family = #test.role_family
update #test set action7 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_family is not null
   and a.role_family = #test.role_family
--role_code
update #test set action7 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_code is not null
   and a.role_code = #test.role_code
update #test set action7 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_code is not null
   and a.role_code = #test.role_code
/* delete #action
update #test set action7 = null
select * from #action
select top 100 * from #test
select * from #train where resource=1098 */
--AFTER STEP 7, WE HAVE ACTIONS FOR 31597 ROWS
UPDATE #test SET action = action1 WHERE action IS NULL AND action1 IS NOT NULL
UPDATE #test SET action = action2 WHERE action IS NULL AND action2 IS NOT NULL
UPDATE #test SET action = action3 WHERE action IS NULL AND action3 IS NOT NULL
UPDATE #test SET action = action4 WHERE action IS NULL AND action4 IS NOT NULL
UPDATE #test SET action = action5 WHERE action IS NULL AND action5 IS NOT NULL
UPDATE #test SET action = action6 WHERE action IS NULL AND action6 IS NOT NULL
UPDATE #test SET action = action7 WHERE action IS NULL AND action7 IS NOT NULL
--STEP 8: try to determine positive/negative signals from #test [EXECUTE STEP 8 SEPARATELY]
DELETE #count
DELETE #action

INSERT #count
SELECT resource, action, count(distinct role_rollup_1), count(distinct role_rollup_2),
       count(distinct role_deptname), count(distinct role_family), count(distinct role_code)
  FROM #test
 WHERE action IS NOT NULL
 GROUP BY resource, action
 ORDER BY resource, action

DECLARE @action INT, @val INT, @val0 INT, @val1 INT, @resource INT
SELECT @resource = -1

WHILE EXISTS (SELECT 1 FROM #count WHERE resource > @resource)
BEGIN
  SELECT @resource = MIN(resource)
    FROM #count
   WHERE resource > @resource

  if (select count(*) from #count where resource = @resource) > 1 --yes, have data for positive and negative action
  begin
    --role_rollup_1
    if exists (select 1 from #count where resource=@resource and action=0 and role_rollup1_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_rollup1_ct=1)
    begin
      select @val0 = role_rollup_1 from #test
       where resource = @resource and action = 0
      select @val1 = role_rollup_1 from #test
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_rollup_1=@val0 where resource=@resource and action=0
        update #action set role_rollup_1=@val1 where resource=@resource and action=1
      end
    end
    --role_rollup_2
    if exists (select 1 from #count where resource=@resource and action=0 and role_rollup2_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_rollup2_ct=1)
    begin
      select @val0 = role_rollup_2 from #test
       where resource = @resource and action = 0
      select @val1 = role_rollup_2 from #test
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_rollup_2=@val0 where resource=@resource and action=0
        update #action set role_rollup_2=@val1 where resource=@resource and action=1
      end
    end
    --role_deptname
    if exists (select 1 from #count where resource=@resource and action=0 and role_deptname_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_deptname_ct=1)
    begin
      select @val0 = role_deptname from #test
       where resource = @resource and action = 0
      select @val1 = role_deptname from #test
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_deptname=@val0 where resource=@resource and action=0
        update #action set role_deptname=@val1 where resource=@resource and action=1
      end
    end
    --role_family
    if exists (select 1 from #count where resource=@resource and action=0 and role_family_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_family_ct=1)
    begin
      select @val0 = role_family from #test
       where resource = @resource and action = 0
      select @val1 = role_family from #test
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_family=@val0 where resource=@resource and action=0
        update #action set role_family=@val1 where resource=@resource and action=1
      end
    end
    --role_code
    if exists (select 1 from #count where resource=@resource and action=0 and role_code_ct=1) and
       exists (select 1 from #count where resource=@resource and action=1 and role_code_ct=1)
    begin
      select @val0 = role_code from #test
       where resource = @resource and action = 0
      select @val1 = role_code from #test
       where resource = @resource and action = 1
      if @val0 != @val1
      begin
        if not exists (select 1 from #action where resource=@resource)
        begin
          insert #action (resource, action) select @resource, 0
          insert #action (resource, action) select @resource, 1
        end
        update #action set role_code=@val0 where resource=@resource and action=0
        update #action set role_code=@val1 where resource=@resource and action=1
      end
    end
  end
  else
  begin
    select @action=action from #count where resource=@resource
    --role_rollup_1
    if exists (select 1 from #count where resource=@resource and role_rollup1_ct=1)
    begin
      select @val = role_rollup_1 from #test where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_rollup_1=@val where resource=@resource
    end
    --role_rollup_2
    if exists (select 1 from #count where resource=@resource and role_rollup2_ct=1)
    begin
      select @val = role_rollup_2 from #test where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_rollup_2=@val where resource=@resource
    end
    --role_deptname
    if exists (select 1 from #count where resource=@resource and role_deptname_ct=1)
    begin
      select @val = role_deptname from #test where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_deptname=@val where resource=@resource
    end
    --role_family
    if exists (select 1 from #count where resource=@resource and role_family_ct=1)
    begin
      select @val = role_family from #test where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_family=@val where resource=@resource
    end
    --role_code
    if exists (select 1 from #count where resource=@resource and role_code_ct=1)
    begin
      select @val = role_code from #test where resource=@resource
      if not exists (select 1 from #action where resource=@resource)
      begin insert #action (resource, action) select @resource, @action end
      update #action set role_code=@val where resource=@resource
    end
  end
end
--role_rollup_1
update #test set action8 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_rollup_1 is not null
   and a.role_rollup_1 = #test.role_rollup_1
update #test set action8 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_rollup_1 is not null
   and a.role_rollup_1 = #test.role_rollup_1
--role_rollup_2
update #test set action8 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_rollup_2 is not null
   and a.role_rollup_2 = #test.role_rollup_2
update #test set action8 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_rollup_2 is not null
   and a.role_rollup_2 = #test.role_rollup_2
--role_deptname
update #test set action8 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_deptname is not null
   and a.role_deptname = #test.role_deptname
update #test set action8 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_deptname is not null
   and a.role_deptname = #test.role_deptname
--role_family
update #test set action8 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_family is not null
   and a.role_family = #test.role_family
update #test set action8 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_family is not null
   and a.role_family = #test.role_family
--role_code
update #test set action8 = 0 from #action a
 where #test.resource = a.resource and a.action = 0 and a.role_code is not null
   and a.role_code = #test.role_code
update #test set action8 = 1 from #action a
 where #test.resource = a.resource and a.action = 1 and a.role_code is not null
   and a.role_code = #test.role_code
--AFTER STEP 8, WE HAVE ACTIONS FOR 36018 ROWS
UPDATE #test SET action = action7 WHERE action IS NULL AND action8 IS NOT NULL

SELECT * FROM #test ORDER BY resource, id
select distinct resource from #test where action is null order by resource
select * from #train where resource = 969 order by action, id
select * from #test where resource = 969 order by action, id
--STEP 9: go through all NULLs in #test and if no columns match #test or #train then action is 0
--hmm, or find distinct values that get action of 0 vs distinct values that get action of 1

/*
1) we can create a list of alt_mgr_id's by matching all columns between #train and #test except for mgr_id obviously and resource
     yes, this will be useful because we will not be joining on resource and should have higher resultset
2) match all columns except role_family_desc and/or creating and using an alt_role_family_desc column
     questionable approach, i think
*/

select * from #train where role_rollup_1 = role_rollup_2 order by role_family_desc, role_code, role_deptname
select * from #test where role_rollup_1 = role_rollup_2 order by role_family_desc, role_code, role_deptname
  
--== BEGIN: check if any resources are always/never granted ==--
/*
create table #resource (
  resource int not null,
  num_req	int	not null,
  num_yes	int null,
  num_no	int null,
  num_req_in_test	int null
)

insert #resource (resource, num_req)
select resource, count(*)
  from #train
 group by resource
 order by resource

update #resource
   set num_yes = x.yes
  from (select resource, action, count(*) as [yes]
          from #train
         where action = 1
         group by resource, action) x
 where #resource.resource = x.resource

update #resource
   set num_no = x.no
  from (select resource, action, count(*) as [no]
          from #train
         where action = 0
         group by resource, action) x
 where #resource.resource = x.resource

update #resource
   set num_req_in_test = x.num
  from (select resource, count(*) as [num]
          from #test
         group by resource) x
 where #resource.resource = x.resource

select * from #resource

drop table #resource
*/
--== END: check if any resources are always/never granted ==--

--check if any employees get access to anything requested

--check if any employees get access to nothing requested


select distinct s.mgr_id, s.role_family_desc
  from #test s
 where not exists (select 1 from #train r
                    where s.mgr_id = r.mgr_id
                      and s.role_family_desc = r.role_family_desc)
 order by s.mgr_id, s.role_family_desc

select * from #train where role_family_desc = 130755
   and resource in (20226)
   --and role_deptname = 117941
   --and role_code = 117880
 order by mgr_id, resource

declare @role_family_desc int, @mgr_id int
select @role_family_desc= 192929, @mgr_id= 2498

select * from #test where role_family_desc = @role_family_desc and mgr_id = @mgr_id order by resource, mgr_id

select * from #train where role_family_desc = @role_family_desc
   and resource in (select resource from #test where role_family_desc = @role_family_desc and mgr_id = @mgr_id)
   --and role_deptname = 118501
   --and role_code = 118532
   --and role_rollup_1 = 117961 and role_rollup_2 =117962
   --and resource not in (20897)
 order by mgr_id, resource

select * from #train where mgr_id=@mgr_id
   and resource in (select resource from #test where role_family_desc = @role_family_desc and mgr_id = @mgr_id)
   --and resource not in (5893,3661)
 order by role_family_desc, resource

/*
drop table #alt_mgr
drop table #count
drop table #action
drop table #train
drop table #test
go
*/
/*
select * from #train where action2 is null

select * from #train where resource = 4675 order by action, mgr_id, role_family_desc, role_deptname, role_code
select * from #train where resource = 4675
   and (mgr_id in (2229,4202,58719) or role_rollup_2 in (118300,118052,118386) or role_deptname in (118450,118706,119954) or role_title in (119192,307024,118318) or role_family_desc in (132731,306404,168365) or role_family in (119184,118331,118205))
select * from #test where resource = 4675 order by mgr_id, role_family_desc, role_deptname, role_code
select * from #test order by resource, id
*/
/*				TRAIN			TEST
COLUMN			#VALUES			#VALUES
RESOURCE		7518			4971
MGR_ID			4243			4689
ROLE_ROLLUP_1	128				126
ROLE_ROLLUP_2	177				177
ROLE_DEPTNAME	449				466
ROLE_TITLE		343				351
ROLE_FAMILY_DESC	2358		2749
ROLE_FAMILY		67				68
ROLE_CODE		343				351

THINGS WE HAVE DETERMINED:
* ROLE_CODE <-> ROLE_TITLE is a one-to-one relationship
* ROLE_FAMILY_DESC is under ROLE_FAMILY but the data is probably dirty, needs to be cleaned up / massaged
* the nearest proxy for an employee id is probably the ROLE_FAMILY_DESC<->MGR_ID pair
    THERE ARE 7973 DISTINCT MGR_ID<->ROLE_FAMILY_DESC PAIRS IN #TRAIN
    THERE ARE 9691 DISTINCT MGR_ID<->ROLE_FAMILY_DESC PAIRS IN #TEST
* ROLLUP_1 and ROLLUP_2 values to not appear in the other column
    7 ROWS EXIST WHERE BOTH VALUES ARE 119370 IN #TRAIN
    23 ROWS EXIST WHERE BOTH VALUES ARE 119370 IN #TEST
* from #TRAIN, there are 38 employee resource requests (77 rows total) that have differing outcomes
* 670 managers exist in #test that do not exist in #train
* 593 role_family_desc values exist in #test that do not exist in #train
* 0 resources exist in #test that do not exist in #train
* 0 rows with match on all columns, 16912 rows match on all columns except mgr_id
* 2549 mgr<->role_family_desc pairs that exist in #test but not in #train
    will create alt_mgr_id's and
    will create alt_role_family_desc's for these cases
* while using alt id's, should score for similarity
*/


create or alter proc trn.s_rtn_prd_ins
	@p_cus_id int,
	@p_jsn nvarchar(max)
as
begin try
set nocount on
begin try drop table #t_dta end try begin catch end catch

--declare @p_cus_id int,
--		@p_jsn nvarchar(max) =
--		'[
--			{"ProductID":2, "Reason":"Broken"},
--			{"ProductID":9, "Reason":"I dont like it"},
--			{"ProductID":10, "Reason":"Not fitted"}
--		 ]'

	declare @p_prd_id int,
			@p_cur_dat smalldatetime = getdate(),
			@p_admin varchar(20) = 'Administrator',
			@p_rsn varchar(150)


	if isjson(@p_jsn) = 0
		raiserror ('Input parameter @p_jsn is not formatted properly.', 1, 16)

	select prd_id, rsn
	into #t_dta
	from openjson(@p_jsn)
	with (
			prd_id int '$.ProductID',
			rsn varchar(150) '$.Reason'
		 )

	declare cur_jsn cursor local fast_forward 
	for 
		 select *
		 from #t_dta

	open cur_jsn  
	fetch next from cur_jsn into @p_prd_id, @p_rsn
	while @@fetch_status = 0  
	begin  

		insert into trn.t_rtn_prd(prd_id, rsn, cre_dat, cre_by, upd_dat, upd_by)
		select @p_prd_id, @p_rsn, @p_cur_dat,@p_admin, @p_cur_dat, @p_admin

		update trn.t_prd
		set avl = 0
		where id = @p_prd_id

	fetch next from cur_jsn into @p_prd_id, @p_rsn
	end  
	close cur_jsn  
	deallocate cur_jsn

end try
begin catch
		
	declare @p_err_mes varchar(4000),
			@p_err_sev int,
			@p_err_sta int,
			@p_err_lne int,
			@p_err_num int,
			@p_prc_nme varchar(100)
			
	select @p_err_mes = error_message(),
			@p_err_sev = error_severity(),
			@p_err_sta = error_state(),
			@p_err_lne = error_line(),
			@p_err_num = error_number(),
			@p_prc_nme = isnull(object_schema_name(@@procid),'') + '.' + isnull(object_name(@@procid),'Custom Script')
	
	raiserror(@p_err_mes, @p_err_sev, 16)
	
end catch
set nocount off


GO

